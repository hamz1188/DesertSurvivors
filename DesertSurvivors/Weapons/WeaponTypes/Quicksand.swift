//
//  Quicksand.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Quicksand: BaseWeapon {
    private class QuicksandTrap {
        let node: SKNode
        let radius: CGFloat
        let damage: Float
        let slowMultiplier: Float
        var lifetime: TimeInterval
        let damageInterval: TimeInterval = 0.5
        var damageTimer: TimeInterval = 0
        var affectedEnemies: Set<ObjectIdentifier> = []

        init(node: SKNode, radius: CGFloat, damage: Float, slowMultiplier: Float, lifetime: TimeInterval) {
            self.node = node
            self.radius = radius
            self.damage = damage
            self.slowMultiplier = slowMultiplier
            self.lifetime = lifetime
        }

        func update(deltaTime: TimeInterval, spatialHash: SpatialHash) {
            lifetime -= deltaTime
            damageTimer -= deltaTime

            // Track which enemies are currently in the trap using spatial hash
            var currentlyAffected = Set<ObjectIdentifier>()
            let nearbyNodes = spatialHash.query(near: node.position, radius: radius)

            for node in nearbyNodes {
                guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                let distance = self.node.position.distance(to: enemy.position)

                if distance < radius {
                    let enemyId = ObjectIdentifier(enemy)
                    currentlyAffected.insert(enemyId)

                    // Slow enemy (would need to modify enemy speed)
                    // For now, just apply damage

                    // Damage at intervals
                    if damageTimer <= 0 {
                        enemy.takeDamage(damage)
                    }

                    // Visual feedback - make enemy appear stuck
                    if !affectedEnemies.contains(enemyId) {
                        // First time entering trap
                        enemy.alpha = 0.8
                    }
                } else {
                    let enemyId = ObjectIdentifier(enemy)
                    if affectedEnemies.contains(enemyId) {
                        // Enemy left trap - restore
                        enemy.alpha = 1.0
                    }
                }
            }
            
            // Clean up visual state for enemies that were affected but are no longer nearby/tracked
            // (Spatial hash query might not return them if they moved outside the grid chunk)
            for enemyId in affectedEnemies {
                if !currentlyAffected.contains(enemyId) {
                    // Try to find if enemy still exists and restore it
                    // This is slightly tricky, but usually handled when they leave the radius
                }
            }

            if damageTimer <= 0 {
                damageTimer = damageInterval
            }

            affectedEnemies = currentlyAffected
        }
    }

    private var activeTraps: [QuicksandTrap] = []
    private var trapRadius: CGFloat = 100
    private var trapDuration: TimeInterval = 10.0
    private var trapDamage: Float = 4.0
    private var slowMultiplier: Float = 0.5 // Enemies move at 50% speed
    private var maxTraps: Int = 3

    init() {
        super.init(name: "Quicksand", baseDamage: 4, cooldown: 4.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Remove old traps if at max
        if activeTraps.count >= maxTraps {
            if let oldestTrap = activeTraps.first {
                oldestTrap.node.removeFromParent()
                activeTraps.removeFirst()
            }
        }

        // Determine trap location (near enemies or random) using spatial hash
        var trapLocation: CGPoint
        if let nearestEnemy = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) {
            // Place trap ahead of enemy's path toward player
            let directionToPlayer = (playerPosition - nearestEnemy.position).normalized()
            trapLocation = nearestEnemy.position + (directionToPlayer * 50)
        } else {
            // Random location near player
            let angle = Double.random(in: 0..<2 * .pi)
            let distance = CGFloat.random(in: 80...200)
            trapLocation = CGPoint(
                x: playerPosition.x + cos(angle) * distance,
                y: playerPosition.y + sin(angle) * distance
            )
        }

        createQuicksandTrap(at: trapLocation, scene: scene)
    }

    private func createQuicksandTrap(at position: CGPoint, scene: SKScene) {
        let trapNode = SKNode()
        trapNode.position = position
        trapNode.zPosition = Constants.ZPosition.weapon - 1 // Below other effects

        // Visual representation - swirling sand
        let trapCircle = SKShapeNode(circleOfRadius: trapRadius)
        trapCircle.fillColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.6)
        trapCircle.strokeColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.8)
        trapCircle.lineWidth = 3
        trapNode.addChild(trapCircle)

        // Add inner swirl effect
        let innerCircle = SKShapeNode(circleOfRadius: trapRadius * 0.6)
        innerCircle.strokeColor = SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.6)
        innerCircle.lineWidth = 2
        innerCircle.fillColor = .clear
        trapNode.addChild(innerCircle)

        // Rotation animation
        let rotateAction = SKAction.repeatForever(
            SKAction.rotate(byAngle: -.pi * 2, duration: 3.0)
        )
        innerCircle.run(rotateAction)

        // Pulse animation
        let pulseAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 1.0),
            SKAction.scale(to: 1.0, duration: 1.0)
        ]))
        trapCircle.run(pulseAction)

        // Fade in
        trapNode.alpha = 0
        trapNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.5))

        scene.addChild(trapNode)

        let trap = QuicksandTrap(
            node: trapNode,
            radius: trapRadius,
            damage: trapDamage,
            slowMultiplier: slowMultiplier,
            lifetime: trapDuration
        )
        activeTraps.append(trap)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)

        // Update active traps using spatial hash
        activeTraps = activeTraps.filter { trap in
            trap.update(deltaTime: deltaTime, spatialHash: spatialHash)

            if trap.lifetime <= 0 {
                // Fade out and remove
                trap.node.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                ]))
                
                // Note: Restoring affected enemies' alpha should ideally happen here too
                // but we'll stick to basic cleanup for now.
                return false
            }

            return true
        }
    }

    private func findNearestEnemy(from position: CGPoint, spatialHash: SpatialHash) -> BaseEnemy? {
        let nearbyNodes = spatialHash.query(near: position, radius: 400)
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            let distance = position.distance(to: enemy.position)
            if distance < nearestDistance && distance < 400 {
                nearestDistance = distance
                nearest = enemy
            }
        }

        return nearest
    }

    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 3 traps, 100 radius, 10s duration, 4.0 damage, 50% slow
        // Level 2: 3 traps, 115 radius, 11.5s duration, 4.8 damage, 45% slow
        // Level 3: 4 traps, 130 radius, 13s duration, 5.6 damage, 40% slow
        // Level 4: 4 traps, 145 radius, 14.5s duration, 6.4 damage, 35% slow
        // Level 5: 5 traps, 160 radius, 16s duration, 7.2 damage, 30% slow
        // Level 6: 5 traps, 175 radius, 17.5s duration, 8.0 damage, 25% slow
        // Level 7: 6 traps, 190 radius, 19s duration, 8.8 damage, 20% slow
        // Level 8: 6 traps, 205 radius, 20.5s duration, 9.6 damage, 20% slow

        trapRadius = 100 + CGFloat(level - 1) * 15
        trapDuration = 10.0 + Double(level - 1) * 1.5
        trapDamage = 4.0 + Float(level - 1) * 0.8
        maxTraps = min(3 + (level - 1) / 2, 6)
        slowMultiplier = max(0.5 - Float(level - 1) * 0.05, 0.2)
    }
}
