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
        let dagger = SKSpriteNode(color: .orange, size: CGSize(width: 20, height: 8))
        dagger.zPosition = Constants.ZPosition.weapon
        daggers.append(dagger)
        addChild(dagger)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // Don't call super.update for orbiting weapons - they work continuously
        previousAngle = currentAngle
        currentAngle += orbitSpeed * CGFloat(deltaTime)
        
        // Update hit cooldowns
        updateHitCooldowns(deltaTime: deltaTime)
        
        // Pre-filter enemies to only those within orbit range (performance optimization)
        // Only check enemies within orbit radius + margin (50 units)
        let maxCheckDistance = orbitRadius + 50
        let nearbyEnemies = enemies.filter { enemy in
            enemy.isAlive && enemy.position.distance(to: playerPosition) < maxCheckDistance
        }
        
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
                enemies: nearbyEnemies  // Only check nearby enemies
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
                dagger.color = .orange.withAlphaComponent(0.9)
                dagger.setScale(1.2)
            }
        }
        if level >= 8 {
            for dagger in daggers {
                dagger.color = .red
                dagger.setScale(1.5)
            }
        }
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Daggers orbit continuously, collision is checked in update
    }
}

