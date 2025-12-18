//
//  Projectile.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Projectile: SKNode {
    var damage: Float
    var speed: CGFloat
    var direction: CGPoint
    var lifetime: TimeInterval = 5.0
    private var elapsedTime: TimeInterval = 0
    private var spriteNode: SKSpriteNode!
    var hasHit: Bool = false
    
    init(damage: Float, speed: CGFloat, direction: CGPoint, color: SKColor = .yellow) {
        self.damage = damage
        self.speed = speed
        self.direction = direction.normalized()
        super.init()
        
        setupSprite(color: color)
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprite(color: SKColor) {
        spriteNode = SKSpriteNode(color: color, size: CGSize(width: 12, height: 12))
        spriteNode.zPosition = Constants.ZPosition.projectile
        addChild(spriteNode)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 6)
        physicsBody?.categoryBitMask = Constants.PhysicsCategory.projectile
        physicsBody?.collisionBitMask = Constants.PhysicsCategory.none
        physicsBody?.contactTestBitMask = Constants.PhysicsCategory.enemy
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    func update(deltaTime: TimeInterval) {
        elapsedTime += deltaTime
        
        if elapsedTime >= lifetime {
            removeFromParent()
            return
        }
        
        // Move projectile
        let movement = direction * speed * CGFloat(deltaTime)
        position = position + movement
    }
    
    func checkCollision(with enemies: [BaseEnemy]) -> BaseEnemy? {
        for enemy in enemies {
            if position.distance(to: enemy.position) < 20 && !hasHit {
                hasHit = true
                enemy.takeDamage(damage)
                return enemy
            }
        }
        return nil
    }
}

