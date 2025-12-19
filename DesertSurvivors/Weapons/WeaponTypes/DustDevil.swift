//
//  DustDevil.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DustDevil: BaseWeapon {
    private struct DevilData {
        let node: SKNode
        var lastDamageTime: TimeInterval
    }
    
    private var activeDevils: [DevilData] = []
    private var devilRadius: CGFloat = 80
    private var devilDuration: TimeInterval = 3.0
    private var damageInterval: TimeInterval = 0.2 // Damage every 0.2 seconds
    private var gameTime: TimeInterval = 0
    
    init() {
        super.init(name: "Dust Devil", baseDamage: 5, cooldown: 4.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Create whirlwind at random location near player
        let angle = Double.random(in: 0..<2 * .pi)
        let distance = CGFloat.random(in: 100...300)
        let spawnX = playerPosition.x + cos(angle) * distance
        let spawnY = playerPosition.y + sin(angle) * distance
        
        let devil = createDustDevil(at: CGPoint(x: spawnX, y: spawnY))
        scene.addChild(devil)
        activeDevils.append(DevilData(node: devil, lastDamageTime: gameTime))
        
        // Remove after duration
        devil.run(SKAction.sequence([
            SKAction.wait(forDuration: devilDuration),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    private func createDustDevil(at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.position = position
        container.zPosition = Constants.ZPosition.weapon

        // Ground shadow/disturbance
        let groundShadow = SKShapeNode(ellipseOf: CGSize(width: devilRadius * 1.8, height: devilRadius * 0.6))
        groundShadow.fillColor = SKColor(red: 0.6, green: 0.5, blue: 0.35, alpha: 0.4)
        groundShadow.strokeColor = .clear
        groundShadow.zPosition = -1
        container.addChild(groundShadow)

        // Vortex cone - multiple layers creating depth
        let ringCount = 5
        for i in 0..<ringCount {
            let progress = CGFloat(i) / CGFloat(ringCount - 1)
            let radius = devilRadius * (0.3 + progress * 0.7)
            let yOffset = progress * devilRadius * 0.8

            // Main ring
            let ring = SKShapeNode(circleOfRadius: radius)
            ring.fillColor = .clear
            ring.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.5 - progress * 0.3)
            ring.lineWidth = 3 - progress * 2
            ring.position = CGPoint(x: 0, y: yOffset)
            ring.zPosition = CGFloat(i)

            // Add swirling dust particles around each ring
            let dustCount = 6 - i
            for j in 0..<dustCount {
                let angle = CGFloat(j) / CGFloat(dustCount) * .pi * 2
                let dustSize = CGFloat.random(in: 4...10) * (1 - progress * 0.5)

                let dust = SKShapeNode(ellipseOf: CGSize(width: dustSize * 1.5, height: dustSize))
                dust.fillColor = SKColor(red: 0.82, green: 0.72, blue: 0.52, alpha: 0.5)
                dust.strokeColor = .clear
                dust.position = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius * 0.3)
                ring.addChild(dust)
            }

            container.addChild(ring)

            // Rotation - inner rings spin faster
            let duration = 0.8 + Double(i) * 0.3
            let direction: CGFloat = i % 2 == 0 ? 1 : -1 // Alternate directions
            ring.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2 * direction, duration: duration)))
        }

        // Central funnel core
        let corePath = CGMutablePath()
        corePath.move(to: CGPoint(x: -8, y: 0))
        corePath.addQuadCurve(to: CGPoint(x: 0, y: devilRadius * 0.7), control: CGPoint(x: -15, y: devilRadius * 0.4))
        corePath.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 15, y: devilRadius * 0.4))
        corePath.closeSubpath()

        let core = SKShapeNode(path: corePath)
        core.fillColor = SKColor(red: 0.75, green: 0.65, blue: 0.45, alpha: 0.3)
        core.strokeColor = .clear
        core.zPosition = 10
        container.addChild(core)

        // Particle emitter for flying debris
        let debris = SKEmitterNode()
        debris.particleBirthRate = 30
        debris.particleLifetime = 1.5
        debris.particlePositionRange = CGVector(dx: devilRadius * 0.5, dy: 10)
        debris.particleSpeed = 80
        debris.particleSpeedRange = 40
        debris.emissionAngle = .pi / 2
        debris.emissionAngleRange = 0.5
        debris.particleAlpha = 0.6
        debris.particleAlphaSpeed = -0.4
        debris.particleScale = 0.15
        debris.particleScaleSpeed = -0.05
        debris.particleColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 1.0)
        debris.particleColorBlendFactor = 1.0
        debris.position = CGPoint(x: 0, y: 0)
        debris.zPosition = 5
        container.addChild(debris)

        return container
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        gameTime += deltaTime
        
        // Update active devils and damage enemies using spatial hash
        activeDevils = activeDevils.compactMap { devilData in
            if devilData.node.parent == nil {
                return nil
            }
            
            // Damage enemies in range at intervals
            if gameTime - devilData.lastDamageTime >= damageInterval {
                let nearbyNodes = spatialHash.query(near: devilData.node.position, radius: devilRadius)
                
                for node in nearbyNodes {
                    guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                    if devilData.node.position.distance(to: enemy.position) < devilRadius {
                        enemy.takeDamage(getDamage())
                    }
                }
                return DevilData(node: devilData.node, lastDamageTime: gameTime)
            }
            
            return devilData
        }
    }
    
    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 80 radius, 3.0s duration, 0.2s damage interval
        // Level 2: 95 radius, 3.5s duration
        // Level 3: 110 radius, 4.0s duration
        // Level 4: 125 radius, 4.5s duration, faster damage
        // Level 5: 140 radius, 5.0s duration
        // Level 6: 155 radius, 5.5s duration
        // Level 7: 170 radius, 6.0s duration
        // Level 8: 185 radius, 6.5s duration, even faster damage

        devilRadius = 80 + CGFloat(level - 1) * 15
        devilDuration = 3.0 + Double(level - 1) * 0.5

        // Faster damage ticks at higher levels
        if level >= 4 {
            damageInterval = 0.15
        }
        if level >= 8 {
            damageInterval = 0.1
        }
    }
}

