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

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Determine attack direction based on player movement or default to nearest enemy
        var direction = CGPoint(x: lastPlayerVelocity.dx, y: lastPlayerVelocity.dy)

        // If player not moving, attack nearest enemy using spatial hash
        if direction.length() < 0.1 {
            if let nearestEnemy = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) {
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

        // Damage enemies in whip path using spatial hash
        damageEnemiesInWhip(playerPosition: playerPosition, direction: direction, spatialHash: spatialHash)

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

    private func createWhip(angle: CGFloat) -> SKNode {
        let container = SKNode()
        container.zPosition = Constants.ZPosition.weapon

        let segmentCount = 12
        for i in 0..<segmentCount {
            let progress = CGFloat(i) / CGFloat(segmentCount - 1)

            // Calculate segment position along a curved arc
            let segmentDistance = progress * whipLength
            let bendAngle = angle + sin(progress * .pi) * 0.4 // More pronounced curve

            let segmentPos = CGPoint(
                x: cos(bendAngle) * segmentDistance,
                y: sin(bendAngle) * segmentDistance
            )

            if i < segmentCount - 1 {
                // Tail segments - armored scorpion segments
                let segmentWidth = whipWidth * (1.0 - progress * 0.6)
                let segmentHeight = segmentWidth * 0.6

                // Armored segment shape
                let segmentPath = CGMutablePath()
                segmentPath.move(to: CGPoint(x: -segmentWidth/2, y: -segmentHeight/2))
                segmentPath.addLine(to: CGPoint(x: -segmentWidth/2 * 0.7, y: segmentHeight/2))
                segmentPath.addLine(to: CGPoint(x: segmentWidth/2 * 0.7, y: segmentHeight/2))
                segmentPath.addLine(to: CGPoint(x: segmentWidth/2, y: -segmentHeight/2))
                segmentPath.closeSubpath()

                let segment = SKShapeNode(path: segmentPath)
                segment.fillColor = SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0) // Dark chitin
                segment.strokeColor = SKColor(red: 0.35, green: 0.28, blue: 0.2, alpha: 1.0)
                segment.lineWidth = 1
                segment.position = segmentPos
                segment.zRotation = bendAngle + .pi/2
                segment.zPosition = CGFloat(i)

                // Highlight ridge on each segment
                let ridge = SKShapeNode(rectOf: CGSize(width: segmentWidth * 0.3, height: 2))
                ridge.fillColor = SKColor(red: 0.4, green: 0.32, blue: 0.25, alpha: 0.6)
                ridge.strokeColor = .clear
                ridge.position = CGPoint(x: 0, y: segmentHeight * 0.2)
                segment.addChild(ridge)

                container.addChild(segment)
            } else {
                // Stinger - the venomous tip
                let stingerContainer = SKNode()
                stingerContainer.position = segmentPos
                stingerContainer.zRotation = bendAngle
                stingerContainer.zPosition = CGFloat(segmentCount)

                // Stinger base (bulb)
                let bulb = SKShapeNode(ellipseOf: CGSize(width: 14, height: 10))
                bulb.fillColor = SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
                bulb.strokeColor = SKColor(red: 0.35, green: 0.28, blue: 0.2, alpha: 1.0)
                bulb.lineWidth = 1
                stingerContainer.addChild(bulb)

                // Stinger needle
                let needlePath = CGMutablePath()
                needlePath.move(to: CGPoint(x: 5, y: 0))
                needlePath.addLine(to: CGPoint(x: 22, y: 0))
                needlePath.addLine(to: CGPoint(x: 5, y: -3))
                needlePath.closeSubpath()

                let needle = SKShapeNode(path: needlePath)
                needle.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.08, alpha: 1.0)
                needle.strokeColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
                needle.lineWidth = 0.5
                stingerContainer.addChild(needle)

                // Venom drip effect
                let venomDrip = SKShapeNode(circleOfRadius: 3)
                venomDrip.fillColor = SKColor(red: 0.4, green: 0.8, blue: 0.2, alpha: 0.8) // Toxic green
                venomDrip.strokeColor = .clear
                venomDrip.position = CGPoint(x: 20, y: -2)

                // Drip animation
                let dripAction = SKAction.repeatForever(SKAction.sequence([
                    SKAction.moveBy(x: 0, y: -5, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.2),
                    SKAction.move(to: CGPoint(x: 20, y: -2), duration: 0),
                    SKAction.fadeIn(withDuration: 0.1)
                ]))
                venomDrip.run(dripAction)
                stingerContainer.addChild(venomDrip)

                container.addChild(stingerContainer)
            }
        }

        container.alpha = 0.0
        return container
    }

    private func damageEnemiesInWhip(playerPosition: CGPoint, direction: CGPoint, spatialHash: SpatialHash) {
        let nearbyNodes = spatialHash.query(near: playerPosition, radius: whipLength)
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            let toEnemy = enemy.position - playerPosition
            let distance = toEnemy.length()

            // Check if enemy is in whip range
            if distance <= whipLength {
                let toEnemyNorm = toEnemy.normalized()
                let dotProduct = direction.x * toEnemyNorm.x + direction.y * toEnemyNorm.y

                // Check if enemy is in front (in whip direction)
                if dotProduct > 0.5 { // 60 degree cone
                    let damage = getDamage()
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
    
    private func findNearestEnemy(from position: CGPoint, spatialHash: SpatialHash) -> BaseEnemy? {
        let nearbyNodes = spatialHash.query(near: position, radius: 400)
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
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

        // Level-based upgrades
        // Level 1: 150 length, 30 width, 20% poison, 2.0 poison damage
        // Level 2: 170 length, 35 width, 25% poison, 2.5 poison damage
        // Level 3: 190 length, 40 width, 30% poison, 3.0 poison damage
        // Level 4: 210 length, 45 width, 35% poison, 3.5 poison damage
        // Level 5: 230 length, 50 width, 40% poison, 4.0 poison damage
        // Level 6: 250 length, 55 width, 45% poison, 4.5 poison damage
        // Level 7: 270 length, 60 width, 50% poison, 5.0 poison damage
        // Level 8: 290 length, 65 width, 60% poison, 5.5 poison damage

        whipLength = 150 + CGFloat(level - 1) * 20
        whipWidth = 30 + CGFloat(level - 1) * 5
        poisonChance = min(0.2 + Float(level - 1) * 0.05, 0.6)
        poisonDamage = 2.0 + Float(level - 1) * 0.5
        poisonDuration = 3.0 + Double(level - 1) * 0.5 // Poison lasts longer at higher levels
    }
}
