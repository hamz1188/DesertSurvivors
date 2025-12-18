//
//  SandBolt.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SandBolt: BaseWeapon {
    private var activeProjectiles: [Projectile] = []
    private var projectileSpeed: CGFloat = 300
    
    init() {
        super.init(name: "Sand Bolt", baseDamage: 15, cooldown: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Find nearest enemy
        guard let nearestEnemy = findNearestEnemy(from: playerPosition, enemies: enemies) else {
            return
        }
        
        // Fire projectile at nearest enemy
        let direction = (nearestEnemy.position - playerPosition).normalized()
        let projectile = Projectile(
            damage: getDamage(),
            speed: projectileSpeed,
            direction: direction,
            color: .brown
        )
        
        projectile.position = playerPosition
        scene.addChild(projectile)
        activeProjectiles.append(projectile)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        // Update active projectiles
        activeProjectiles.removeAll { projectile in
            projectile.update(deltaTime: deltaTime)
            
            // Check collision
            if let hitEnemy = projectile.checkCollision(with: enemies) {
                projectile.removeFromParent()
                return true
            }
            
            // Remove if out of bounds or lifetime expired
            if projectile.parent == nil {
                return true
            }
            
            return false
        }
    }
    
    private func findNearestEnemy(from position: CGPoint, enemies: [BaseEnemy]) -> BaseEnemy? {
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for enemy in enemies {
            let distance = position.distance(to: enemy.position)
            if distance < nearestDistance {
                nearestDistance = distance
                nearest = enemy
            }
        }
        
        return nearest
    }
    
    override func upgrade() {
        super.upgrade()
        
        // Increase projectile count and speed
        projectileSpeed = 300 + CGFloat(level - 1) * 50
    }
}

