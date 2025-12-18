//
//  AncientCurse.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class AncientCurse: BaseWeapon {
    private struct CurseEffect {
        let enemy: BaseEnemy
        let marker: SKNode
        var duration: TimeInterval
        let damageMultiplier: Float
    }

    private var cursedEnemies: [CurseEffect] = []
    private var curseRadius: CGFloat = 300
    private var curseDuration: TimeInterval = 8.0
    private var curseDamageMultiplier: Float = 1.5 // Cursed enemies take 50% more damage
    private var maxCursedEnemies: Int = 3

    init() {
        super.init(name: "Ancient Curse", baseDamage: 5, cooldown: 3.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Find enemies to curse (not already cursed)
        let uncursedEnemies = enemies.filter { enemy in
            enemy.isAlive && !isCursed(enemy) && playerPosition.distance(to: enemy.position) < curseRadius
        }

        // Sort by distance and curse nearest enemies
        let sortedEnemies = uncursedEnemies.sorted { enemy1, enemy2 in
            playerPosition.distance(to: enemy1.position) < playerPosition.distance(to: enemy2.position)
        }

        let enemiesNeeded = maxCursedEnemies - cursedEnemies.count
        let enemiesToCurse = Array(sortedEnemies.prefix(enemiesNeeded))

        for enemy in enemiesToCurse {
            applyCurse(to: enemy, scene: scene)
        }
    }

    private func applyCurse(to enemy: BaseEnemy, scene: SKScene) {
        // Create curse marker (visual indicator)
        let marker = createCurseMarker()
        marker.position = CGPoint(x: 0, y: 25) // Above enemy
        enemy.addChild(marker)

        // Apply initial damage
        enemy.takeDamage(getDamage())

        // Store curse effect
        let curse = CurseEffect(
            enemy: enemy,
            marker: marker,
            duration: curseDuration,
            damageMultiplier: curseDamageMultiplier
        )
        cursedEnemies.append(curse)

        // Visual effect - dark energy swirl
        createCurseVisualEffect(at: enemy.position, scene: scene)
    }

    private func createCurseMarker() -> SKNode {
        let container = SKNode()
        container.zPosition = 100

        // Rotating curse symbol
        let symbol = SKShapeNode(circleOfRadius: 12)
        symbol.strokeColor = .purple
        symbol.lineWidth = 2
        symbol.fillColor = SKColor.purple.withAlphaComponent(0.3)
        container.addChild(symbol)

        // Add inner mark
        let innerMark = SKShapeNode(circleOfRadius: 6)
        innerMark.strokeColor = .purple
        innerMark.lineWidth = 1
        innerMark.fillColor = .clear
        container.addChild(innerMark)

        // Pulse animation
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ]))
        symbol.run(pulse)

        // Rotation animation
        let rotate = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2.0))
        container.run(rotate)

        return container
    }

    private func createCurseVisualEffect(at position: CGPoint, scene: SKScene) {
        // Dark energy particles
        for _ in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: 4)
            particle.fillColor = .purple
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = Constants.ZPosition.projectile
            scene.addChild(particle)

            let angle = Double.random(in: 0..<2 * .pi)
            let distance: CGFloat = 50
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )

            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.move(to: destination, duration: 0.8),
                    SKAction.fadeOut(withDuration: 0.8),
                    SKAction.scale(to: 0.1, duration: 0.8)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }

    private func isCursed(_ enemy: BaseEnemy) -> Bool {
        return cursedEnemies.contains { $0.enemy === enemy }
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)

        // Update cursed enemies
        cursedEnemies = cursedEnemies.compactMap { curse in
            var mutableCurse = curse
            mutableCurse.duration -= deltaTime

            // Apply damage over time
            if Int(mutableCurse.duration * 10) % 10 == 0 { // Every ~1 second
                curse.enemy.takeDamage(getDamage() * 0.3)
            }

            // Check if curse expired or enemy died
            if mutableCurse.duration <= 0 || !curse.enemy.isAlive {
                curse.marker.run(SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.scale(to: 0.1, duration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ]))
                return nil
            }

            return mutableCurse
        }
    }

    /// Get the damage multiplier for a cursed enemy
    func getDamageMultiplier(for enemy: BaseEnemy) -> Float {
        if isCursed(enemy) {
            return curseDamageMultiplier
        }
        return 1.0
    }

    override func upgrade() {
        super.upgrade()

        // Increase curse duration, radius, and max cursed enemies
        curseDuration = 8.0 + Double(level - 1) * 1.0
        curseRadius = 300 + CGFloat(level - 1) * 50
        maxCursedEnemies = 3 + (level - 1) / 2 // 3, 3, 4, 4, 5, 5, 6, 6
        curseDamageMultiplier = 1.5 + Float(level - 1) * 0.1 // Up to 2.2x at level 8
    }
}
