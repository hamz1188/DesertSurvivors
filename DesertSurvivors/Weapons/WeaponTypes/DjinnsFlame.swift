//
//  DjinnsFlame.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DjinnsFlame: BaseWeapon {
    private class Flame {
        let node: SKNode
        var target: BaseEnemy?
        var lifetime: TimeInterval
        let damage: Float
        let speed: CGFloat
        let seekRadius: CGFloat
        var hasHitTargets: Set<ObjectIdentifier> = []
        let maxHits: Int
        var currentHits: Int = 0

        init(node: SKNode, damage: Float, speed: CGFloat, seekRadius: CGFloat, lifetime: TimeInterval, maxHits: Int) {
            self.node = node
            self.damage = damage
            self.speed = speed
            self.seekRadius = seekRadius
            self.lifetime = lifetime
            self.maxHits = maxHits
        }

        func update(deltaTime: TimeInterval, spatialHash: SpatialHash) {
            lifetime -= deltaTime

            // Find target if needed using spatial hash
            if target == nil || target?.isAlive == false || hasHitTarget(target!) {
                target = findNearestUnhitEnemy(spatialHash: spatialHash)
            }

            // Move toward target or drift
            if let target = target, target.isAlive, !hasHitTarget(target), currentHits < maxHits {
                let direction = (target.position - node.position).normalized()
                let movement = direction * speed * CGFloat(deltaTime)
                node.position = node.position + movement

                // Check collision
                let distance = node.position.distance(to: target.position)
                if distance < 20 {
                    target.takeDamage(damage)
                    hasHitTargets.insert(ObjectIdentifier(target))
                    currentHits += 1

                    // Flash effect
                    if let sprite = node.children.first as? SKShapeNode {
                        sprite.run(SKAction.sequence([
                            SKAction.scale(to: 1.5, duration: 0.1),
                            SKAction.scale(to: 1.0, duration: 0.1)
                        ]))
                    }

                    // Clear target to find new one
                    self.target = nil
                }
            } else {
                // Drift slowly
                let driftAngle = CGFloat.random(in: 0..<2 * .pi)
                let driftSpeed = speed * 0.2
                let movement = CGPoint(
                    x: cos(driftAngle) * driftSpeed * CGFloat(deltaTime),
                    y: sin(driftAngle) * driftSpeed * CGFloat(deltaTime)
                )
                node.position = node.position + movement
            }
        }

        private func hasHitTarget(_ enemy: BaseEnemy) -> Bool {
            return hasHitTargets.contains(ObjectIdentifier(enemy))
        }

        private func findNearestUnhitEnemy(spatialHash: SpatialHash) -> BaseEnemy? {
            let nearbyNodes = spatialHash.query(near: node.position, radius: seekRadius)
            
            var nearest: BaseEnemy?
            var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

            for node in nearbyNodes {
                guard let enemy = node as? BaseEnemy, enemy.isAlive, !hasHitTarget(enemy) else { continue }

                let distance = self.node.position.distance(to: enemy.position)
                if distance < nearestDistance && distance < seekRadius {
                    nearestDistance = distance
                    nearest = enemy
                }
            }

            return nearest
        }
    }

    private var activeFlames: [Flame] = []
    private var flameSpeed: CGFloat = 200
    private var seekRadius: CGFloat = 400
    private var flameLifetime: TimeInterval = 8.0
    private var flameCount: Int = 3
    private var maxHitsPerFlame: Int = 2

    init() {
        super.init(name: "Djinn's Flame", baseDamage: 14, cooldown: 2.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Spawn multiple flames in a spread pattern
        let spreadAngle: CGFloat = 2 * .pi / CGFloat(flameCount)

        for i in 0..<flameCount {
            let angle = spreadAngle * CGFloat(i)
            let offset = CGPoint(
                x: cos(angle) * 30,
                y: sin(angle) * 30
            )
            let spawnPosition = playerPosition + offset

            let flame = createFlame(at: spawnPosition)
            scene.addChild(flame.node)
            activeFlames.append(flame)
        }
    }

    private func createFlame(at position: CGPoint) -> Flame {
        let container = SKNode()
        container.position = position
        container.zPosition = Constants.ZPosition.weapon

        // Mystical djinn flame - magical fire spirit
        let flameContainer = SKNode()

        // Outer magical aura
        let aura = SKShapeNode(circleOfRadius: 18)
        aura.fillColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 0.2) // Blue magic glow
        aura.strokeColor = SKColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.4)
        aura.lineWidth = 2
        aura.zPosition = 0
        flameContainer.addChild(aura)

        // Main flame body - teardrop shape
        let flamePath = CGMutablePath()
        flamePath.move(to: CGPoint(x: 0, y: 18))
        flamePath.addQuadCurve(to: CGPoint(x: 10, y: -5), control: CGPoint(x: 14, y: 8))
        flamePath.addQuadCurve(to: CGPoint(x: 0, y: -12), control: CGPoint(x: 6, y: -10))
        flamePath.addQuadCurve(to: CGPoint(x: -10, y: -5), control: CGPoint(x: -6, y: -10))
        flamePath.addQuadCurve(to: CGPoint(x: 0, y: 18), control: CGPoint(x: -14, y: 8))

        let flameBody = SKShapeNode(path: flamePath)
        flameBody.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 0.9)
        flameBody.strokeColor = SKColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0)
        flameBody.lineWidth = 1.5
        flameBody.zPosition = 1
        flameContainer.addChild(flameBody)

        // Inner bright core
        let innerPath = CGMutablePath()
        innerPath.move(to: CGPoint(x: 0, y: 12))
        innerPath.addQuadCurve(to: CGPoint(x: 5, y: -2), control: CGPoint(x: 7, y: 5))
        innerPath.addQuadCurve(to: CGPoint(x: 0, y: -6), control: CGPoint(x: 3, y: -5))
        innerPath.addQuadCurve(to: CGPoint(x: -5, y: -2), control: CGPoint(x: -3, y: -5))
        innerPath.addQuadCurve(to: CGPoint(x: 0, y: 12), control: CGPoint(x: -7, y: 5))

        let innerFlame = SKShapeNode(path: innerPath)
        innerFlame.fillColor = SKColor(red: 1.0, green: 0.85, blue: 0.4, alpha: 0.9)
        innerFlame.strokeColor = .clear
        innerFlame.zPosition = 2
        flameContainer.addChild(innerFlame)

        // White hot center
        let core = SKShapeNode(circleOfRadius: 4)
        core.fillColor = .white
        core.strokeColor = .clear
        core.alpha = 0.9
        core.position = CGPoint(x: 0, y: -2)
        core.zPosition = 3
        flameContainer.addChild(core)

        // Magical sparkles
        let sparkles = SKEmitterNode()
        sparkles.particleBirthRate = 20
        sparkles.particleLifetime = 0.6
        sparkles.particlePositionRange = CGVector(dx: 15, dy: 20)
        sparkles.particleSpeed = 15
        sparkles.particleSpeedRange = 10
        sparkles.emissionAngle = .pi / 2
        sparkles.emissionAngleRange = 1.5
        sparkles.particleAlpha = 0.8
        sparkles.particleAlphaSpeed = -1.3
        sparkles.particleScale = 0.06
        sparkles.particleScaleSpeed = -0.08
        sparkles.particleColor = SKColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0) // Blue magical
        sparkles.particleColorBlendFactor = 1.0
        sparkles.zPosition = 4
        flameContainer.addChild(sparkles)

        container.addChild(flameContainer)

        // Flicker animation
        let flickerScale = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.08),
            SKAction.scale(to: 0.9, duration: 0.08),
            SKAction.scale(to: 1.05, duration: 0.06)
        ]))
        flameBody.run(flickerScale)
        innerFlame.run(flickerScale)

        // Gentle rotation for magical feel
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 3.0))
        aura.run(rotate)

        return Flame(
            node: container,
            damage: getDamage(),
            speed: flameSpeed,
            seekRadius: seekRadius,
            lifetime: flameLifetime,
            maxHits: maxHitsPerFlame
        )
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)

        // Update all active flames
        activeFlames = activeFlames.filter { flame in
            flame.update(deltaTime: deltaTime, spatialHash: spatialHash)

            // Remove if expired or max hits reached
            if flame.lifetime <= 0 || flame.currentHits >= flame.maxHits {
                flame.node.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.scale(to: 0.1, duration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ]))
                return false
            }

            return true
        }
    }

    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 3 flames, 2 hits, 200 speed, 8s lifetime, 400 seek radius
        // Level 2: 3 flames, 2 hits, 230 speed, 9s lifetime, 450 seek radius
        // Level 3: 4 flames, 2 hits, 260 speed, 10s lifetime, 500 seek radius
        // Level 4: 4 flames, 3 hits, 290 speed, 11s lifetime, 550 seek radius
        // Level 5: 5 flames, 3 hits, 320 speed, 12s lifetime, 600 seek radius
        // Level 6: 5 flames, 3 hits, 350 speed, 13s lifetime, 650 seek radius
        // Level 7: 6 flames, 4 hits, 380 speed, 14s lifetime, 700 seek radius
        // Level 8: 6 flames, 4 hits, 410 speed, 15s lifetime, 750 seek radius

        flameCount = 3 + (level - 1) / 2
        flameLifetime = 8.0 + Double(level - 1) * 1.0
        flameSpeed = 200 + CGFloat(level - 1) * 30
        seekRadius = 400 + CGFloat(level - 1) * 50
        maxHitsPerFlame = 2 + (level - 1) / 3
    }
}
