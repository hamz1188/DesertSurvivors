//
//  DustDevil.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DustDevil: BaseWeapon {
    private struct DevilData {
        let node: SKNode
        var lastDamageTime: TimeInterval
    }
    
    private var activeDevils: [DevilData] = []
    private var devilRadius: CGFloat = 80
    private var devilDuration: TimeInterval = 3.0
    private var damageInterval: TimeInterval = 0.2 // Damage every 0.2 seconds
    private var gameTime: TimeInterval = 0
    
    init() {
        super.init(name: "Dust Devil", baseDamage: 5, cooldown: 4.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Create whirlwind at random location near player
        let angle = Double.random(in: 0..<2 * .pi)
        let distance = CGFloat.random(in: 100...300)
        let spawnX = playerPosition.x + cos(angle) * distance
        let spawnY = playerPosition.y + sin(angle) * distance
        
        let devil = createDustDevil(at: CGPoint(x: spawnX, y: spawnY))
        scene.addChild(devil)
        activeDevils.append(DevilData(node: devil, lastDamageTime: gameTime))
        
        // Remove after duration
        devil.run(SKAction.sequence([
            SKAction.wait(forDuration: devilDuration),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createDustDevil(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = Constants.ZPosition.weapon
        
        // Vortex rings
        let ringCount = 3
        for i in 0..<ringCount {
            let radius = devilRadius * CGFloat(i + 1) / CGFloat(ringCount)
            let ring = SKShapeNode(circleOfRadius: radius)
            ring.fillColor = .clear
            ring.strokeColor = SKColor(white: 0.82, alpha: 0.4)
            ring.lineWidth = 2
            
            // Add some "dust" clouds around the ring
            for _ in 0..<4 {
                let angle = CGFloat.random(in: 0..<2 * .pi)
                let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 5...12))
                dust.fillColor = SKColor(red: 0.76, green: 0.69, blue: 0.5, alpha: 0.3)
                dust.strokeColor = .clear
                dust.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
                ring.addChild(dust)
            }
            
            container.addChild(ring)
            
            // Rotation speed varies by ring
            let duration = 1.0 / Double(i + 1)
            ring.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: duration)))
        }
        
        return container
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        gameTime += deltaTime
        
        // Update active devils and damage enemies using spatial hash
        activeDevils = activeDevils.compactMap { devilData in
            if devilData.node.parent == nil {
                return nil
            }
            
            // Damage enemies in range at intervals
            if gameTime - devilData.lastDamageTime >= damageInterval {
                let nearbyNodes = spatialHash.query(near: devilData.node.position, radius: devilRadius)
                
                for node in nearbyNodes {
                    guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                    if devilData.node.position.distance(to: enemy.position) < devilRadius {
                        enemy.takeDamage(getDamage())
                    }
                }
                return DevilData(node: devilData.node, lastDamageTime: gameTime)
            }
            
            return devilData
        }
    }
    
    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 80 radius, 3.0s duration, 0.2s damage interval
        // Level 2: 95 radius, 3.5s duration
        // Level 3: 110 radius, 4.0s duration
        // Level 4: 125 radius, 4.5s duration, faster damage
        // Level 5: 140 radius, 5.0s duration
        // Level 6: 155 radius, 5.5s duration
        // Level 7: 170 radius, 6.0s duration
        // Level 8: 185 radius, 6.5s duration, even faster damage

        devilRadius = 80 + CGFloat(level - 1) * 15
        devilDuration = 3.0 + Double(level - 1) * 0.5

        // Faster damage ticks at higher levels
        if level >= 4 {
            damageInterval = 0.15
        }
        if level >= 8 {
            damageInterval = 0.1
        }
    }
}

