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
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Find nearest enemy
        guard let nearestEnemy = findNearestEnemy(from: playerPosition, enemies: enemies) else {
            return
        }
        
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
        
        scene.addChild(beam)
        activeBeams.append(beam)
        
        // Damage enemies in beam path
        damageEnemiesInBeam(beam: beam, enemies: enemies, playerPosition: playerPosition, direction: direction)
        
        // Remove beam after duration
        beam.run(SKAction.sequence([
            SKAction.wait(forDuration: beamDuration),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        // Clean up removed beams
        activeBeams.removeAll { $0.parent == nil }
    }
    
    private func damageEnemiesInBeam(beam: SKShapeNode, enemies: [BaseEnemy], playerPosition: CGPoint, direction: CGPoint) {
        for enemy in enemies {
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
        
        // Increase beam width and length
        beamWidth = 20 + CGFloat(level - 1) * 5
        beamLength = 400 + CGFloat(level - 1) * 50
        beamDuration = 0.5 + Double(level - 1) * 0.1
    }
}

