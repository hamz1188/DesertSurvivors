//
//  DesertStorm.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class DesertStorm: BaseWeapon {
    // Evolved Sand Bolt (Sand Bolt + Djinn Lamp)
    // Behavior: Machine-gun like rapid fire, high velocity, explosive impact
    
    init() {
        super.init(name: "Desert Storm", baseDamage: 25, cooldown: 0.15)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene, let enemy = findNearestEnemy(from: playerPosition, enemies: enemies) else { return }
        
        // Fire bolt
        let bolt = createBolt()
        bolt.position = playerPosition
        scene.addChild(bolt)
        
        // Calculate direction
        let direction = (enemy.position - playerPosition).normalized()
        let angle = atan2(direction.y, direction.x)
        bolt.zRotation = angle
        
        // Movement
        let velocity: CGFloat = 800 // Very fast
        let moveDuration = 1000 / velocity // Large distance
        
        let moveAction = SKAction.move(by: CGVector(dx: direction.x * 1000, dy: direction.y * 1000), duration: moveDuration)
        let doneAction = SKAction.removeFromParent()
        
        bolt.run(SKAction.sequence([moveAction, doneAction]))
        
        // Check for hits (Projectile logic handled here for simplicity or via collision manager)
        // Since we don't have a centralized ProjectileManager yet, we do simple distance check or physics body.
        // For reliability without physics engine overhead, let's use a repeating action to check overlap.
        
        let checkHitAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 0.05),
            SKAction.run { [weak self, weak bolt] in
                guard let self = self, let bolt = bolt else { return }
                self.checkBoltCollision(bolt: bolt, enemies: enemies)
            }
        ]))
        
        bolt.run(checkHitAction)
    }
    
    private func createBolt() -> SKShapeNode {
        // Evolved visual: Glowing yellow/blue bolt
        let bolt = SKShapeNode(rectOf: CGSize(width: 40, height: 8), cornerRadius: 4)
        bolt.fillColor = .cyan // "Storm" / Lightning look
        bolt.strokeColor = .white
        bolt.glowWidth = 3.0
        bolt.zPosition = Constants.ZPosition.projectile
        return bolt
    }
    
    private func findNearestEnemy(from position: CGPoint, enemies: [BaseEnemy]) -> BaseEnemy? {
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for enemy in enemies where enemy.isAlive {
            let distance = position.distance(to: enemy.position)
            if distance < nearestDistance {
                nearestDistance = distance
                nearest = enemy
            }
        }
        return nearest
    }
    
    private func checkBoltCollision(bolt: SKNode, enemies: [BaseEnemy]) {
        for enemy in enemies where enemy.isAlive {
            if bolt.position.distance(to: enemy.position) < 30 {
                // Hit!
                // Create explosion
                createExplosion(at: bolt.position)
                
                // Damage enemy (direct)
                enemy.takeDamage(getDamage())
                
                // Area Damage
                applyAreaDamage(at: bolt.position, radius: 100, damage: getDamage() * 0.5, enemies: enemies)
                
                // Remove bolt
                bolt.removeAllActions()
                bolt.removeFromParent()
                return // Single target hit triggers explosion
            }
        }
    }
    
    private func applyAreaDamage(at position: CGPoint, radius: CGFloat, damage: Float, enemies: [BaseEnemy]) {
        for enemy in enemies where enemy.isAlive {
            if enemy.position.distance(to: position) < radius {
                enemy.takeDamage(damage)
            }
        }
    }
    
    private func createExplosion(at position: CGPoint) {
        guard let scene = scene else { return }
        
        let explosion = SKShapeNode(circleOfRadius: 10)
        explosion.position = position
        explosion.fillColor = .white
        explosion.strokeColor = .cyan
        explosion.alpha = 0.8
        explosion.zPosition = Constants.ZPosition.projectile + 1
        scene.addChild(explosion)
        
        explosion.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 5.0, duration: 0.2),
                SKAction.fadeOut(withDuration: 0.2)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
