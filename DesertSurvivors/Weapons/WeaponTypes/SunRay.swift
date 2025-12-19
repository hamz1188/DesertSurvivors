//
//  SunRay.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SunRay: BaseWeapon {
    private var activeBeams: [SKNode] = []
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

        let beamContainer = SKNode()
        beamContainer.position = playerPosition
        beamContainer.zRotation = angle
        beamContainer.zPosition = Constants.ZPosition.projectile

        // Outer glow (largest, most transparent)
        let outerGlow = SKShapeNode(rectOf: CGSize(width: beamLength, height: beamWidth + 20), cornerRadius: (beamWidth + 20) / 2)
        outerGlow.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 0.15)
        outerGlow.strokeColor = .clear
        outerGlow.position = CGPoint(x: beamLength / 2, y: 0)
        beamContainer.addChild(outerGlow)

        // Middle glow
        let middleGlow = SKShapeNode(rectOf: CGSize(width: beamLength, height: beamWidth + 8), cornerRadius: (beamWidth + 8) / 2)
        middleGlow.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.3)
        middleGlow.strokeColor = .clear
        middleGlow.position = CGPoint(x: beamLength / 2, y: 0)
        beamContainer.addChild(middleGlow)

        // Core beam (brightest)
        let coreBeam = SKShapeNode(rectOf: CGSize(width: beamLength, height: beamWidth), cornerRadius: beamWidth / 2)
        coreBeam.fillColor = SKColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 0.9)
        coreBeam.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        coreBeam.lineWidth = 2
        coreBeam.position = CGPoint(x: beamLength / 2, y: 0)
        beamContainer.addChild(coreBeam)

        // Inner white-hot center
        let innerCore = SKShapeNode(rectOf: CGSize(width: beamLength * 0.95, height: beamWidth * 0.4), cornerRadius: beamWidth * 0.2)
        innerCore.fillColor = .white
        innerCore.strokeColor = .clear
        innerCore.alpha = 0.8
        innerCore.position = CGPoint(x: beamLength / 2, y: 0)
        beamContainer.addChild(innerCore)

        // Sun symbol at origin
        let sunCircle = SKShapeNode(circleOfRadius: beamWidth * 0.8)
        sunCircle.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 0.9)
        sunCircle.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 1.0)
        sunCircle.lineWidth = 2
        beamContainer.addChild(sunCircle)

        // Sun rays around origin
        for i in 0..<8 {
            let rayAngle = CGFloat(i) * .pi / 4
            let ray = SKShapeNode(rectOf: CGSize(width: 3, height: 12))
            ray.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 0.7)
            ray.strokeColor = .clear
            ray.position = CGPoint(x: cos(rayAngle) * (beamWidth * 0.8 + 8), y: sin(rayAngle) * (beamWidth * 0.8 + 8))
            ray.zRotation = rayAngle
            beamContainer.addChild(ray)
        }

        // Heat shimmer particles along beam
        let shimmer = SKEmitterNode()
        shimmer.particleBirthRate = 50
        shimmer.particleLifetime = 0.4
        shimmer.particlePositionRange = CGVector(dx: beamLength, dy: beamWidth)
        shimmer.particleSpeed = 30
        shimmer.particleSpeedRange = 20
        shimmer.emissionAngle = .pi / 2
        shimmer.emissionAngleRange = .pi
        shimmer.particleAlpha = 0.4
        shimmer.particleAlphaSpeed = -1.0
        shimmer.particleScale = 0.1
        shimmer.particleScaleSpeed = -0.2
        shimmer.particleColor = SKColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 1.0)
        shimmer.particleColorBlendFactor = 1.0
        shimmer.position = CGPoint(x: beamLength / 2, y: 0)
        beamContainer.addChild(shimmer)

        // Flickering animation
        let flickerOut = SKAction.fadeAlpha(to: 0.6, duration: 0.03)
        let flickerIn = SKAction.fadeAlpha(to: 1.0, duration: 0.03)
        let flicker = SKAction.repeatForever(SKAction.sequence([flickerOut, flickerIn]))
        coreBeam.run(flicker)
        innerCore.run(flicker)

        scene.addChild(beamContainer)
        activeBeams.append(beamContainer)
        
        // Damage enemies in beam path using spatial hash
        damageEnemiesInBeam(playerPosition: playerPosition, direction: direction, spatialHash: spatialHash)
        
        // Remove beam after duration
        beamContainer.run(SKAction.sequence([
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

