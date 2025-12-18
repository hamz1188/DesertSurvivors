//
//  DesertEagle.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DesertEagle: BaseWeapon {
    private class Falcon {
        let node: SKSpriteNode
        var target: BaseEnemy?
        var lifetime: TimeInterval
        let damage: Float
        let speed: CGFloat
        let turnRate: CGFloat = 5.0 // Radians per second
        var velocity: CGVector = CGVector.zero
        var hasHit: Bool = false

        init(node: SKSpriteNode, damage: Float, speed: CGFloat, lifetime: TimeInterval) {
            self.node = node
            self.damage = damage
            self.speed = speed
            self.lifetime = lifetime
        }

        func update(deltaTime: TimeInterval, enemies: [BaseEnemy]) {
            lifetime -= deltaTime

            // Find or update target
            if target == nil || target?.isAlive == false || hasHit {
                target = findNearestEnemy(from: node.position, enemies: enemies)
                hasHit = false
            }

            // Home toward target
            if let target = target, target.isAlive, !hasHit {
                let desiredDirection = (target.position - node.position).normalized()
                let currentDirection = CGPoint(x: velocity.dx, y: velocity.dy).normalized()

                // Smoothly turn toward target
                let angle = atan2(desiredDirection.y, desiredDirection.x)
                let currentAngle = atan2(currentDirection.y, currentDirection.x)
                var angleDiff = angle - currentAngle

                // Normalize angle difference
                while angleDiff > .pi { angleDiff -= 2 * .pi }
                while angleDiff < -.pi { angleDiff += 2 * .pi }

                let turnAmount = min(abs(angleDiff), turnRate * CGFloat(deltaTime)) * (angleDiff > 0 ? 1 : -1)
                let newAngle = currentAngle + turnAmount

                velocity = CGVector(
                    dx: cos(newAngle) * speed,
                    dy: sin(newAngle) * speed
                )

                node.zRotation = newAngle

                // Check collision
                let distance = node.position.distance(to: target.position)
                if distance < 25 {
                    target.takeDamage(damage)
                    hasHit = true

                    // Flash effect
                    node.run(SKAction.sequence([
                        SKAction.fadeAlpha(to: 0.3, duration: 0.1),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                    ]))

                    // Look for new target
                    self.target = nil
                }
            } else if velocity.dx == 0 && velocity.dy == 0 {
                // Initial velocity
                let randomAngle = Double.random(in: 0..<2 * .pi)
                velocity = CGVector(
                    dx: cos(randomAngle) * speed,
                    dy: sin(randomAngle) * speed
                )
            }

            // Move falcon
            node.position = CGPoint(
                x: node.position.x + velocity.dx * CGFloat(deltaTime),
                y: node.position.y + velocity.dy * CGFloat(deltaTime)
            )
        }

        private func findNearestEnemy(from position: CGPoint, enemies: [BaseEnemy]) -> BaseEnemy? {
            var nearest: BaseEnemy?
            var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

            for enemy in enemies where enemy.isAlive {
                let distance = position.distance(to: enemy.position)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearest = enemy
                }
            }

            return nearest
        }
    }

    private var activeFalcons: [Falcon] = []
    private var falconSpeed: CGFloat = 350
    private var falconLifetime: TimeInterval = 6.0
    private var maxFalcons: Int = 1

    init() {
        super.init(name: "Desert Eagle", baseDamage: 18, cooldown: 2.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Only spawn if under max falcons
        if activeFalcons.count < maxFalcons {
            let falcon = createFalcon(at: playerPosition)
            scene.addChild(falcon.node)
            activeFalcons.append(falcon)
        }
    }

    private func createFalcon(at position: CGPoint) -> Falcon {
        // Create falcon sprite (bird-like shape)
        let falconNode = SKSpriteNode(color: .brown, size: CGSize(width: 25, height: 20))
        falconNode.position = position
        falconNode.zPosition = Constants.ZPosition.projectile

        // Add wing effect
        let wing1 = SKSpriteNode(color: SKColor.brown.withAlphaComponent(0.7), size: CGSize(width: 15, height: 8))
        wing1.position = CGPoint(x: -8, y: 0)
        wing1.zRotation = 0.3
        falconNode.addChild(wing1)

        let wing2 = SKSpriteNode(color: SKColor.brown.withAlphaComponent(0.7), size: CGSize(width: 15, height: 8))
        wing2.position = CGPoint(x: 8, y: 0)
        wing2.zRotation = -0.3
        falconNode.addChild(wing2)

        // Flap animation
        let flapUp = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 3, duration: 0.15),
            SKAction.moveBy(x: 0, y: -3, duration: 0.15)
        ])
        falconNode.run(SKAction.repeatForever(flapUp))

        // Spawn animation
        falconNode.setScale(0.5)
        falconNode.alpha = 0.5
        falconNode.run(SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]))

        let falcon = Falcon(
            node: falconNode,
            damage: getDamage(),
            speed: falconSpeed,
            lifetime: falconLifetime
        )
        return falcon
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)

        // Update all active falcons
        activeFalcons = activeFalcons.filter { falcon in
            falcon.update(deltaTime: deltaTime, enemies: enemies)

            if falcon.lifetime <= 0 {
                // Fade out and remove
                falcon.node.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.scale(to: 0.5, duration: 0.3)
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

        // Increase falcon count, speed, and lifetime
        maxFalcons = 1 + (level - 1) / 2 // 1, 1, 2, 2, 3, 3, 4, 4
        falconSpeed = 350 + CGFloat(level - 1) * 30
        falconLifetime = 6.0 + Double(level - 1) * 0.5
    }
}
