//
//  Projectile.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Projectile: SKNode {
    var damage: Float
    var projectileSpeed: CGFloat
    var direction: CGPoint
    var lifetime: TimeInterval = 5.0
    private var elapsedTime: TimeInterval = 0
    private var spriteNode: SKSpriteNode!
    var hasHit: Bool = false
    
    init(damage: Float, speed: CGFloat, direction: CGPoint, color: SKColor = .yellow) {
        self.damage = damage
        self.projectileSpeed = speed
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
    
    func configure(damage: Float, speed: CGFloat, direction: CGPoint, color: SKColor = .yellow) {
        self.damage = damage
        self.projectileSpeed = speed
        self.direction = direction.normalized()
        self.elapsedTime = 0
        self.hasHit = false
        self.spriteNode.color = color
        self.spriteNode.colorBlendFactor = 1.0
        self.isHidden = false
    }
    
    func update(deltaTime: TimeInterval, onExpired: () -> Void) {
        elapsedTime += deltaTime
        
        if elapsedTime >= lifetime {
            onExpired()
            return
        }
        
        // Move projectile
        let movement = direction * projectileSpeed * CGFloat(deltaTime)
        position = position + movement
    }
    
    func checkCollision(spatialHash: SpatialHash) -> BaseEnemy? {
        guard !hasHit else { return nil }
        
        // Query spatial hash for nearby enemies (using a radius slightly larger than collision distance)
        let nearbyNodes = spatialHash.query(near: position, radius: 25)
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            
            if position.distance(to: enemy.position) < 20 {
                hasHit = true
                enemy.takeDamage(damage)
                return enemy
            }
        }
        return nil
    }
}

