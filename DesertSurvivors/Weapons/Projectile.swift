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
        spriteNode = SKSpriteNode(color: .clear, size: CGSize(width: 16, height: 20))

        // Create a mystical sand crystal projectile
        let container = SKNode()
        container.name = "shard"

        // Main crystal body - elongated hexagonal shape
        let crystalPath = CGMutablePath()
        crystalPath.move(to: CGPoint(x: 0, y: 10))      // Top point
        crystalPath.addLine(to: CGPoint(x: 4, y: 5))    // Upper right
        crystalPath.addLine(to: CGPoint(x: 4, y: -4))   // Lower right
        crystalPath.addLine(to: CGPoint(x: 0, y: -10))  // Bottom point
        crystalPath.addLine(to: CGPoint(x: -4, y: -4))  // Lower left
        crystalPath.addLine(to: CGPoint(x: -4, y: 5))   // Upper left
        crystalPath.closeSubpath()

        let crystal = SKShapeNode(path: crystalPath)
        crystal.fillColor = color
        crystal.strokeColor = color.lighter(by: 0.3)
        crystal.lineWidth = 1
        container.addChild(crystal)

        // Inner glow/facet
        let innerPath = CGMutablePath()
        innerPath.move(to: CGPoint(x: 0, y: 7))
        innerPath.addLine(to: CGPoint(x: 2, y: 3))
        innerPath.addLine(to: CGPoint(x: 2, y: -2))
        innerPath.addLine(to: CGPoint(x: 0, y: -6))
        innerPath.addLine(to: CGPoint(x: -1, y: -2))
        innerPath.addLine(to: CGPoint(x: -1, y: 3))
        innerPath.closeSubpath()

        let innerFacet = SKShapeNode(path: innerPath)
        innerFacet.fillColor = color.lighter(by: 0.4)
        innerFacet.strokeColor = .clear
        innerFacet.alpha = 0.6
        container.addChild(innerFacet)

        // Bright highlight
        let highlight = SKShapeNode(ellipseOf: CGSize(width: 2, height: 4))
        highlight.fillColor = .white
        highlight.strokeColor = .clear
        highlight.alpha = 0.7
        highlight.position = CGPoint(x: -1, y: 4)
        container.addChild(highlight)

        // Sand particle trail effect
        let trail = SKEmitterNode()
        trail.particleBirthRate = 40
        trail.particleLifetime = 0.3
        trail.particlePositionRange = CGVector(dx: 4, dy: 4)
        trail.particleSpeed = 20
        trail.particleSpeedRange = 10
        trail.emissionAngle = .pi
        trail.emissionAngleRange = 0.5
        trail.particleAlpha = 0.5
        trail.particleAlphaSpeed = -1.5
        trail.particleScale = 0.08
        trail.particleScaleSpeed = -0.2
        trail.particleColor = color
        trail.particleColorBlendFactor = 1.0
        trail.position = CGPoint(x: 0, y: -8)
        container.addChild(trail)

        spriteNode.addChild(container)
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
        
        if let shard = spriteNode.childNode(withName: "shard") as? SKShapeNode {
            shard.fillColor = color
        }
        
        // Face movement direction
        spriteNode.zRotation = atan2(direction.y, direction.x) - .pi/2
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

