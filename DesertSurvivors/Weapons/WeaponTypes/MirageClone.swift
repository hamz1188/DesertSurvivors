//
//  MirageClone.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class MirageClone: BaseWeapon {
    private class Clone {
        let node: SKSpriteNode
        var target: BaseEnemy?
        var lifetime: TimeInterval
        let damage: Float
        let moveSpeed: CGFloat = 200
        var attackCooldown: TimeInterval = 0.5
        var currentAttackCooldown: TimeInterval = 0

        init(node: SKSpriteNode, damage: Float, lifetime: TimeInterval) {
            self.node = node
            self.damage = damage
            self.lifetime = lifetime
        }

        func update(deltaTime: TimeInterval, enemies: [BaseEnemy]) {
            lifetime -= deltaTime
            currentAttackCooldown -= deltaTime

            // Find or update target
            if target == nil || target?.isAlive == false {
                target = findNearestEnemy(from: node.position, enemies: enemies)
            }

            // Move toward target
            if let target = target, target.isAlive {
                let direction = (target.position - node.position).normalized()
                let movement = direction * moveSpeed * CGFloat(deltaTime)
                node.position = node.position + movement

                // Attack if close enough
                let distance = node.position.distance(to: target.position)
                if distance < 30 && currentAttackCooldown <= 0 {
                    target.takeDamage(damage)
                    currentAttackCooldown = attackCooldown

                    // Flash effect
                    node.run(SKAction.sequence([
                        SKAction.fadeAlpha(to: 1.0, duration: 0.05),
                        SKAction.fadeAlpha(to: 0.6, duration: 0.05)
                    ]))
                }
            }
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

    private var activeClones: [Clone] = []
    private var cloneDuration: TimeInterval = 8.0
    private var maxClones: Int = 2

    init() {
        super.init(name: "Mirage Clone", baseDamage: 12, cooldown: 3.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Remove expired clones
        activeClones.removeAll { $0.lifetime <= 0 }

        // Only spawn if under max clones
        if activeClones.count < maxClones {
            let clone = createClone(at: playerPosition)
            scene.addChild(clone.node)
            activeClones.append(clone)
        }
    }

    private func createClone(at position: CGPoint) -> Clone {
        // Create visual representation (semi-transparent player copy)
        let cloneNode = SKSpriteNode(color: SKColor.cyan.withAlphaComponent(0.6), size: CGSize(width: 30, height: 30))
        cloneNode.position = position
        cloneNode.zPosition = Constants.ZPosition.player - 1

        // Add glow effect
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        let glowSprite = SKSpriteNode(color: .cyan, size: CGSize(width: 35, height: 35))
        glowSprite.alpha = 0.5
        glow.addChild(glowSprite)
        cloneNode.addChild(glow)

        // Spawn animation
        cloneNode.alpha = 0
        cloneNode.setScale(0.5)
        cloneNode.run(SKAction.group([
            SKAction.fadeAlpha(to: 0.6, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ]))

        let clone = Clone(node: cloneNode, damage: getDamage(), lifetime: cloneDuration)
        return clone
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)

        // Update all active clones
        activeClones = activeClones.filter { clone in
            clone.update(deltaTime: deltaTime, enemies: enemies)

            if clone.lifetime <= 0 {
                // Fade out and remove
                clone.node.run(SKAction.sequence([
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

        // Level-based upgrades
        // Level 1: 2 clones, 8s duration, 0.5s attack speed
        // Level 2: 2 clones, 9s duration, 0.5s attack speed
        // Level 3: 3 clones, 10s duration, 0.45s attack speed
        // Level 4: 3 clones, 11s duration, 0.45s attack speed
        // Level 5: 4 clones, 12s duration, 0.4s attack speed
        // Level 6: 4 clones, 13s duration, 0.4s attack speed
        // Level 7: 5 clones, 14s duration, 0.35s attack speed
        // Level 8: 5 clones, 15s duration, 0.3s attack speed

        maxClones = 2 + (level - 1) / 2
        cloneDuration = 8.0 + Double(level - 1) * 1.0
    }
}
