//
//  Haboob.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class Haboob: BaseWeapon {
    // Evolved Dust Devil (Dust Devil + Sandstorm Cloak)
    // Behavior: Massive sandstorms with vacuum effect
    
    private struct StormData {
        let node: SKShapeNode
        let visualNode: SKNode
        var lifetime: TimeInterval
    }
    
    private var activeStorms: [StormData] = []
    private let stormRadius: CGFloat = 200
    private let vacuumStrength: CGFloat = 3.0
    private let hitInterval: TimeInterval = 0.2
    private var gameTime: TimeInterval = 0
    
    init() {
        super.init(name: "Haboob", baseDamage: 8, cooldown: 5.0) // Large AOE, longer cooldown but lasts long
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Spawn a massive storm near the player
        guard let scene = scene else { return }
        
        let spawnPos = playerPosition
        
        let storm = createStorm()
        storm.position = spawnPos
        scene.addChild(storm)
        
        // Expand
        storm.setScale(0.1)
        storm.run(SKAction.scale(to: 1.0, duration: 1.0))
        
        // Visual spin
        if let visual = storm.userData?["visual"] as? SKNode {
            visual.run(SKAction.repeatForever(SKAction.rotate(byAngle: -5, duration: 1.0)))
        }
        
        // Add to tracking
        // Note: We need to recreate the struct to store it properly since we just made the node
        // Actually createStorm returns the node, let's look inside
        
        activeStorms.append(StormData(node: storm, visualNode: storm, lifetime: 8.0))
        
        // Fade out at end
        storm.run(SKAction.sequence([
            SKAction.wait(forDuration: 7.0),
            SKAction.fadeOut(withDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createStorm() -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: stormRadius)
        node.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.3) // Sand color
        node.strokeColor = .clear
        node.zPosition = Constants.ZPosition.weapon
        
        // Add inner details (particles or swirling dust lines)
        let dust = SKShapeNode(circleOfRadius: stormRadius * 0.8)
        dust.strokeColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.5)
        dust.lineWidth = 4
        // SKShapeNode doesn't support lineDashPattern directly like CAShapeLayer without underlying access
        // We will just use transparency for effect or multiple rings
        node.addChild(dust)
        
        // Store visual ref in userData if needed, or just rotate the whole node
        node.userData = ["visual": dust]
        
        return node
    }
    
    // Hit tracking per storm per enemy is complex.
    // Let's use a global (per weapon instance) hit tracker map like the others.
    private var enemyHitTimes: [ObjectIdentifier: TimeInterval] = [:]
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        gameTime += deltaTime
        
        // Filter out dead storms
        activeStorms = activeStorms.filter { $0.node.parent != nil }
        
        // Effect logic
        for storm in activeStorms {
            let center = storm.node.position
            
            // Vacuum and Damage
            for enemy in enemies where enemy.isAlive {
                let toCenter = center - enemy.position
                let dist = toCenter.length()
                
                if dist < stormRadius + 50 { // Slightly larger pull range
                    // Pull effect
                    let pullDir = toCenter.normalized()
                    // Apply displacement
                    // Stronger pull when closer? Or constant?
                    // Let's do constant pull
                    enemy.position = enemy.position + (pullDir * vacuumStrength)
                    
                    // Damage if inside actual radius
                    if dist < stormRadius {
                        if canHit(enemy) {
                            enemy.takeDamage(getDamage())
                            recordHit(enemy)
                        }
                    }
                }
            }
        }
    }
    
    private func canHit(_ enemy: BaseEnemy) -> Bool {
        let id = ObjectIdentifier(enemy)
        if let lastHit = enemyHitTimes[id] {
            return CACurrentMediaTime() - lastHit > hitInterval
        }
        return true
    }
    
    private func recordHit(_ enemy: BaseEnemy) {
        enemyHitTimes[ObjectIdentifier(enemy)] = CACurrentMediaTime()
    }
}
