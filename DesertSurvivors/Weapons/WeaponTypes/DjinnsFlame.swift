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

        func update(deltaTime: TimeInterval, enemies: [BaseEnemy]) {
            lifetime -= deltaTime

            // Find target if needed
            if target == nil || target?.isAlive == false || hasHitTarget(target!) {
                target = findNearestUnhitEnemy(enemies: enemies)
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

        private func findNearestUnhitEnemy(enemies: [BaseEnemy]) -> BaseEnemy? {
            var nearest: BaseEnemy?
            var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

            for enemy in enemies where enemy.isAlive {
                if hasHitTarget(enemy) {
                    continue
                }

                let distance = node.position.distance(to: enemy.position)
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

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
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
        let flameNode = SKNode()
        flameNode.position = position
        flameNode.zPosition = Constants.ZPosition.projectile

        // Create flame visual - blue mystical fire
        let flameShape = SKShapeNode(circleOfRadius: 12)
        flameShape.fillColor = SKColor(red: 0.2, green: 0.4, blue: 1.0, alpha: 0.8)
        flameShape.strokeColor = SKColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0)
        flameShape.lineWidth = 2
        flameShape.glowWidth = 5.0
        flameNode.addChild(flameShape)

        // Inner glow
        let innerGlow = SKShapeNode(circleOfRadius: 6)
        innerGlow.fillColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.9)
        innerGlow.strokeColor = .clear
        flameNode.addChild(innerGlow)

        // Flickering animation
        let flicker = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.2),
            SKAction.scale(to: 0.9, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
        flameShape.run(flicker)

        // Rotation animation
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 1.5))
        innerGlow.run(rotate)

        // Spawn animation
        flameNode.setScale(0.3)
        flameNode.alpha = 0.3
        flameNode.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.3),
            SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        ]))

        let flame = Flame(
            node: flameNode,
            damage: getDamage(),
            speed: flameSpeed,
            seekRadius: seekRadius,
            lifetime: flameLifetime,
            maxHits: maxHitsPerFlame
        )
        return flame
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)

        // Update all active flames
        activeFlames = activeFlames.filter { flame in
            flame.update(deltaTime: deltaTime, enemies: enemies)

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

        // Increase flame count, lifetime, speed, and hits per flame
        flameCount = 3 + (level - 1) / 2 // 3, 3, 4, 4, 5, 5, 6, 6
        flameLifetime = 8.0 + Double(level - 1) * 1.0
        flameSpeed = 200 + CGFloat(level - 1) * 30
        seekRadius = 400 + CGFloat(level - 1) * 50
        maxHitsPerFlame = 2 + (level - 1) / 3 // 2, 2, 2, 3, 3, 3, 4, 4
    }
}
