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
        // Arabian-style curved dagger (Jambiya/Khanjar inspired)
        let container = SKSpriteNode(color: .clear, size: CGSize(width: 30, height: 14))

        // Main curved blade - scimitar style
        let bladePath = CGMutablePath()
        // Start at the base of the blade
        bladePath.move(to: CGPoint(x: -6, y: 2))
        // Top edge - sweeping curve
        bladePath.addQuadCurve(to: CGPoint(x: 16, y: 3), control: CGPoint(x: 6, y: 8))
        // Tip - sharp point
        bladePath.addLine(to: CGPoint(x: 18, y: 0))
        // Bottom edge - less curved
        bladePath.addQuadCurve(to: CGPoint(x: -6, y: -2), control: CGPoint(x: 6, y: 0))
        bladePath.closeSubpath()

        let blade = SKShapeNode(path: bladePath)
        blade.fillColor = SKColor(red: 0.75, green: 0.78, blue: 0.82, alpha: 1.0) // Steel color
        blade.strokeColor = SKColor(red: 0.9, green: 0.92, blue: 0.95, alpha: 1.0) // Bright edge
        blade.lineWidth = 1
        container.addChild(blade)

        // Blade edge highlight (sharp edge gleam)
        let edgePath = CGMutablePath()
        edgePath.move(to: CGPoint(x: -4, y: 2))
        edgePath.addQuadCurve(to: CGPoint(x: 17, y: 2), control: CGPoint(x: 6, y: 7))
        let edge = SKShapeNode(path: edgePath)
        edge.strokeColor = SKColor.white.withAlphaComponent(0.7)
        edge.lineWidth = 1
        container.addChild(edge)

        // Fuller (blood groove) - decorative line on blade
        let fullerPath = CGMutablePath()
        fullerPath.move(to: CGPoint(x: -2, y: 0))
        fullerPath.addQuadCurve(to: CGPoint(x: 12, y: 1), control: CGPoint(x: 5, y: 3))
        let fuller = SKShapeNode(path: fullerPath)
        fuller.strokeColor = SKColor(red: 0.6, green: 0.62, blue: 0.65, alpha: 0.6)
        fuller.lineWidth = 1.5
        container.addChild(fuller)

        // Crossguard - ornate curved
        let guardPath = CGMutablePath()
        guardPath.move(to: CGPoint(x: -6, y: -6))
        guardPath.addQuadCurve(to: CGPoint(x: -6, y: 6), control: CGPoint(x: -10, y: 0))
        guardPath.addLine(to: CGPoint(x: -5, y: 5))
        guardPath.addQuadCurve(to: CGPoint(x: -5, y: -5), control: CGPoint(x: -8, y: 0))
        guardPath.closeSubpath()

        let guard_ = SKShapeNode(path: guardPath)
        guard_.fillColor = SKColor(red: 0.85, green: 0.7, blue: 0.25, alpha: 1.0) // Gold/brass
        guard_.strokeColor = SKColor(red: 0.7, green: 0.55, blue: 0.15, alpha: 1.0)
        guard_.lineWidth = 0.5
        container.addChild(guard_)

        // Handle - wrapped grip
        let handlePath = CGMutablePath()
        handlePath.move(to: CGPoint(x: -7, y: 3))
        handlePath.addLine(to: CGPoint(x: -14, y: 2))
        handlePath.addLine(to: CGPoint(x: -14, y: -2))
        handlePath.addLine(to: CGPoint(x: -7, y: -3))
        handlePath.closeSubpath()

        let handle = SKShapeNode(path: handlePath)
        handle.fillColor = SKColor(red: 0.35, green: 0.2, blue: 0.1, alpha: 1.0) // Dark wood
        handle.strokeColor = SKColor(red: 0.25, green: 0.15, blue: 0.05, alpha: 1.0)
        handle.lineWidth = 0.5
        container.addChild(handle)

        // Handle wrapping lines
        for i in 0..<3 {
            let wrapX = CGFloat(-9 - i * 2)
            let wrap = SKShapeNode(rectOf: CGSize(width: 1, height: 5))
            wrap.fillColor = SKColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1.0)
            wrap.strokeColor = .clear
            wrap.position = CGPoint(x: wrapX, y: 0)
            container.addChild(wrap)
        }

        // Pommel - decorative end
        let pommel = SKShapeNode(circleOfRadius: 3)
        pommel.fillColor = SKColor(red: 0.85, green: 0.7, blue: 0.25, alpha: 1.0)
        pommel.strokeColor = SKColor(red: 0.7, green: 0.55, blue: 0.15, alpha: 1.0)
        pommel.lineWidth = 0.5
        pommel.position = CGPoint(x: -15, y: 0)
        container.addChild(pommel)

        // Gem in pommel
        let gem = SKShapeNode(circleOfRadius: 1.5)
        gem.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // Ruby
        gem.strokeColor = .white
        gem.lineWidth = 0.3
        gem.position = CGPoint(x: -15, y: 0)
        container.addChild(gem)

        return container
    }
    
    private func addDaggerTrail(to dagger: SKNode) {
        // Metallic slash trail effect
        let trail = SKEmitterNode()
        trail.particleTexture = nil
        trail.particleBirthRate = 60
        trail.particleLifetime = 0.25
        trail.particlePositionRange = CGVector(dx: 3, dy: 3)
        trail.particleSpeed = 15
        trail.particleSpeedRange = 8
        trail.emissionAngle = .pi
        trail.emissionAngleRange = 0.4
        trail.particleAlpha = 0.7
        trail.particleAlphaSpeed = -2.8
        trail.particleScale = 0.12
        trail.particleScaleSpeed = -0.4
        trail.particleColor = SKColor(red: 0.85, green: 0.88, blue: 0.92, alpha: 1.0) // Steel color
        trail.particleColorBlendFactor = 1.0
        trail.targetNode = self.scene
        trail.position = CGPoint(x: 10, y: 0) // Trail from blade tip

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
        
        for enemy in enemies where enemy.isAlive {
            let enemyId = ObjectIdentifier(enemy)
            
            // Skip if enemy was hit recently
            if hitCooldowns[enemyId] != nil {
                continue
            }
            
            // Calculate enemy position relative to player
            let toEnemy = enemy.position - playerPosition
            let enemyDistance = toEnemy.length()
            
            // Check if enemy is within orbit range (including a bit inside and outside)
            let innerRadius = max(0, orbitRadius - hitWidth)
            let outerRadius = orbitRadius + hitWidth
            
            if enemyDistance >= innerRadius && enemyDistance <= outerRadius {
                // Enemy is at the right distance - check angle
                let enemyAngle = atan2(toEnemy.y, toEnemy.x)
                
                // Check if dagger swept through enemy's angle
                if isAngleInSweep(angle: enemyAngle, from: previousAngle, to: daggerAngle) {
                    enemy.takeDamage(getDamage())
                    hitCooldowns[enemyId] = hitCooldownDuration
                }
            }
            // Also check enemies INSIDE the orbit (closer to player)
            else if enemyDistance < innerRadius && enemyDistance > 15 { // Not too close (player collision)
                // For enemies inside orbit, check if dagger passed their angle
                let enemyAngle = atan2(toEnemy.y, toEnemy.x)
                
                // Use wider angle tolerance for inner enemies
                if isAngleInSweep(angle: enemyAngle, from: previousAngle, to: daggerAngle, tolerance: 0.3) {
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

