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
    
    var spriteNode: SKSpriteNode!
    weak var target: Player?
    
    init(name: String, maxHealth: Float, moveSpeed: CGFloat, damage: Float) {
        self.enemyName = name
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
        self.moveSpeed = moveSpeed
        self.damage = damage
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
        // Placeholder sprite - colored circle
        let size = CGSize(width: 25, height: 25)
        spriteNode = SKSpriteNode(color: .red, size: size)
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
        if currentHealth <= 0 {
            die()
        }
    }
    
    func die() {
        // Override in subclasses for death effects
        currentHealth = 0
    }
    
    var isAlive: Bool {
        return currentHealth > 0 && parent != nil
    }
}

