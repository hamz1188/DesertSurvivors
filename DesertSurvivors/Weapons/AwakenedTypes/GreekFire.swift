//
//  GreekFire.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class GreekFire: BaseWeapon {
    // Evolved Oil Flask (Oil Flask + Djinn Lamp)
    // Behavior: Throws blue-flame flasks creating intense, spreading fire pools.
    
    private class FirePool {
        let node: SKNode
        let radius: CGFloat
        let damage: Float
        var lifetime: TimeInterval
        let damageInterval: TimeInterval = 0.2
        var damageTimer: TimeInterval = 0
        
        init(node: SKNode, radius: CGFloat, damage: Float, lifetime: TimeInterval) {
            self.node = node
            self.radius = radius
            self.damage = damage
            self.lifetime = lifetime
        }
        
        func update(deltaTime: TimeInterval, enemies: [BaseEnemy]) {
            lifetime -= deltaTime
            damageTimer -= deltaTime
            
            if damageTimer <= 0 {
                // Intense damage
                for enemy in enemies where enemy.isAlive {
                    if node.position.distance(to: enemy.position) < radius {
                        enemy.takeDamage(damage)
                    }
                }
                damageTimer = damageInterval
            }
        }
    }
    
    private var activePools: [FirePool] = []
    private var poolRadius: CGFloat = 120
    
    init() {
        super.init(name: "Greek Fire", baseDamage: 25, cooldown: 3.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Throw 3 flasks in random directions
        for _ in 0..<3 {
            let angle = Double.random(in: 0..<2 * .pi)
            let distance = CGFloat.random(in: 100...300)
            let targetPos = CGPoint(x: playerPosition.x + cos(angle) * distance, y: playerPosition.y + sin(angle) * distance)
            
            throwFlask(to: targetPos, scene: scene)
        }
    }
    
    private func throwFlask(to target: CGPoint, scene: SKScene) {
        let flask = SKShapeNode(circleOfRadius: 8)
        flask.fillColor = .cyan
        flask.strokeColor = .blue
        flask.position = (scene as? GameScene)?.player.position ?? .zero
        flask.zPosition = Constants.ZPosition.projectile
        scene.addChild(flask)
        
        let move = SKAction.move(to: target, duration: 0.5)
        move.timingMode = .easeOut
        
        flask.run(SKAction.sequence([
            move,
            SKAction.run { [weak self] in
                self?.createFirePubble(at: target, scene: scene)
                flask.removeFromParent()
            }
        ]))
    }
    
    private func createFirePubble(at position: CGPoint, scene: SKScene) {
        let poolNode = SKNode()
        poolNode.position = position
        poolNode.zPosition = Constants.ZPosition.weapon
        
        // Blue fire visual
        let fire = SKShapeNode(circleOfRadius: poolRadius)
        fire.fillColor = SKColor.cyan.withAlphaComponent(0.6)
        fire.strokeColor = .blue
        fire.lineWidth = 4
        poolNode.addChild(fire)
        
        // Flicker effect
        fire.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.1),
            SKAction.fadeAlpha(to: 0.7, duration: 0.1)
        ])))
        
        scene.addChild(poolNode)
        
        activePools.append(FirePool(node: poolNode, radius: poolRadius, damage: getDamage(), lifetime: 6.0))
        
        // Remove pool after lifetime
        poolNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 6.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        activePools = activePools.filter { pool in
            pool.update(deltaTime: deltaTime, enemies: enemies)
            return pool.lifetime > 0
        }
    }
}
