//
//  CurvedDagger.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class CurvedDagger: BaseWeapon {
    private var daggers: [SKSpriteNode] = []
    private var orbitRadius: CGFloat = 60
    private var orbitSpeed: CGFloat = 3.0 // radians per second
    private var currentAngle: CGFloat = 0
    private var previousAngle: CGFloat = 0
    
    // Track which enemies have been hit recently to prevent spam
    private var hitCooldowns: [ObjectIdentifier: TimeInterval] = [:]
    private let hitCooldownDuration: TimeInterval = 0.3 // Can hit same enemy again after 0.3s
    
    init() {
        super.init(name: "Curved Dagger", baseDamage: 10, cooldown: 1.5)
        setupDaggers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDaggers() {
        // Start with 1 dagger, more will be added on level up
        createDagger()
    }
    
    private func createDagger() {
        let dagger = createDaggerShape()
        dagger.zPosition = Constants.ZPosition.weapon
        daggers.append(dagger)
        addChild(dagger)
        
        // Add trail effect
        addDaggerTrail(to: dagger)
    }
    
    private func createDaggerShape() -> SKSpriteNode {
        // We'll use multiple nodes to construct a dagger for "texture" feel
        // but package them in a single node for easy rotation.
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 25, height: 10))
        
        // Blade (Curved)
        let bladePath = CGMutablePath()
        bladePath.move(to: CGPoint(x: -8, y: 0))
        bladePath.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 2, y: 5))
        bladePath.addQuadCurve(to: CGPoint(x: -8, y: -2), control: CGPoint(x: 2, y: 2))
        bladePath.closeSubpath()
        
        let blade = SKShapeNode(path: bladePath)
        blade.fillColor = .lightGray
        blade.strokeColor = .white
        blade.lineWidth = 1
        container.addChild(blade)
        
        // Hilt / Crossguard
        let hilt = SKShapeNode(rectOf: CGSize(width: 3, height: 12), cornerRadius: 1)
        hilt.fillColor = SKColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0)
        hilt.strokeColor = .black
        hilt.lineWidth = 0.5
        hilt.position = CGPoint(x: -8, y: 0)
        container.addChild(hilt)
        
        // Grip
        let grip = SKShapeNode(rectOf: CGSize(width: 6, height: 3), cornerRadius: 1)
        grip.fillColor = .brown
        grip.position = CGPoint(x: -12, y: 0)
        container.addChild(grip)
        
        return container
    }
    
    private func addDaggerTrail(to dagger: SKNode) {
        // Simple trail using a particle system template
        let trail = SKEmitterNode()
        trail.particleTexture = nil // Use squares if no texture
        trail.particleBirthRate = 50
        trail.particleLifetime = 0.3
        trail.particlePositionRange = CGVector(dx: 2, dy: 2)
        trail.particleSpeed = 20
        trail.particleSpeedRange = 10
        trail.emissionAngle = .pi // Emit backwards
         trail.emissionAngleRange = 0.5
        trail.particleAlpha = 0.6
        trail.particleAlphaSpeed = -2.0
        trail.particleScale = 0.1
        trail.particleScaleSpeed = -0.3
        trail.particleColor = .lightGray
        trail.particleColorBlendFactor = 1.0
        trail.targetNode = self.scene // Particles stay in world space
        
        dagger.addChild(trail)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        // Don't call super.update for orbiting weapons - they work continuously
        previousAngle = currentAngle
        currentAngle += orbitSpeed * CGFloat(deltaTime)
        
        // Update hit cooldowns
        updateHitCooldowns(deltaTime: deltaTime)
        
        // Pre-filter enemies using spatial hash grid (performance optimization)
        let maxCheckDistance = orbitRadius + 50
        let nearbyNodes = spatialHash.query(near: playerPosition, radius: maxCheckDistance)
        let nearbyEnemies = nearbyNodes.compactMap { $0 as? BaseEnemy }.filter { $0.isAlive }
        
        // Update dagger positions and check collisions
        let daggerCount = daggers.count
        for (index, dagger) in daggers.enumerated() {
            let daggerAngle = currentAngle + (CGFloat(index) * 2 * .pi / CGFloat(daggerCount))
            let previousDaggerAngle = previousAngle + (CGFloat(index) * 2 * .pi / CGFloat(daggerCount))
            
            let x = cos(daggerAngle) * orbitRadius
            let y = sin(daggerAngle) * orbitRadius
            dagger.position = CGPoint(x: x, y: y)
            dagger.zRotation = daggerAngle + .pi / 2
            
            // Check collision with nearby enemies using sweep detection
            checkDaggerSweepCollision(
                daggerAngle: daggerAngle,
                previousAngle: previousDaggerAngle,
                playerPosition: playerPosition,
                enemies: nearbyEnemies
            )
        }
    }
    
    private func updateHitCooldowns(deltaTime: TimeInterval) {
        // Decrease cooldowns and remove expired ones
        for (key, value) in hitCooldowns {
            let newValue = value - deltaTime
            if newValue <= 0 {
                hitCooldowns.removeValue(forKey: key)
            } else {
                hitCooldowns[key] = newValue
            }
        }
    }
    
    private func checkDaggerSweepCollision(daggerAngle: CGFloat, previousAngle: CGFloat, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        let hitWidth: CGFloat = 25 // Width of the dagger hit area

        // Optimized: Pre-calculate dagger directions (avoid repeated trig)
        let daggerDir = CGPoint(x: cos(daggerAngle), y: sin(daggerAngle))
        let prevDaggerDir = CGPoint(x: cos(previousAngle), y: sin(previousAngle))

        // Pre-calculate distance thresholds squared (avoid sqrt in loop)
        let innerRadius = max(0, orbitRadius - hitWidth)
        let outerRadius = orbitRadius + hitWidth
        let innerRadiusSq = innerRadius * innerRadius
        let outerRadiusSq = outerRadius * outerRadius
        let minInnerDistSq: CGFloat = 15 * 15

        for enemy in enemies where enemy.isAlive {
            let enemyId = ObjectIdentifier(enemy)

            // Skip if enemy was hit recently
            if hitCooldowns[enemyId] != nil {
                continue
            }

            // Calculate enemy position relative to player
            let toEnemy = enemy.position - playerPosition
            let enemyDistSq = toEnemy.x * toEnemy.x + toEnemy.y * toEnemy.y

            // Optimized: Check distance using squared values (no sqrt needed)
            if enemyDistSq >= innerRadiusSq && enemyDistSq <= outerRadiusSq {
                // Enemy is at the right distance - check angle using dot product
                let enemyDist = sqrt(enemyDistSq) // Only sqrt once we know it's in range
                let toEnemyNorm = CGPoint(x: toEnemy.x / enemyDist, y: toEnemy.y / enemyDist)

                // Dot product check: enemy is "close enough" to dagger direction
                // Threshold 0.94 ~= 20 degrees, 0.98 ~= 11.5 degrees
                let dotCurrent = toEnemyNorm.x * daggerDir.x + toEnemyNorm.y * daggerDir.y
                let dotPrevious = toEnemyNorm.x * prevDaggerDir.x + toEnemyNorm.y * prevDaggerDir.y

                // Hit if currently aligned OR was aligned last frame (sweep detection)
                if dotCurrent > 0.94 || dotPrevious > 0.94 {
                    enemy.takeDamage(getDamage())
                    hitCooldowns[enemyId] = hitCooldownDuration
                }
            }
            // Also check enemies INSIDE the orbit (closer to player)
            else if enemyDistSq < innerRadiusSq && enemyDistSq > minInnerDistSq {
                // For inner enemies, use wider tolerance
                let enemyDist = sqrt(enemyDistSq)
                let toEnemyNorm = CGPoint(x: toEnemy.x / enemyDist, y: toEnemy.y / enemyDist)

                let dotCurrent = toEnemyNorm.x * daggerDir.x + toEnemyNorm.y * daggerDir.y
                let dotPrevious = toEnemyNorm.x * prevDaggerDir.x + toEnemyNorm.y * prevDaggerDir.y

                // Wider tolerance for inner enemies (0.85 ~= 32 degrees)
                if dotCurrent > 0.85 || dotPrevious > 0.85 {
                    enemy.takeDamage(getDamage())
                    hitCooldowns[enemyId] = hitCooldownDuration
                }
            }
        }
    }
    
    /// Check if an angle falls within a sweep arc (handles wraparound)
    private func isAngleInSweep(angle: CGFloat, from: CGFloat, to: CGFloat, tolerance: CGFloat = 0.2) -> Bool {
        // Normalize angles to 0...2π
        let normalizedAngle = normalizeAngle(angle)
        let normalizedFrom = normalizeAngle(from)
        let normalizedTo = normalizeAngle(to)
        
        // Calculate angular distance considering direction
        let sweepAmount = normalizedTo - normalizedFrom
        
        // Check if angle is within the sweep with tolerance
        let angleDiffToStart = abs(angleDifference(normalizedAngle, normalizedFrom))
        let angleDiffToEnd = abs(angleDifference(normalizedAngle, normalizedTo))
        
        // Either close to current position OR within the sweep arc
        return angleDiffToEnd < tolerance || (angleDiffToStart < abs(sweepAmount) + tolerance && angleDiffToEnd < abs(sweepAmount) + tolerance)
    }
    
    private func normalizeAngle(_ angle: CGFloat) -> CGFloat {
        var normalized = angle.truncatingRemainder(dividingBy: 2 * .pi)
        if normalized < 0 {
            normalized += 2 * .pi
        }
        return normalized
    }
    
    private func angleDifference(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        var diff = a - b
        while diff > .pi { diff -= 2 * .pi }
        while diff < -.pi { diff += 2 * .pi }
        return diff
    }
    
    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 1 dagger, 60 radius, 3.0 speed
        // Level 2: 2 daggers, 70 radius, 3.5 speed
        // Level 3: 3 daggers, 80 radius, 4.0 speed
        // Level 4: 4 daggers, 90 radius, 4.5 speed
        // Level 5: 5 daggers, 100 radius, 5.0 speed
        // Level 6: 6 daggers, 110 radius, 5.5 speed
        // Level 7: 7 daggers, 120 radius, 6.0 speed
        // Level 8: 8 daggers, 130 radius, 6.5 speed

        // Add daggers up to level count
        while daggers.count < level {
            createDagger()
        }

        // Scale properties
        orbitRadius = 60 + CGFloat(level - 1) * 10
        orbitSpeed = 3.0 + CGFloat(level - 1) * 0.5

        // Visual enhancement at higher levels
        if level >= 5 {
            for dagger in daggers {
                if let blade = dagger.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    blade.fillColor = .orange
                }
                dagger.setScale(1.2)
            }
        }
        if level >= 8 {
            for dagger in daggers {
                if let blade = dagger.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
                    blade.fillColor = .red
                }
                dagger.setScale(1.5)
            }
        }
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        // Daggers orbit continuously, collision is checked in update
    }
}

