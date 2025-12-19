//
//  SunRay.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SunRay: BaseWeapon {
    private var activeBeams: [SKShapeNode] = []
    private var beamDuration: TimeInterval = 0.5
    private var beamWidth: CGFloat = 20
    private var beamLength: CGFloat = 400
    
    init() {
        super.init(name: "Sun Ray", baseDamage: 8, cooldown: 2.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Find nearest enemy using spatial hash query
        let nearbyNodes = spatialHash.query(near: playerPosition, radius: 500)
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            let distance = playerPosition.distance(to: enemy.position)
            if distance < nearestDistance {
                nearestDistance = distance
                nearest = enemy
            }
        }
        
        guard let nearestEnemy = nearest else { return }
        
        // Create beam
        let direction = (nearestEnemy.position - playerPosition).normalized()
        let angle = atan2(direction.y, direction.x)
        
        let beam = SKShapeNode(rectOf: CGSize(width: beamLength, height: beamWidth))
        beam.fillColor = .yellow
        beam.strokeColor = .orange
        beam.lineWidth = 2
        beam.zPosition = Constants.ZPosition.projectile
        beam.position = playerPosition
        beam.zRotation = angle
        beam.alpha = 0.8
        
        // Add Glow effect
        let glow = SKShapeNode(rectOf: CGSize(width: beamLength, height: beamWidth + 10))
        glow.fillColor = .yellow.withAlphaComponent(0.2)
        glow.strokeColor = .clear
        glow.zPosition = -1
        beam.addChild(glow)
        
        // Add flickering animation
        let flickerOut = SKAction.fadeAlpha(to: 0.4, duration: 0.05)
        let flickerIn = SKAction.fadeAlpha(to: 0.8, duration: 0.05)
        let flicker = SKAction.repeatForever(SKAction.sequence([flickerOut, flickerIn]))
        beam.run(flicker)
        
        scene.addChild(beam)
        activeBeams.append(beam)
        
        // Damage enemies in beam path using spatial hash
        damageEnemiesInBeam(playerPosition: playerPosition, direction: direction, spatialHash: spatialHash)
        
        // Remove beam after duration
        beam.run(SKAction.sequence([
            SKAction.wait(forDuration: beamDuration),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        // Clean up removed beams
        activeBeams.removeAll { $0.parent == nil }
    }
    
    private func damageEnemiesInBeam(playerPosition: CGPoint, direction: CGPoint, spatialHash: SpatialHash) {
        // Query enemies along the beam length
        let beamNodes = spatialHash.query(near: playerPosition, radius: beamLength)
        
        for node in beamNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            
            let toEnemy = (enemy.position - playerPosition).normalized()
            let dotProduct = direction.x * toEnemy.x + direction.y * toEnemy.y
            
            // Check if enemy is in front of player (dot product > 0.7 means roughly same direction)
            if dotProduct > 0.7 {
                let distance = playerPosition.distance(to: enemy.position)
                if distance <= beamLength {
                    enemy.takeDamage(getDamage())
                }
            }
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

        // Level-based upgrades
        // Level 1: 20 width, 400 length, 0.5s duration
        // Level 2: 25 width, 450 length, 0.6s duration
        // Level 3: 30 width, 500 length, 0.7s duration
        // Level 4: 35 width, 550 length, 0.8s duration
        // Level 5: 40 width, 600 length, 0.9s duration
        // Level 6: 45 width, 650 length, 1.0s duration
        // Level 7: 50 width, 700 length, 1.1s duration
        // Level 8: 55 width, 750 length, 1.2s duration

        beamWidth = 20 + CGFloat(level - 1) * 5
        beamLength = 400 + CGFloat(level - 1) * 50
        beamDuration = 0.5 + Double(level - 1) * 0.1
    }
}

