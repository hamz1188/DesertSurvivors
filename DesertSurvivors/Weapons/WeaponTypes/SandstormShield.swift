//
//  SandstormShield.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SandstormShield: BaseWeapon {
    private var shieldNode: SKNode?
    private var shieldRadius: CGFloat = 70
    private var orbitSpeed: CGFloat = 2.0
    private var currentAngle: CGFloat = 0
    private var shieldSegments: [SKShapeNode] = []
    private var damageInterval: TimeInterval = 0.3
    private var hitCooldowns: [ObjectIdentifier: TimeInterval] = [:]

    init() {
        super.init(name: "Sandstorm Shield", baseDamage: 8, cooldown: 0.1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Shield is always active, created once
        if shieldNode == nil {
            createShield()
        }
    }

    private func createShield() {
        guard let scene = scene else { return }

        let container = SKNode()
        container.zPosition = Constants.ZPosition.weapon
        scene.addChild(container)
        shieldNode = container

        // Create shield segments (rotating barrier pieces)
        let segmentCount = 6
        for i in 0..<segmentCount {
            let segment = SKShapeNode(rectOf: CGSize(width: 40, height: 15), cornerRadius: 5)
            segment.fillColor = SKColor.yellow.withAlphaComponent(0.6)
            segment.strokeColor = .orange
            segment.lineWidth = 2
            segment.zPosition = Constants.ZPosition.weapon

            shieldSegments.append(segment)
            container.addChild(segment)
        }

        addChild(container)
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // Don't call super.update - shield is always active
        currentAngle += orbitSpeed * CGFloat(deltaTime)

        // Update hit cooldowns
        updateHitCooldowns(deltaTime: deltaTime)

        // Update shield segment positions
        guard let shield = shieldNode else { return }
        shield.position = CGPoint.zero // Relative to player (weapon is child of player)

        let segmentCount = shieldSegments.count
        for (index, segment) in shieldSegments.enumerated() {
            let segmentAngle = currentAngle + (CGFloat(index) * 2 * .pi / CGFloat(segmentCount))
            let x = cos(segmentAngle) * shieldRadius
            let y = sin(segmentAngle) * shieldRadius
            segment.position = CGPoint(x: x, y: y)
            segment.zRotation = segmentAngle + .pi / 2
        }

        // Check collisions with enemies
        checkShieldCollisions(playerPosition: playerPosition, enemies: enemies)
    }

    private func updateHitCooldowns(deltaTime: TimeInterval) {
        for (key, value) in hitCooldowns {
            let newValue = value - deltaTime
            if newValue <= 0 {
                hitCooldowns.removeValue(forKey: key)
            } else {
                hitCooldowns[key] = newValue
            }
        }
    }

    private func checkShieldCollisions(playerPosition: CGPoint, enemies: [BaseEnemy]) {
        for enemy in enemies where enemy.isAlive {
            let enemyId = ObjectIdentifier(enemy)

            // Skip if enemy was hit recently
            if hitCooldowns[enemyId] != nil {
                continue
            }

            // Check if enemy is within shield radius
            let distance = playerPosition.distance(to: enemy.position)
            let hitRange = shieldRadius + 20 // Add some tolerance

            if distance < hitRange && distance > shieldRadius - 30 {
                // Enemy is in shield range
                enemy.takeDamage(getDamage())
                hitCooldowns[enemyId] = damageInterval

                // Flash effect on shield
                for segment in shieldSegments {
                    segment.run(SKAction.sequence([
                        SKAction.fadeAlpha(to: 1.0, duration: 0.05),
                        SKAction.fadeAlpha(to: 0.6, duration: 0.1)
                    ]))
                }

                // Knockback effect
                let knockbackDirection = (enemy.position - playerPosition).normalized()
                let knockbackForce: CGFloat = 50
                let knockbackMovement = knockbackDirection * knockbackForce
                enemy.position = enemy.position + knockbackMovement
            }
        }
    }

    override func upgrade() {
        super.upgrade()

        // Increase shield radius and add more segments
        shieldRadius = 70 + CGFloat(level - 1) * 10
        orbitSpeed = 2.0 + CGFloat(level - 1) * 0.3

        // Add more shield segments at higher levels
        if level > 1 && shieldSegments.count < 12 {
            let newSegmentCount = 6 + (level - 1)
            while shieldSegments.count < newSegmentCount {
                let segment = SKShapeNode(rectOf: CGSize(width: 40, height: 15), cornerRadius: 5)
                segment.fillColor = SKColor.yellow.withAlphaComponent(0.6)
                segment.strokeColor = .orange
                segment.lineWidth = 2
                segment.zPosition = Constants.ZPosition.weapon

                shieldSegments.append(segment)
                shieldNode?.addChild(segment)
            }
        }
    }
}
