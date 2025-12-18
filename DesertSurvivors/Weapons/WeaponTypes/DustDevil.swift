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
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
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
        
        // Visual representation - spinning circle
        let visual = SKShapeNode(circleOfRadius: devilRadius)
        visual.fillColor = SKColor(white: 0.8, alpha: 0.6)
        visual.strokeColor = .brown
        visual.lineWidth = 3
        container.addChild(visual)
        
        // Spin animation
        visual.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 1.0)))
        
        return container
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        gameTime += deltaTime
        
        // Update active devils and damage enemies
        activeDevils = activeDevils.compactMap { devilData in
            if devilData.node.parent == nil {
                return nil
            }
            
            // Damage enemies in range at intervals
            if gameTime - devilData.lastDamageTime >= damageInterval {
                for enemy in enemies {
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

