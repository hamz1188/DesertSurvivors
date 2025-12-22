//
//  BaseEnemy.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class BaseEnemy: SKNode {

    // MARK: - Direction Enum (matches Player's for consistency)

    enum Direction: String, CaseIterable {
        case south, north, east, west
        case southEast = "south-east"
        case southWest = "south-west"
        case northEast = "north-east"
        case northWest = "north-west"

        /// Get direction from movement vector
        static func from(vector: CGPoint) -> Direction {
            guard vector.length() > 0.01 else { return .south }

            let angle = atan2(vector.y, vector.x)
            let degrees = angle * 180 / .pi

            // Convert angle to 8-direction
            switch degrees {
            case -22.5..<22.5: return .east
            case 22.5..<67.5: return .northEast
            case 67.5..<112.5: return .north
            case 112.5..<157.5: return .northWest
            case -67.5..<(-22.5): return .southEast
            case -112.5..<(-67.5): return .south
            case -157.5..<(-112.5): return .southWest
            default: return .west
            }
        }

        /// Map 8 directions to 4 for enemies with only 4-directional sprites
        var fourDirectional: Direction {
            switch self {
            case .south, .southEast, .southWest: return .south
            case .north, .northEast, .northWest: return .north
            case .east: return .east
            case .west: return .west
            }
        }
    }

    // MARK: - Properties

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

    // Direction and animation
    private var currentDirection: Direction = .south
    private var walkAnimations: [Direction: [SKTexture]] = [:]
    private var isAnimating: Bool = false

    /// Number of animation frames (override in subclasses: 4, 6, or 8)
    var animationFrameCount: Int { 4 }

    /// Whether this enemy uses 8-directional sprites (false = 4 directions)
    var uses8Directions: Bool { true }

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
        loadWalkAnimations()
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

    // MARK: - Animation Loading

    private func loadWalkAnimations() {
        guard let textureName = textureName else { return }

        let directions: [Direction] = uses8Directions
            ? Direction.allCases
            : [.south, .north, .east, .west]

        for direction in directions {
            var frames: [SKTexture] = []
            for i in 0..<animationFrameCount {
                let frameName = "\(textureName)-walking-\(direction.rawValue)-\(String(format: "%03d", i))"
                let texture = SKTexture(imageNamed: frameName)
                // Only add if texture is valid
                if texture.size().width > 0 {
                    texture.filteringMode = .nearest
                    frames.append(texture)
                }
            }
            if !frames.isEmpty {
                walkAnimations[direction] = frames
            }
        }
    }

    /// Update animation to face a direction (can be called by subclasses)
    func updateFacingDirection(_ direction: Direction) {
        startWalkAnimation(direction: direction)
    }

    /// Update animation based on movement vector (can be called by subclasses)
    func updateFacingVector(_ vector: CGPoint) {
        if vector.length() > 0.01 {
            let direction = Direction.from(vector: vector)
            startWalkAnimation(direction: direction)
        }
    }

    private func startWalkAnimation(direction: Direction) {
        let effectiveDirection = uses8Directions ? direction : direction.fourDirectional

        guard let frames = walkAnimations[effectiveDirection], !frames.isEmpty else { return }

        // Don't restart if already animating this direction
        if isAnimating && currentDirection == effectiveDirection { return }

        currentDirection = effectiveDirection
        isAnimating = true

        spriteNode.removeAction(forKey: "walk")
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        let repeatAction = SKAction.repeatForever(animate)
        spriteNode.run(repeatAction, withKey: "walk")
    }

    private func stopWalkAnimation() {
        guard isAnimating else { return }
        isAnimating = false
        spriteNode.removeAction(forKey: "walk")

        // Set to first frame of current direction
        let effectiveDirection = uses8Directions ? currentDirection : currentDirection.fourDirectional
        if let frames = walkAnimations[effectiveDirection], let firstFrame = frames.first {
            spriteNode.texture = firstFrame
        }
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
        let directionVector = (playerPosition - position).normalized()
        let movement = directionVector * moveSpeed * CGFloat(deltaTime)
        let oldPosition = position
        position = position + movement

        // Check if enemy moved enough to require rehashing (half a cell or more)
        let moveDist = oldPosition.distance(to: position)
        if moveDist > Constants.spatialHashCellSize / 2 {
            needsRehash = true
        }

        // Update animation based on movement direction
        if directionVector.length() > 0.01 {
            let newDirection = Direction.from(vector: directionVector)
            startWalkAnimation(direction: newDirection)
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
        currentDirection = .south
        isAnimating = false
        spriteNode?.removeAllActions()
        spriteNode?.alpha = 1.0
        spriteNode?.setScale(1.0)
        // Set initial texture to south-facing
        if let frames = walkAnimations[.south], let firstFrame = frames.first {
            spriteNode?.texture = firstFrame
        }
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
