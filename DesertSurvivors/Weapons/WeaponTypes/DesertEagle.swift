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

        func update(deltaTime: TimeInterval, spatialHash: SpatialHash) {
            lifetime -= deltaTime

            // Find or update target using spatial hash
            if target == nil || target?.isAlive == false || hasHit {
                target = findNearestEnemy(from: node.position, spatialHash: spatialHash)
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

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }

        // Only spawn if under max falcons
        if activeFalcons.count < maxFalcons {
            let falcon = createFalcon(at: playerPosition)
            scene.addChild(falcon.node)
            activeFalcons.append(falcon)
        }
    }
    
    private func createFalcon(at position: CGPoint) -> Falcon {
        let node = SKSpriteNode(color: .clear, size: CGSize(width: 40, height: 30))
        node.position = position
        node.zPosition = Constants.ZPosition.projectile

        // Create procedural falcon/eagle
        let falcon = SKNode()

        // Body - streamlined
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -15, y: 0))
        bodyPath.addQuadCurve(to: CGPoint(x: 12, y: 0), control: CGPoint(x: 0, y: 8))
        bodyPath.addQuadCurve(to: CGPoint(x: -15, y: 0), control: CGPoint(x: 0, y: -6))

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = SKColor(red: 0.45, green: 0.35, blue: 0.25, alpha: 1.0) // Brown
        body.strokeColor = SKColor(red: 0.35, green: 0.25, blue: 0.18, alpha: 1.0)
        body.lineWidth = 1
        falcon.addChild(body)

        // Wings (animated)
        let wingPath = CGMutablePath()
        wingPath.move(to: CGPoint(x: -5, y: 3))
        wingPath.addQuadCurve(to: CGPoint(x: -18, y: 12), control: CGPoint(x: -12, y: 10))
        wingPath.addLine(to: CGPoint(x: -8, y: 3))
        wingPath.closeSubpath()

        let topWing = SKShapeNode(path: wingPath)
        topWing.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        topWing.strokeColor = SKColor(red: 0.35, green: 0.25, blue: 0.18, alpha: 1.0)
        topWing.lineWidth = 0.5
        topWing.name = "wing"
        falcon.addChild(topWing)

        // Bottom wing (mirror)
        let bottomWingPath = CGMutablePath()
        bottomWingPath.move(to: CGPoint(x: -5, y: -3))
        bottomWingPath.addQuadCurve(to: CGPoint(x: -18, y: -12), control: CGPoint(x: -12, y: -10))
        bottomWingPath.addLine(to: CGPoint(x: -8, y: -3))
        bottomWingPath.closeSubpath()

        let bottomWing = SKShapeNode(path: bottomWingPath)
        bottomWing.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        bottomWing.strokeColor = SKColor(red: 0.35, green: 0.25, blue: 0.18, alpha: 1.0)
        bottomWing.lineWidth = 0.5
        bottomWing.name = "wing"
        falcon.addChild(bottomWing)

        // Head
        let head = SKShapeNode(circleOfRadius: 6)
        head.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.22, alpha: 1.0)
        head.strokeColor = .clear
        head.position = CGPoint(x: 10, y: 2)
        falcon.addChild(head)

        // Beak - hooked
        let beakPath = CGMutablePath()
        beakPath.move(to: CGPoint(x: 14, y: 3))
        beakPath.addLine(to: CGPoint(x: 22, y: 1))
        beakPath.addQuadCurve(to: CGPoint(x: 18, y: -2), control: CGPoint(x: 21, y: -1))
        beakPath.addLine(to: CGPoint(x: 14, y: 0))
        beakPath.closeSubpath()

        let beak = SKShapeNode(path: beakPath)
        beak.fillColor = SKColor(red: 0.9, green: 0.75, blue: 0.2, alpha: 1.0)
        beak.strokeColor = SKColor(red: 0.7, green: 0.55, blue: 0.1, alpha: 1.0)
        beak.lineWidth = 0.5
        falcon.addChild(beak)

        // Eye
        let eye = SKShapeNode(circleOfRadius: 2)
        eye.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1.0) // Golden eye
        eye.strokeColor = .black
        eye.lineWidth = 0.5
        eye.position = CGPoint(x: 12, y: 4)
        falcon.addChild(eye)

        // Tail feathers
        for i in 0..<3 {
            let tailPath = CGMutablePath()
            let yOffset = CGFloat(i - 1) * 3
            tailPath.move(to: CGPoint(x: -15, y: yOffset))
            tailPath.addLine(to: CGPoint(x: -22, y: yOffset + CGFloat(i - 1) * 2))
            tailPath.addLine(to: CGPoint(x: -20, y: yOffset))
            tailPath.closeSubpath()

            let tail = SKShapeNode(path: tailPath)
            tail.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.22, alpha: 1.0)
            tail.strokeColor = .clear
            falcon.addChild(tail)
        }

        node.addChild(falcon)

        // Wing flapping animation
        let flapUp = SKAction.run {
            topWing.yScale = 1.3
            bottomWing.yScale = 0.7
        }
        let flapDown = SKAction.run {
            topWing.yScale = 0.7
            bottomWing.yScale = 1.3
        }
        let flapSequence = SKAction.repeatForever(SKAction.sequence([
            flapUp, SKAction.wait(forDuration: 0.1),
            flapDown, SKAction.wait(forDuration: 0.1)
        ]))
        node.run(flapSequence)

        return Falcon(node: node, damage: getDamage(), speed: falconSpeed, lifetime: falconLifetime)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)

        // Update all active falcons using spatial hash
        activeFalcons = activeFalcons.filter { falcon in
            falcon.update(deltaTime: deltaTime, spatialHash: spatialHash)

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

        // Level-based upgrades
        // Level 1: 1 falcon, 350 speed, 6.0s lifetime
        // Level 2: 1 falcon, 380 speed, 6.5s lifetime
        // Level 3: 2 falcons, 410 speed, 7.0s lifetime
        // Level 4: 2 falcons, 440 speed, 7.5s lifetime
        // Level 5: 3 falcons, 470 speed, 8.0s lifetime
        // Level 6: 3 falcons, 500 speed, 8.5s lifetime
        // Level 7: 4 falcons, 530 speed, 9.0s lifetime
        // Level 8: 4 falcons, 560 speed, 9.5s lifetime

        maxFalcons = 1 + (level - 1) / 2
        falconSpeed = 350 + CGFloat(level - 1) * 30
        falconLifetime = 6.0 + Double(level - 1) * 0.5
    }
}
