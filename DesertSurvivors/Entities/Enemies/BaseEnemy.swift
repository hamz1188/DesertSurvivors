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
    
    private var originalColor: SKColor = .red
    private var isFlashing: Bool = false
    
    var textureName: String? // Added property
    
    init(name: String, maxHealth: Float, moveSpeed: CGFloat, damage: Float, xpValue: Float = 10, textureName: String? = nil) {
        self.enemyName = name
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        self.moveSpeed = moveSpeed
        self.damage = damage
        self.xpValue = xpValue
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
            spriteNode = SKSpriteNode(imageNamed: textureName)
            if spriteNode.texture == nil {
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
        position = position + movement
        
        // Rotate sprite to face movement direction
        if direction.length() > 0 {
            spriteNode.zRotation = atan2(direction.y, direction.x)
        }
    }
    
    func takeDamage(_ amount: Float) {
        guard isAlive else { return }
        currentHealth -= amount
        
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
        guard !isFlashing else { return }
        isFlashing = true
        
        let flashWhite = SKAction.run { [weak self] in
            self?.spriteNode.color = .white
        }
        let wait = SKAction.wait(forDuration: 0.05)
        let resetColor = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.spriteNode.color = self.originalColor
            self.isFlashing = false
        }
        spriteNode.run(SKAction.sequence([flashWhite, wait, resetColor]))
    }
    
    func die() {
        // Death animation
        currentHealth = 0
        
        // Audio
        if let scene = scene {
            SoundManager.shared.playSFX(filename: "sfx_enemy_die.wav", scene: scene)
        }
        
        // Notify game to spawn XP and count kill
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
}


extension Notification.Name {
    static let enemyDied = Notification.Name("enemyDied")
}
