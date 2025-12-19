//
//  IfritsEmbrace.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class IfritsEmbrace: BaseWeapon {
    // Evolved Djinn's Flame (Djinn's Flame + Djinn Lamp)
    // Behavior: Ring of living fire around player + Homing Spirits
    
    private var fireRing: SKNode?
    private let ringRadius: CGFloat = 100
    private var spirits: [SKShapeNode] = []
    private var spawnTimer: TimeInterval = 0
    private let spawnInterval: TimeInterval = 0.5
    
    init() {
        super.init(name: "Ifrit's Embrace", baseDamage: 20, cooldown: 0.1)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        if fireRing == nil {
            createFireRing(scene: scene)
        }
    }
    
    private func createFireRing(scene: SKScene?) {
        guard let scene = scene else { return }
        
        let container = SKNode()
        container.zPosition = Constants.ZPosition.weapon
        scene.addChild(container)
        fireRing = container
        
        // Create 8 orbital fireballs
        for i in 0..<8 {
            let angle = (CGFloat(i) / 8.0) * 2 * .pi
            let fireball = SKShapeNode(circleOfRadius: 15)
            fireball.fillColor = .orange
            fireball.strokeColor = .red
            fireball.glowWidth = 5
            
            let x = cos(angle) * ringRadius
            let y = sin(angle) * ringRadius
            fireball.position = CGPoint(x: x, y: y)
            
            container.addChild(fireball)
        }
        
        // Spin
        container.run(SKAction.repeatForever(SKAction.rotate(byAngle: 3, duration: 1.0)))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        guard let ring = fireRing else { return }
        ring.position = playerPosition
        
        // Ring Damage (Contact)
        for enemy in enemies where enemy.isAlive {
            let dist = enemy.position.distance(to: playerPosition)
            if abs(dist - ringRadius) < 30 {
                 enemy.takeDamage(getDamage() * 0.5) // Rapid low damage
                 // Maybe burn logic if we had it exposed
            }
        }
        
        // Spawn Homing Spirits
        spawnTimer += deltaTime
        if spawnTimer >= spawnInterval {
            spawnTimer = 0
            spawnSpirit(at: playerPosition, scene: ring.scene)
        }
        
        // Update Spirits
        updateSpirits(deltaTime: deltaTime, enemies: enemies)
    }
    
    private func spawnSpirit(at position: CGPoint, scene: SKNode?) {
        guard let scene = scene else { return }
        
        let spirit = SKShapeNode(circleOfRadius: 10)
        spirit.fillColor = .red
        spirit.strokeColor = .yellow
        spirit.position = position
        spirit.zPosition = Constants.ZPosition.projectile
        scene.addChild(spirit)
        
        spirits.append(spirit)
    }
    
    private func updateSpirits(deltaTime: TimeInterval, enemies: [BaseEnemy]) {
        for (index, spirit) in spirits.enumerated().reversed() {
            // Find target
            if let target = findNearestEnemy(from: spirit.position, enemies: enemies) {
                let dir = (target.position - spirit.position).normalized()
                let speed: CGFloat = 400
                spirit.position = spirit.position + (dir * speed * CGFloat(deltaTime))
                
                if spirit.position.distance(to: target.position) < 20 {
                    target.takeDamage(getDamage())
                    
                    // Explode visual
                    spirit.removeFromParent()
                    spirits.remove(at: index)
                }
            } else {
                // Just move outward or fade
                spirit.alpha -= CGFloat(deltaTime)
                if spirit.alpha <= 0 {
                    spirit.removeFromParent()
                    spirits.remove(at: index)
                }
            }
        }
    }
    
    private func findNearestEnemy(from position: CGPoint, enemies: [BaseEnemy]) -> BaseEnemy? {
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        for enemy in enemies where enemy.isAlive {
            let d = position.distance(to: enemy.position)
            if d < nearestDistance {
                nearestDistance = d
                nearest = enemy
            }
        }
        return nearest
    }
}
