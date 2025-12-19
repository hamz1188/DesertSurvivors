//
//  EyeOfTheStorm.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class EyeOfTheStorm: BaseWeapon {
    // Evolved Sandstorm Shield (Sandstorm Shield + Desert Rose)
    // Behavior: Permanent impernetrable storm barrier, arcs lightning.
    
    private var shieldNode: SKShapeNode?
    private let shieldRadius: CGFloat = 120
    private var hitTimer: TimeInterval = 0
    private let hitInterval: TimeInterval = 0.1 // Very fast hits
    private var arcTimer: TimeInterval = 0
    
    init() {
        super.init(name: "Eye of the Storm", baseDamage: 15, cooldown: 0.1)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        if shieldNode == nil {
            createShield(scene: scene)
        }
    }
    
    private func createShield(scene: SKScene?) {
        guard let scene = scene else { return }
        
        let node = SKShapeNode(circleOfRadius: shieldRadius)
        node.fillColor = SKColor.white.withAlphaComponent(0.2)
        node.strokeColor = .cyan
        node.lineWidth = 4
        node.glowWidth = 10
        node.zPosition = Constants.ZPosition.weapon
        scene.addChild(node)
        shieldNode = node
        
        // Add swirling clouds/lightning effect
        let cloud = SKShapeNode(circleOfRadius: shieldRadius * 0.9)
        cloud.strokeColor = .white
        cloud.lineWidth = 2
        // SKShapeNode dash pattern issue workaround: just solid line or transparent
        cloud.alpha = 0.5
        node.addChild(cloud)
        
        cloud.run(SKAction.repeatForever(SKAction.rotate(byAngle: 5, duration: 1.0)))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        guard let shield = shieldNode else { return }
        shield.position = playerPosition
        
        // Rapid damage area
        hitTimer += deltaTime
        if hitTimer >= hitInterval {
            hitTimer = 0
            for enemy in enemies where enemy.isAlive {
                if enemy.position.distance(to: playerPosition) < shieldRadius {
                    enemy.takeDamage(getDamage())
                    
                    // Knockback
                    let dir = (enemy.position - playerPosition).normalized()
                    enemy.position = enemy.position + (dir * 5)
                }
            }
        }
        
        // Lightning Arcs
        arcTimer += deltaTime
        if arcTimer >= 0.5 {
            arcTimer = 0
            fireLightningArc(from: playerPosition, enemies: enemies, scene: shield.parent)
        }
    }
    
    private func fireLightningArc(from origin: CGPoint, enemies: [BaseEnemy], scene: SKNode?) {
        guard let scene = scene else { return }
        
        // Find random enemy outside shield but close
        let closeEnemies = enemies.filter {
            let d = $0.position.distance(to: origin)
            return d > shieldRadius && d < shieldRadius * 3 && $0.isAlive
        }
        
        if let target = closeEnemies.randomElement() {
            // Draw line
            let path = CGMutablePath()
            path.move(to: origin)
            path.addLine(to: target.position)
            
            let bolt = SKShapeNode(path: path)
            bolt.strokeColor = .cyan
            bolt.lineWidth = 3
            bolt.zPosition = Constants.ZPosition.projectile
            scene.addChild(bolt)
            
            target.takeDamage(getDamage() * 2) // Bonus damage
            
            bolt.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.1),
                SKAction.fadeOut(withDuration: 0.1),
                SKAction.removeFromParent()
            ]))
        }
    }
}
