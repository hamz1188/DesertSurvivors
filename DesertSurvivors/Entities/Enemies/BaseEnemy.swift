//
//  BaseEnemy.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class BaseEnemy: SKNode {
    var enemyName: String
    var maxHealth: Float
    var currentHealth: Float
    var moveSpeed: CGFloat
    var damage: Float
    var xpValue: Float = 10 // Experience value when killed

    var spriteNode: SKSpriteNode!
    weak var target: Player?

    /// Delegate for enemy death events (preferred over NotificationCenter)
    weak var eventDelegate: EnemyEventDelegate?

    private var originalColor: SKColor = .red
    private var isDying: Bool = false

    // Spatial hash optimization
    var lastHashedPosition: CGPoint = .zero
    var needsRehash: Bool = true

    // Rotation caching optimization - avoid atan2() every frame
    private var cachedRotation: CGFloat = 0
    private var lastRotationDirection: CGPoint = .zero
    private let rotationUpdateThreshold: CGFloat = 0.1 // Only update rotation if direction changed significantly

    var textureName: String? // Added property
    var poolType: String? // Tracks which pool this enemy belongs to for recycling
    
    init(name: String, maxHealth: Float, moveSpeed: CGFloat, damage: Float, xpValue: Float = 10, textureName: String? = nil) {
        self.enemyName = name
        // Validate all numeric inputs to prevent exploits/bugs
        self.maxHealth = InputValidation.validateMaxHealth(maxHealth)
        self.currentHealth = self.maxHealth
        self.moveSpeed = InputValidation.validateSpeed(moveSpeed)
        self.damage = InputValidation.validateEnemyDamage(damage)
        self.xpValue = InputValidation.validateXP(xpValue)
        self.textureName = textureName
        super.init()

        // Set SKNode's name property (inherited, optional String)
        self.name = name

        setupSprite()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprite() {
        if let textureName = textureName {
            // Try to load the base texture
            spriteNode = SKSpriteNode(imageNamed: textureName)
            if spriteNode.texture == nil {
                // Fallback if texture missing
                spriteNode = SKSpriteNode(color: originalColor, size: CGSize(width: 30, height: 30))
            } else {
                spriteNode.scale(to: CGSize(width: 35, height: 35))
            }
        } else {
            // Placeholder sprite - colored circle
            let size = CGSize(width: 25, height: 25)
            spriteNode = SKSpriteNode(color: originalColor, size: size)
        }
        spriteNode.zPosition = Constants.ZPosition.enemy
        addChild(spriteNode)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 12.5)
        physicsBody?.categoryBitMask = Constants.PhysicsCategory.enemy
        physicsBody?.collisionBitMask = Constants.PhysicsCategory.none
        physicsBody?.contactTestBitMask = Constants.PhysicsCategory.player | Constants.PhysicsCategory.projectile
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive else { return }

        // Move toward player
        let direction = (playerPosition - position).normalized()
        let movement = direction * moveSpeed * CGFloat(deltaTime)
        let oldPosition = position
        position = position + movement

        // Check if enemy moved enough to require rehashing (half a cell or more)
        let moveDist = oldPosition.distance(to: position)
        if moveDist > Constants.spatialHashCellSize / 2 {
            needsRehash = true
        }

        // Rotate sprite to face movement direction (optimized: only recalculate if direction changed significantly)
        if direction.length() > 0 {
            let directionDelta = abs(direction.x - lastRotationDirection.x) + abs(direction.y - lastRotationDirection.y)
            if directionDelta > rotationUpdateThreshold {
                cachedRotation = atan2(direction.y, direction.x)
                lastRotationDirection = direction
                spriteNode.zRotation = cachedRotation
            }
        }
    }
    
    func takeDamage(_ amount: Float) {
        guard isAlive else { return }
        // Validate damage to prevent negative values or exploits
        let validatedDamage = InputValidation.validateDamage(amount)
        currentHealth -= validatedDamage

        // Visual feedback
        flashDamage()
        
        // Audio feedback
        if let scene = scene {
            SoundManager.shared.playSFX(filename: "sfx_enemy_hit.wav", scene: scene)
        }
        
        if currentHealth <= 0 {
            die()
        }
    }
    
    private func flashDamage() {
        // Cancel any previous flash animation
        spriteNode.removeAction(forKey: "flash")
        
        let flashWhite = SKAction.run { [weak self] in
            self?.spriteNode.color = .white
        }
        let wait = SKAction.wait(forDuration: 0.05)
        let resetColor = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.spriteNode.color = self.originalColor
        }
        spriteNode.run(SKAction.sequence([flashWhite, wait, resetColor]), withKey: "flash")
    }
    
    func die() {
        // Prevent double-call bug (e.g., from simultaneous projectile hits)
        guard !isDying else { return }
        isDying = true

        // Death animation
        currentHealth = 0

        // Audio
        if let scene = scene {
            SoundManager.shared.playSFX(filename: "sfx_enemy_die.wav", scene: scene)
        }

        // Notify via delegate (preferred)
        eventDelegate?.enemyDidDie(at: position, xpValue: xpValue)

        // Also post notification for backward compatibility
        NotificationCenter.default.post(name: .enemyDied, object: nil, userInfo: ["position": position, "xp": xpValue])

        // Scale down and fade out
        let shrink = SKAction.scale(to: 0.5, duration: 0.15)
        let fade = SKAction.fadeOut(withDuration: 0.15)
        let remove = SKAction.removeFromParent()
        let group = SKAction.group([shrink, fade])

        spriteNode.run(SKAction.sequence([group, remove]))
    }
    
    var isAlive: Bool {
        return currentHealth > 0 && parent != nil
    }

    /// Set the enemy's base color (used by subclasses)
    func setColor(_ color: SKColor) {
        originalColor = color
        spriteNode?.color = color
    }

    // MARK: - Object Pooling Support

    /// Reset enemy state for reuse from object pool
    func reset() {
        currentHealth = maxHealth
        isDying = false
        isHidden = false
        alpha = 1.0
        setScale(1.0)
        lastHashedPosition = .zero
        needsRehash = true
        cachedRotation = 0
        lastRotationDirection = .zero
        spriteNode?.removeAllActions()
        spriteNode?.alpha = 1.0
        spriteNode?.setScale(1.0)
        spriteNode?.zRotation = 0
        // Note: eventDelegate is set by EnemySpawner after spawning
    }

    /// Prepare enemy for return to pool (called instead of removeFromParent in pooled scenarios)
    func prepareForPool() {
        removeFromParent()
        isHidden = true
        removeAllActions()
    }
}


extension Notification.Name {
    static let enemyDied = Notification.Name("enemyDied")
}
