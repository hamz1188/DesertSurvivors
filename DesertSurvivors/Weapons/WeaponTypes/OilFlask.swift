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

        // Create flask projectile
        let flaskNode = SKSpriteNode(color: .orange, size: CGSize(width: 15, height: 15))
        flaskNode.position = playerPosition
        flaskNode.zPosition = Constants.ZPosition.projectile
        scene.addChild(flaskNode)

        let flask = Flask(
            projectile: flaskNode,
            direction: targetDirection,
            speed: flaskSpeed,
            damage: getDamage()
        )
        activeFlasks.append(flask)
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

        // Visual effect - burning circle
        let fire = SKShapeNode(circleOfRadius: poolRadius)
        fire.fillColor = SKColor.orange.withAlphaComponent(0.7)
        fire.strokeColor = .red
        fire.lineWidth = 3
        fire.alpha = 0.0
        poolNode.addChild(fire)

        // Pulse animation
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ]))
        fire.run(pulse)

        // Fade in
        fire.run(SKAction.fadeAlpha(to: 0.7, duration: 0.2))

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
