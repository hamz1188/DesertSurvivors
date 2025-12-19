//
//  ArmyOfMirages.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class ArmyOfMirages: BaseWeapon {
    // Evolved Mirage Clone (Mirage Clone + Mirror of Truth)
    // Behavior: Spawns a squad of 5 aggressive clones that explode on death/expiration
    
    private class AggressiveClone {
        let node: SKSpriteNode
        var target: BaseEnemy?
        var lifetime: TimeInterval
        let damage: Float
        let explosionDamage: Float
        let moveSpeed: CGFloat = 300 // Faster than normal clone
        var attackCooldown: TimeInterval = 0.2 // Very fast attacks
        var currentAttackCooldown: TimeInterval = 0
        var isDead: Bool = false

        init(node: SKSpriteNode, damage: Float, explosionDamage: Float, lifetime: TimeInterval) {
            self.node = node
            self.damage = damage
            self.explosionDamage = explosionDamage
            self.lifetime = lifetime
        }
        
        func update(deltaTime: TimeInterval, spatialHash: SpatialHash) {
            if isDead { return }
            lifetime -= deltaTime
            currentAttackCooldown -= deltaTime
            
            if lifetime <= 0 {
                explode(spatialHash: spatialHash)
                return
            }
            
            // Find target using spatial hash
            if target == nil || target?.isAlive == false {
                target = findNearestEnemy(from: node.position, spatialHash: spatialHash)
            }
            
            // Move and Attack
            if let target = target, target.isAlive {
                let direction = (target.position - node.position).normalized()
                node.position = node.position + (direction * moveSpeed * CGFloat(deltaTime))
                
                // Flip sprite based on direction
                if direction.x < 0 { node.xScale = -1.0 } // Assuming facing right initially
                else { node.xScale = 1.0 }
                
                if node.position.distance(to: target.position) < 40 && currentAttackCooldown <= 0 {
                    // Attack
                    target.takeDamage(damage)
                    currentAttackCooldown = attackCooldown
                    
                    // Visual
                    node.run(SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.05),
                        SKAction.scale(to: 1.0, duration: 0.05)
                    ]))
                }
            } else {
                // Idle wander? Or stay put.
            }
        }
        
        func explode(spatialHash: SpatialHash) {
            isDead = true
            
            // Explosion visual
            let explosion = SKShapeNode(circleOfRadius: 60)
            explosion.fillColor = .cyan
            explosion.alpha = 0.8
            explosion.position = node.position
            explosion.zPosition = Constants.ZPosition.projectile + 1
            node.parent?.addChild(explosion)
            
            explosion.run(SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 1.5, duration: 0.2),
                    SKAction.fadeOut(withDuration: 0.2)
                ]),
                SKAction.removeFromParent()
            ]))
            
            // Area Damage using spatial hash
            let nearbyNodes = spatialHash.query(near: node.position, radius: 80)
            for node in nearbyNodes {
                guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                if enemy.position.distance(to: self.node.position) < 80 {
                    enemy.takeDamage(explosionDamage)
                }
            }
            
            // Remove self
            node.removeFromParent()
        }
        
        private func findNearestEnemy(from position: CGPoint, spatialHash: SpatialHash) -> BaseEnemy? {
            let nearbyNodes = spatialHash.query(near: position, radius: 400)
            var nearest: BaseEnemy?
            var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
            
            for node in nearbyNodes {
                guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                let dist = position.distance(to: enemy.position)
                if dist < nearestDistance {
                    nearestDistance = dist
                    nearest = enemy
                }
            }
            return nearest
        }
    }
    
    private var activeClones: [AggressiveClone] = []
    
    init() {
        super.init(name: "Army of Mirages", baseDamage: 15, cooldown: 6.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Spawn 5 clones
        for _ in 0..<5 {
            // Random offset
            let offset = CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -50...50))
            let spawnPos = playerPosition + offset
            
            let clone = createClone(at: spawnPos)
            scene.addChild(clone.node)
            activeClones.append(clone)
        }
    }
    
    private func createClone(at position: CGPoint) -> AggressiveClone {
        // Visual
        let node = SKSpriteNode(color: .cyan, size: CGSize(width: 25, height: 25))
        node.position = position
        node.zPosition = Constants.ZPosition.player - 1
        node.alpha = 0.8
        
        // Add "Ninja/Warrior" mask look perhaps? Just simple for now.
        
        return AggressiveClone(node: node, damage: getDamage(), explosionDamage: getDamage() * 3, lifetime: 5.0)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        // Update clones
        activeClones.forEach { $0.update(deltaTime: deltaTime, spatialHash: spatialHash) }
        activeClones.removeAll { $0.isDead }
    }
}
