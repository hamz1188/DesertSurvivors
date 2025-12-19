//
//  RocsDescendant.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class RocsDescendant: BaseWeapon {
    // Evolved Desert Eagle (Desert Eagle + Eagle Feather)
    // Behavior: Summons a massive Roc that circles the player, periodically diving and creating shockwaves.
    
    private var rocNode: SKSpriteNode?
    private var angle: CGFloat = 0
    private var radius: CGFloat = 150
    private var diveTimer: TimeInterval = 0
    private let diveInterval: TimeInterval = 2.0
    
    init() {
        super.init(name: "Roc's Descendant", baseDamage: 40, cooldown: 1.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        if rocNode == nil {
            summonRoc(scene: scene, playerPos: playerPosition)
        }
    }
    
    private func summonRoc(scene: SKScene?, playerPos: CGPoint) {
        guard let scene = scene else { return }
        
        // Large roc visual (simplified)
        let roc = SKSpriteNode(color: .brown, size: CGSize(width: 60, height: 40)) 
        roc.zPosition = Constants.ZPosition.projectile + 10 
        roc.position = CGPoint(x: playerPos.x + radius, y: playerPos.y)
        scene.addChild(roc)
        rocNode = roc
        
        let wingL = SKSpriteNode(color: .brown, size: CGSize(width: 40, height: 15))
        wingL.position = CGPoint(x: -20, y: 10)
        roc.addChild(wingL)
        let wingR = SKSpriteNode(color: .brown, size: CGSize(width: 40, height: 15))
        wingR.position = CGPoint(x: 20, y: 10)
        roc.addChild(wingR)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        
        guard let roc = rocNode else { return }
        
        // Circle player
        angle += CGFloat(deltaTime) * 2.0
        let targetPos = CGPoint(
            x: playerPosition.x + cos(angle) * radius,
            y: playerPosition.y + sin(angle) * radius
        )
        roc.position = targetPos
        roc.zRotation = angle + .pi / 2
        
        // Dive logic
        diveTimer += deltaTime
        if diveTimer >= diveInterval {
            diveTimer = 0
            performShockwave(at: roc.position, spatialHash: spatialHash, scene: roc.scene)
        }
    }
    
    private func performShockwave(at position: CGPoint, spatialHash: SpatialHash, scene: SKNode?) {
        guard let scene = scene else { return }
        
        let wave = SKShapeNode(circleOfRadius: 10)
        wave.position = position
        wave.strokeColor = .white
        wave.lineWidth = 3
        scene.addChild(wave)
        
        wave.run(SKAction.sequence([
            SKAction.scale(to: 10.0, duration: 0.5), // Expands to 100 radius
            SKAction.removeFromParent()
        ]))
        
        // Shockwave Damage using spatial hash
        let waveRadius: CGFloat = 100
        let nearbyNodes = spatialHash.query(near: position, radius: waveRadius)
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            if enemy.position.distance(to: position) < waveRadius {
                enemy.takeDamage(getDamage())
                
                // Stun/Pushback
                let dir = (enemy.position - position).normalized()
                enemy.position = enemy.position + (dir * 20)
            }
        }
    }
}
