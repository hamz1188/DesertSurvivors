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
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Find nearest enemy using spatial hash
        guard let nearestEnemy = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) else {
            return
        }

        // Determine number of projectiles based on level
        let projectileCount = level < 4 ? 1 : level < 6 ? 2 : level < 8 ? 3 : 4

        for i in 0..<projectileCount {
            let spreadAngle: CGFloat = projectileCount > 1 ? CGFloat(i - projectileCount / 2) * 0.2 : 0
            let direction = (nearestEnemy.position - playerPosition).normalized()
            let rotatedDirection = CGPoint(
                x: direction.x * cos(spreadAngle) - direction.y * sin(spreadAngle),
                y: direction.x * sin(spreadAngle) + direction.y * cos(spreadAngle)
            )

            let projectile = PoolingManager.shared.spawnProjectile(weaponName: "SandBolt") {
                Projectile(damage: 0, speed: 0, direction: .zero)
            }
            
            projectile.configure(
                damage: getDamage(),
                speed: projectileSpeed,
                direction: rotatedDirection,
                color: level >= 5 ? .orange : .brown
            )

            projectile.position = playerPosition
            if projectile.parent == nil {
                scene.addChild(projectile)
            }
            activeProjectiles.append(projectile)
        }
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)

        // Update active projectiles
        activeProjectiles.removeAll { projectile in
            projectile.update(deltaTime: deltaTime) {
                PoolingManager.shared.despawnProjectile(projectile, weaponName: "SandBolt")
            }
            
            // Check collision using spatial hash
            if projectile.checkCollision(spatialHash: spatialHash) != nil {
                PoolingManager.shared.despawnProjectile(projectile, weaponName: "SandBolt")
                return true
            }
            
            // Remove if parent cleared (despawned)
            if projectile.parent == nil {
                return true
            }
            
            return false
        }
    }
    
    private func findNearestEnemy(from position: CGPoint, spatialHash: SpatialHash) -> BaseEnemy? {
        let nearbyNodes = spatialHash.query(near: position, radius: 500)
        
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
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

        // Level-based upgrades
        // Level 1: 1 projectile, 300 speed
        // Level 2-3: 1 projectile, faster
        // Level 4-5: 2 projectiles per attack
        // Level 6-7: 3 projectiles per attack
        // Level 8: 4 projectiles per attack

        projectileSpeed = 300 + CGFloat(level - 1) * 50
    }
}

