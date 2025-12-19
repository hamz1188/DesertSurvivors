//
//  OilFlask.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class OilFlask: BaseWeapon {
    private class Flask {
        let projectile: SKSpriteNode
        let direction: CGPoint
        let speed: CGFloat
        let damage: Float
        var lifetime: TimeInterval = 2.0

        init(projectile: SKSpriteNode, direction: CGPoint, speed: CGFloat, damage: Float) {
            self.projectile = projectile
            self.direction = direction
            self.speed = speed
            self.damage = damage
        }

        func update(deltaTime: TimeInterval) {
            lifetime -= deltaTime
            let movement = direction * speed * CGFloat(deltaTime)
            projectile.position = projectile.position + movement

            // Arc trajectory
            projectile.zRotation += CGFloat(deltaTime) * 3.0
        }
    }

    private class BurningPool {
        let node: SKNode
        let radius: CGFloat
        let damage: Float
        var lifetime: TimeInterval
        let damageInterval: TimeInterval = 0.3
        var damageTimer: TimeInterval = 0

        init(node: SKNode, radius: CGFloat, damage: Float, lifetime: TimeInterval) {
            self.node = node
            self.radius = radius
            self.damage = damage
            self.lifetime = lifetime
        }

        func update(deltaTime: TimeInterval, spatialHash: SpatialHash) {
            lifetime -= deltaTime
            damageTimer -= deltaTime

            if damageTimer <= 0 {
                // Damage enemies in pool using spatial hash query
                let nearbyNodes = spatialHash.query(near: node.position, radius: radius)
                for node in nearbyNodes {
                    guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                    if self.node.position.distance(to: enemy.position) < radius {
                        enemy.takeDamage(damage)
                    }
                }
                damageTimer = damageInterval
            }
        }
    }

    private var activeFlasks: [Flask] = []
    private var activePools: [BurningPool] = []
    private var flaskSpeed: CGFloat = 400
    private var poolRadius: CGFloat = 80
    private var poolDuration: TimeInterval = 5.0
    private var poolDamage: Float = 3.0

    init() {
        super.init(name: "Oil Flask", baseDamage: 15, cooldown: 2.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene as? GameScene else { return }

        // Find target location using helper that queries collision manager
        var targetDirection: CGPoint
        if let nearestEnemy = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) {
            targetDirection = (nearestEnemy.position - playerPosition).normalized()
        } else {
            let angle = Double.random(in: 0..<2 * .pi)
            targetDirection = CGPoint(x: cos(angle), y: sin(angle))
        }

        // Create flask projectile - ceramic pot style
        let flaskNode = SKSpriteNode(color: .clear, size: CGSize(width: 20, height: 24))
        flaskNode.position = playerPosition
        flaskNode.zPosition = Constants.ZPosition.projectile

        let flask = SKNode()

        // Flask body (pottery)
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -6, y: -10))
        bodyPath.addQuadCurve(to: CGPoint(x: -8, y: 0), control: CGPoint(x: -10, y: -5))
        bodyPath.addQuadCurve(to: CGPoint(x: -4, y: 8), control: CGPoint(x: -8, y: 5))
        bodyPath.addLine(to: CGPoint(x: 4, y: 8))
        bodyPath.addQuadCurve(to: CGPoint(x: 8, y: 0), control: CGPoint(x: 8, y: 5))
        bodyPath.addQuadCurve(to: CGPoint(x: 6, y: -10), control: CGPoint(x: 10, y: -5))
        bodyPath.closeSubpath()

        let body = SKShapeNode(path: bodyPath)
        body.fillColor = SKColor(red: 0.65, green: 0.45, blue: 0.3, alpha: 1.0) // Terracotta
        body.strokeColor = SKColor(red: 0.5, green: 0.35, blue: 0.22, alpha: 1.0)
        body.lineWidth = 1
        flask.addChild(body)

        // Flask neck
        let neck = SKShapeNode(rectOf: CGSize(width: 6, height: 5), cornerRadius: 1)
        neck.fillColor = SKColor(red: 0.6, green: 0.42, blue: 0.28, alpha: 1.0)
        neck.strokeColor = SKColor(red: 0.5, green: 0.35, blue: 0.22, alpha: 1.0)
        neck.lineWidth = 0.5
        neck.position = CGPoint(x: 0, y: 10)
        flask.addChild(neck)

        // Cork/stopper with wick
        let cork = SKShapeNode(circleOfRadius: 4)
        cork.fillColor = SKColor(red: 0.55, green: 0.4, blue: 0.25, alpha: 1.0)
        cork.strokeColor = .clear
        cork.position = CGPoint(x: 0, y: 13)
        flask.addChild(cork)

        // Burning wick
        let wick = SKShapeNode(rectOf: CGSize(width: 2, height: 6))
        wick.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        wick.strokeColor = .clear
        wick.position = CGPoint(x: 0, y: 17)
        flask.addChild(wick)

        // Flame on wick
        let flame = SKShapeNode(circleOfRadius: 4)
        flame.fillColor = SKColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.9)
        flame.strokeColor = SKColor(red: 1.0, green: 0.8, blue: 0.3, alpha: 1.0)
        flame.lineWidth = 1
        flame.position = CGPoint(x: 0, y: 21)

        // Flame flicker
        let flickerAction = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 0.8, duration: 0.1)
        ]))
        flame.run(flickerAction)
        flask.addChild(flame)

        // Oil sloshing highlight
        let oilHighlight = SKShapeNode(ellipseOf: CGSize(width: 8, height: 4))
        oilHighlight.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.15, alpha: 0.5)
        oilHighlight.strokeColor = .clear
        oilHighlight.position = CGPoint(x: -2, y: -2)
        flask.addChild(oilHighlight)

        flaskNode.addChild(flask)
        scene.addChild(flaskNode)

        let flaskData = Flask(
            projectile: flaskNode,
            direction: targetDirection,
            speed: flaskSpeed,
            damage: getDamage()
        )
        activeFlasks.append(flaskData)
    }

    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)

        // Update flasks
        activeFlasks = activeFlasks.filter { flask in
            flask.update(deltaTime: deltaTime)

            // Check if flask hit enemy using spatial hash query
            var shouldExplode = flask.lifetime <= 0

            if !shouldExplode {
                let nearbyNodes = spatialHash.query(near: flask.projectile.position, radius: 25)
                for node in nearbyNodes {
                    guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                    if flask.projectile.position.distance(to: enemy.position) < 20 {
                        enemy.takeDamage(flask.damage * 0.5) // Initial impact damage
                        shouldExplode = true
                        break
                    }
                }
            }

            if shouldExplode {
                createBurningPool(at: flask.projectile.position, damage: poolDamage)
                flask.projectile.removeFromParent()
                return false
            }

            return true
        }

        // Update burning pools
        activePools = activePools.filter { pool in
            pool.update(deltaTime: deltaTime, spatialHash: spatialHash)

            if pool.lifetime <= 0 {
                pool.node.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 0.5),
                    SKAction.removeFromParent()
                ]))
                return false
            }

            return true
        }
    }

    private func createBurningPool(at position: CGPoint, damage: Float) {
        guard let scene = scene else { return }

        let poolNode = SKNode()
        poolNode.position = position
        poolNode.zPosition = Constants.ZPosition.weapon

        // Base oil slick
        let oilSlick = SKShapeNode(ellipseOf: CGSize(width: poolRadius * 2.2, height: poolRadius * 1.8))
        oilSlick.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.05, alpha: 0.7)
        oilSlick.strokeColor = .clear
        oilSlick.zPosition = 0
        poolNode.addChild(oilSlick)

        // Fire ring (outer)
        let fireRing = SKShapeNode(circleOfRadius: poolRadius)
        fireRing.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 0.6)
        fireRing.strokeColor = SKColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 0.8)
        fireRing.lineWidth = 4
        fireRing.zPosition = 1
        poolNode.addChild(fireRing)

        // Inner fire (brighter)
        let innerFire = SKShapeNode(circleOfRadius: poolRadius * 0.6)
        innerFire.fillColor = SKColor(red: 1.0, green: 0.7, blue: 0.2, alpha: 0.7)
        innerFire.strokeColor = .clear
        innerFire.zPosition = 2
        poolNode.addChild(innerFire)

        // Fire particles
        let flames = SKEmitterNode()
        flames.particleBirthRate = 40
        flames.particleLifetime = 0.8
        flames.particlePositionRange = CGVector(dx: poolRadius * 1.5, dy: poolRadius * 1.5)
        flames.particleSpeed = 40
        flames.particleSpeedRange = 20
        flames.emissionAngle = .pi / 2
        flames.emissionAngleRange = 0.5
        flames.particleAlpha = 0.8
        flames.particleAlphaSpeed = -1.0
        flames.particleScale = 0.2
        flames.particleScaleSpeed = -0.15
        flames.particleColor = SKColor(red: 1.0, green: 0.5, blue: 0.1, alpha: 1.0)
        flames.particleColorBlendFactor = 1.0
        flames.zPosition = 3
        poolNode.addChild(flames)

        // Smoke particles
        let smoke = SKEmitterNode()
        smoke.particleBirthRate = 15
        smoke.particleLifetime = 1.5
        smoke.particlePositionRange = CGVector(dx: poolRadius, dy: poolRadius)
        smoke.particleSpeed = 25
        smoke.particleSpeedRange = 10
        smoke.emissionAngle = .pi / 2
        smoke.emissionAngleRange = 0.3
        smoke.particleAlpha = 0.3
        smoke.particleAlphaSpeed = -0.2
        smoke.particleScale = 0.15
        smoke.particleScaleSpeed = 0.1
        smoke.particleColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        smoke.particleColorBlendFactor = 1.0
        smoke.zPosition = 4
        poolNode.addChild(smoke)

        // Pulse animation
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.08, duration: 0.3),
            SKAction.scale(to: 0.95, duration: 0.3)
        ]))
        fireRing.run(pulse)
        innerFire.run(pulse)

        // Fade in
        poolNode.alpha = 0
        poolNode.run(SKAction.fadeAlpha(to: 1.0, duration: 0.2))

        scene.addChild(poolNode)

        let pool = BurningPool(
            node: poolNode,
            radius: poolRadius,
            damage: damage,
            lifetime: poolDuration
        )
        activePools.append(pool)
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

    override func upgrade() {
        super.upgrade()

        // Level-based upgrades
        // Level 1: 80 radius, 5.0s pool, 3.0 DoT, 400 speed
        // Level 2: 90 radius, 5.5s pool, 3.5 DoT, 450 speed
        // Level 3: 100 radius, 6.0s pool, 4.0 DoT, 500 speed
        // Level 4: 110 radius, 6.5s pool, 4.5 DoT, 550 speed
        // Level 5: 120 radius, 7.0s pool, 5.0 DoT, 600 speed
        // Level 6: 130 radius, 7.5s pool, 5.5 DoT, 650 speed
        // Level 7: 140 radius, 8.0s pool, 6.0 DoT, 700 speed
        // Level 8: 150 radius, 8.5s pool, 6.5 DoT, 750 speed

        poolRadius = 80 + CGFloat(level - 1) * 10
        poolDuration = 5.0 + Double(level - 1) * 0.5
        poolDamage = 3.0 + Float(level - 1) * 0.5
        flaskSpeed = 400 + CGFloat(level - 1) * 50
    }
}
