//
//  PharaohsWrath.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class PharaohsWrath: BaseWeapon {
    // Evolved Ancient Curse (Ancient Curse + Canopic Jar)
    // Behavior: Applies "Pharaoh's Seals" to enemies. 
    // Effect: Drains health to heal player, explodes on death.
    
    private struct SealEffect {
        let enemy: BaseEnemy
        let marker: SKNode
        var duration: TimeInterval
    }
    
    private var activeSeals: [SealEffect] = []
    private var sealRadius: CGFloat = 400
    private var sealDuration: TimeInterval = 10.0
    private var maxSealedEnemies: Int = 5
    private var healAmount: Float = 1.0
    private var explosionDamage: Float = 30.0
    
    init() {
        super.init(name: "Pharaoh's Wrath", baseDamage: 8, cooldown: 2.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Find unsealed enemies nearby
        let candidates = enemies.filter { enemy in
            enemy.isAlive && !isSealed(enemy) && playerPosition.distance(to: enemy.position) < sealRadius
        }
        
        // Sort by health (prefer stronger enemies to seal?) or just distance
        let sorted = candidates.sorted { $0.maxHealth > $1.maxHealth }
        
        let countToSeal = max(0, maxSealedEnemies - activeSeals.count)
        let targets = sorted.prefix(countToSeal)
        
        for target in targets {
            applySeal(to: target, scene: scene)
        }
    }
    
    private func applySeal(to enemy: BaseEnemy, scene: SKScene) {
        // Visual Marker - Ankh or Hieroglyph
        let marker = SKNode()
        marker.position = CGPoint(x: 0, y: 30)
        marker.zPosition = 100
        
        // Gold glowing Ankh shape (simplified)
        let circle = SKShapeNode(circleOfRadius: 6)
        circle.strokeColor = .yellow
        circle.lineWidth = 2
        circle.position = CGPoint(x: 0, y: 6)
        marker.addChild(circle)
        
        let cross = SKShapeNode(rectOf: CGSize(width: 16, height: 4))
        cross.fillColor = .yellow
        marker.addChild(cross)
        
        let stem = SKShapeNode(rectOf: CGSize(width: 4, height: 16))
        stem.fillColor = .yellow
        stem.position = CGPoint(x: 0, y: -6)
        marker.addChild(stem)
        
        enemy.addChild(marker)
        
        // Animation
        marker.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])))
        
        activeSeals.append(SealEffect(enemy: enemy, marker: marker, duration: sealDuration))
    }
    
    private func isSealed(_ enemy: BaseEnemy) -> Bool {
        return activeSeals.contains { $0.enemy === enemy }
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        activeSeals = activeSeals.compactMap { seal in
            var activeSeal = seal
            activeSeal.duration -= deltaTime
            
            let enemy = seal.enemy
            
            if !enemy.isAlive {
                // Explode!
                explode(at: enemy.position)
                seal.marker.removeFromParent()
                return nil
            }
            
            if activeSeal.duration <= 0 {
                // Expired
                seal.marker.removeFromParent()
                return nil
            }
            
            // Drain Health Logic
            // Every 1 second roughly
            if Int(activeSeal.duration * 60) % 60 == 0 {
                // Damage enemy
                enemy.takeDamage(getDamage())
                
                // Heal Player (Need access to PlayerStats via GameScene)
                if let gameScene = scene as? GameScene {
                   gameScene.player.stats.currentHealth = min(
                       gameScene.player.stats.currentHealth + self.healAmount,
                       gameScene.player.stats.maxHealth
                   )
                   // Visual heal text could go here
                }
            }
            
            return activeSeal
        }
    }
    
    private func explode(at position: CGPoint) {
        guard let scene = scene else { return }
        
        // Visual
        let blast = SKShapeNode(circleOfRadius: 80)
        blast.fillColor = SKColor.yellow.withAlphaComponent(0.6)
        blast.strokeColor = .white
        blast.position = position
        blast.zPosition = Constants.ZPosition.projectile + 10
        scene.addChild(blast)
        
        blast.run(SKAction.sequence([
            SKAction.scale(to: 1.5, duration: 0.2),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
        
        // Damage Area
        // Access enemies from GameScene or pass them? 
        // We lack direct enemy list access here inside explode unless we pass it or query scene
        // Simpler to just assume we catch them next frame or query scene nodes.
        // Let's query scene nodes for simplicity in this decoupled method
        
        let nearby = scene.children.compactMap { $0 as? BaseEnemy }
        for enemy in nearby where enemy.isAlive {
            if enemy.position.distance(to: position) < 100 {
                enemy.takeDamage(explosionDamage)
            }
        }
    }
}
