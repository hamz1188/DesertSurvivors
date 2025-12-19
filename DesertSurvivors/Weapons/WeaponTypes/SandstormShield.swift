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

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        // Shield is always active, created once
        if shieldNode == nil {
            createShield()
        }
    }

    private func createShield() {
        guard let scene = scene else { return }

        let node = SKNode()
        node.zPosition = Constants.ZPosition.weapon
        shieldNode = node

        // Create initial segments - sand barrier style
        let segmentCount = 6 + (level - 1)
        for i in 0..<segmentCount {
            let segment = createShieldSegment()
            shieldSegments.append(segment)
            node.addChild(segment)
        }

        addChild(node)
    }

    private func createShieldSegment() -> SKShapeNode {
        // Create an arc-shaped sand barrier segment
        let container = SKShapeNode()
        container.zPosition = Constants.ZPosition.weapon

        // Main barrier - curved sand wall
        let barrierPath = CGMutablePath()
        barrierPath.move(to: CGPoint(x: -20, y: -6))
        barrierPath.addQuadCurve(to: CGPoint(x: 20, y: -6), control: CGPoint(x: 0, y: 6))
        barrierPath.addLine(to: CGPoint(x: 18, y: -10))
        barrierPath.addQuadCurve(to: CGPoint(x: -18, y: -10), control: CGPoint(x: 0, y: 2))
        barrierPath.closeSubpath()

        let barrier = SKShapeNode(path: barrierPath)
        barrier.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.5, alpha: 0.8)
        barrier.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.35, alpha: 1.0)
        barrier.lineWidth = 1.5
        container.addChild(barrier)

        // Inner sand texture lines
        for offset in [-8, 0, 8] {
            let line = SKShapeNode(rectOf: CGSize(width: 2, height: 8))
            line.fillColor = SKColor(red: 0.75, green: 0.65, blue: 0.4, alpha: 0.5)
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(offset), y: -4)
            container.addChild(line)
        }

        // Swirling sand particles on top
        let particles = SKEmitterNode()
        particles.particleBirthRate = 15
        particles.particleLifetime = 0.5
        particles.particlePositionRange = CGVector(dx: 30, dy: 5)
        particles.particleSpeed = 20
        particles.particleSpeedRange = 10
        particles.emissionAngle = .pi / 2
        particles.emissionAngleRange = 1.0
        particles.particleAlpha = 0.4
        particles.particleAlphaSpeed = -0.8
        particles.particleScale = 0.08
        particles.particleScaleSpeed = -0.1
        particles.particleColor = SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
        particles.particleColorBlendFactor = 1.0
        particles.position = CGPoint(x: 0, y: 0)
        container.addChild(particles)

        return container
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
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

        // Check collisions with enemies using spatial hash
        checkShieldCollisions(playerPosition: playerPosition, spatialHash: spatialHash)
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

    private func checkShieldCollisions(playerPosition: CGPoint, spatialHash: SpatialHash) {
        let nearbyNodes = spatialHash.query(near: playerPosition, radius: shieldRadius + 30)
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
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

        // Level-based upgrades
        // Level 1: 6 segments, 70 radius, 2.0 speed
        // Level 2: 7 segments, 80 radius, 2.3 speed
        // Level 3: 8 segments, 90 radius, 2.6 speed
        // Level 4: 9 segments, 100 radius, 2.9 speed
        // Level 5: 10 segments, 110 radius, 3.2 speed
        // Level 6: 11 segments, 120 radius, 3.5 speed
        // Level 7: 12 segments, 130 radius, 3.8 speed
        // Level 8: 13 segments, 140 radius, 4.1 speed

        shieldRadius = 70 + CGFloat(level - 1) * 10
        orbitSpeed = 2.0 + CGFloat(level - 1) * 0.3

        // Add more shield segments at higher levels
        let targetSegmentCount = 6 + (level - 1)
        while shieldSegments.count < targetSegmentCount && shieldSegments.count < 13 {
            let segment = createShieldSegment()
            shieldSegments.append(segment)
            shieldNode?.addChild(segment)
        }
    }
}
