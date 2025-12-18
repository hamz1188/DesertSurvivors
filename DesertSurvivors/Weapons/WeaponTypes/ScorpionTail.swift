//
//  ScorpionTail.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class ScorpionTail: BaseWeapon {
    private var whipLength: CGFloat = 150
    private var whipWidth: CGFloat = 30
    private var whipDuration: TimeInterval = 0.3
    private var lastPlayerVelocity: CGVector = CGVector(dx: 1, dy: 0) // Default to right
    private var poisonChance: Float = 0.2 // 20% chance to poison
    private var poisonDamage: Float = 2.0
    private var poisonDuration: TimeInterval = 3.0

    init() {
        super.init(name: "Scorpion Tail", baseDamage: 20, cooldown: 1.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Determine attack direction based on player movement or default to nearest enemy
        var direction = CGPoint(x: lastPlayerVelocity.dx, y: lastPlayerVelocity.dy)

        // If player not moving, attack nearest enemy
        if direction.length() < 0.1 {
            if let nearestEnemy = findNearestEnemy(from: playerPosition, enemies: enemies) {
                direction = (nearestEnemy.position - playerPosition).normalized()
            } else {
                direction = CGPoint(x: 1, y: 0) // Default right
            }
        } else {
            direction = direction.normalized()
        }

        let angle = atan2(direction.y, direction.x)

        // Create whip visual
        let whip = createWhip(angle: angle)
        whip.position = playerPosition
        scene.addChild(whip)

        // Damage enemies in whip path
        damageEnemiesInWhip(playerPosition: playerPosition, direction: direction, enemies: enemies)

        // Animate whip
        whip.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 0.8, duration: 0.1),
                SKAction.scale(to: 1.2, duration: 0.1)
            ]),
            SKAction.wait(forDuration: whipDuration - 0.2),
            SKAction.fadeOut(withDuration: 0.1),
            SKAction.removeFromParent()
        ]))
    }

    private func createWhip(angle: CGFloat) -> SKShapeNode {
        // Create a curved path for the whip
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))

        // Create a sweeping arc
        let midPoint = CGPoint(
            x: cos(angle) * whipLength * 0.6,
            y: sin(angle) * whipLength * 0.6
        )
        let endPoint = CGPoint(
            x: cos(angle) * whipLength,
            y: sin(angle) * whipLength
        )

        path.addQuadCurve(
            to: endPoint,
            control: CGPoint(x: midPoint.x * 1.2, y: midPoint.y * 1.2)
        )

        let whip = SKShapeNode(path: path)
        whip.strokeColor = .purple
        whip.lineWidth = whipWidth
        whip.alpha = 0.0
        whip.zPosition = Constants.ZPosition.weapon
        whip.lineCap = .round

        return whip
    }

    private func damageEnemiesInWhip(playerPosition: CGPoint, direction: CGPoint, enemies: [BaseEnemy]) {
        for enemy in enemies {
            let toEnemy = enemy.position - playerPosition
            let distance = toEnemy.length()

            // Check if enemy is in whip range
            if distance <= whipLength {
                let toEnemyNorm = toEnemy.normalized()
                let dotProduct = direction.x * toEnemyNorm.x + direction.y * toEnemyNorm.y

                // Check if enemy is in front (in whip direction)
                if dotProduct > 0.5 { // 60 degree cone
                    var damage = getDamage()
                    enemy.takeDamage(damage)

                    // Apply poison effect
                    if Float.random(in: 0...1) < poisonChance {
                        applyPoison(to: enemy)
                    }
                }
            }
        }
    }

    private func applyPoison(to enemy: BaseEnemy) {
        // Apply poison damage over time
        // Note: This is a simplified version. In a full implementation,
        // you'd want to track poison effects per enemy
        let poisonAction = SKAction.repeat(
            SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.run { [weak enemy] in
                    enemy?.takeDamage(self.poisonDamage)
                }
            ]),
            count: Int(poisonDuration / 0.5)
        )
        enemy.run(poisonAction)
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

    /// Update the last known player velocity for attack direction
    func updatePlayerVelocity(_ velocity: CGVector) {
        if velocity.dx != 0 || velocity.dy != 0 {
            lastPlayerVelocity = velocity
        }
    }

    override func upgrade() {
        super.upgrade()

        // Increase whip length, width, and poison chance
        whipLength = 150 + CGFloat(level - 1) * 20
        whipWidth = 30 + CGFloat(level - 1) * 5
        poisonChance = min(0.2 + Float(level - 1) * 0.05, 0.6) // Max 60% poison chance
        poisonDamage = 2.0 + Float(level - 1) * 0.5
    }
}
