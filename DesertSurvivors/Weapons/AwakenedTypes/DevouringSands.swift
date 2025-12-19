//
//  DevouringSands.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class DevouringSands: BaseWeapon {
    // Evolved Quicksand (Quicksand + Hourglass)
    // Behavior: Massive sinkholes that pull enemies in and execute low HP non-bosses.
    
    private struct Sinkhole {
        let node: SKNode
        let visual: SKShapeNode
        var lifetime: TimeInterval
    }
    
    private var activeSinkholes: [Sinkhole] = []
    private var holeRadius: CGFloat = 180
    private var holeDuration: TimeInterval = 12.0
    private var executeThreshold: Float = 0.30 // 30% HP
    private var pullStrength: CGFloat = 2.0
    
    init() {
        super.init(name: "Devouring Sands", baseDamage: 6, cooldown: 5.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Spawn up to 2 large sinkholes
        if activeSinkholes.count < 2 {
            // Find cluster or random
            var pos = playerPosition
            if let nearest = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) {
                pos = nearest.position
            } else {
                 let angle = CGFloat.random(in: 0...2 * .pi)
                 pos = playerPosition + CGPoint(x: cos(angle) * 150, y: sin(angle) * 150)
            }
            
            createSinkhole(at: pos, scene: scene)
        }
    }
    
    private func createSinkhole(at position: CGPoint, scene: SKScene) {
        let container = SKNode()
        container.position = position
        container.zPosition = Constants.ZPosition.weapon - 2 // Deep underground
        
        let hole = SKShapeNode(circleOfRadius: holeRadius)
        hole.fillColor = SKColor.black.withAlphaComponent(0.6)
        hole.strokeColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        hole.lineWidth = 4
        container.addChild(hole)
        
        // Spiral effect
        let spiral = SKShapeNode(circleOfRadius: holeRadius * 0.9)
        spiral.strokeColor = SKColor(red: 0.6, green: 0.5, blue: 0.3, alpha: 0.5)
        spiral.lineWidth = 5
        hole.addChild(spiral)
        
        spiral.run(SKAction.repeatForever(SKAction.rotate(byAngle: -5, duration: 2.0)))
        
        container.alpha = 0
        container.run(SKAction.fadeAlpha(to: 1.0, duration: 1.0))
        
        scene.addChild(container)
        
        activeSinkholes.append(Sinkhole(node: container, visual: hole, lifetime: holeDuration))
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        // Clean up
        activeSinkholes = activeSinkholes.filter { $0.node.parent != nil }
        
        for index in 0..<activeSinkholes.count {
            activeSinkholes[index].lifetime -= deltaTime
            if activeSinkholes[index].lifetime <= 0 {
                let node = activeSinkholes[index].node
                node.run(SKAction.sequence([
                    SKAction.fadeOut(withDuration: 1.0),
                    SKAction.removeFromParent()
                ]))
                continue
            }
            
            let center = activeSinkholes[index].node.position
            
            // Process enemies using spatial hash
            let nearbyNodes = spatialHash.query(near: center, radius: holeRadius + 60)
            for node in nearbyNodes {
                guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
                let dist = enemy.position.distance(to: center)
                if dist < holeRadius + 50 {
                    // Pull
                    let dir = (center - enemy.position).normalized()
                    enemy.position = enemy.position + (dir * pullStrength)
                    
                    if dist < holeRadius {
                        // Damage
                        if Int(activeSinkholes[index].lifetime * 60) % 10 == 0 {
                             enemy.takeDamage(getDamage())
                        }
                        
                        // Execute Check
                        let hpPercent = enemy.currentHealth / enemy.maxHealth
                        if hpPercent < executeThreshold {
                            // EXECUTE
                            enemy.takeDamage(99999)
                            
                            // Visual Pop
                            let pop = SKShapeNode(circleOfRadius: 20)
                            pop.fillColor = .red
                            pop.position = enemy.position
                            scene?.addChild(pop)
                            pop.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.2), SKAction.removeFromParent()]))
                        }
                    }
                }
            }
        }
        
        activeSinkholes.removeAll { $0.lifetime <= 0 }
    }
    
    private func findNearestEnemy(from position: CGPoint, spatialHash: SpatialHash) -> BaseEnemy? {
        let nearbyNodes = spatialHash.query(near: position, radius: 400)
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            let d = position.distance(to: enemy.position)
            if d < nearestDistance {
                nearestDistance = d
                nearest = enemy
            }
        }
        return nearest
    }
}
