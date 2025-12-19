//
//  EmperorScorpion.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class EmperorScorpion: BaseWeapon {
    // Evolved Scorpion Tail (Scorpion Tail + Venom Vial)
    // Behavior: Two massive whips (left and right), 100% poison chance, high damage
    
    private var lastDirection = CGVector(dx: 1, dy: 0)
    
    init() {
        super.init(name: "Emperor Scorpion", baseDamage: 40, cooldown: 1.0)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func upgrade() {
        // No levels for now
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Determine facing
        var forwardVec = lastDirection
        if let nearest = findNearestEnemy(from: playerPosition, spatialHash: spatialHash) {
            forwardVec = (nearest.position - playerPosition).toVector().normalized()
            lastDirection = forwardVec
        }
        
        let angle = atan2(forwardVec.dy, forwardVec.dx)
        
        // Whip 1 (Left offset)
        let whip1 = createWhip(color: .purple)
        whip1.position = playerPosition
        whip1.zRotation = angle + .pi / 8
        scene.addChild(whip1)
        animateWhip(whip1)
        
        // Whip 2 (Right offset)
        let whip2 = createWhip(color: .green) // Venom green
        whip2.position = playerPosition
        whip2.zRotation = angle - .pi / 8
        scene.addChild(whip2)
        animateWhip(whip2)
        
        // Damage Logic (Cone Area) using spatial hash
        checkConeDamage(origin: playerPosition, direction: forwardVec, angleWidth: .pi / 1.5, length: 250, spatialHash: spatialHash)
    }
    
    private func createWhip(color: SKColor) -> SKShapeNode {
        let length: CGFloat = 250
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: length, y: 0)) 
        
        let shape = SKShapeNode(path: path)
        shape.strokeColor = color
        shape.lineWidth = 20
        shape.zPosition = Constants.ZPosition.weapon
        return shape
    }
    
    private func animateWhip(_ node: SKNode) {
        node.run(SKAction.sequence([
            SKAction.scaleY(to: 1.5, duration: 0.1),
            SKAction.scaleY(to: 1.0, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    private func checkConeDamage(origin: CGPoint, direction: CGVector, angleWidth: CGFloat, length: CGFloat, spatialHash: SpatialHash) {
        let facingAngle = atan2(direction.dy, direction.dx)
        
        let nearbyNodes = spatialHash.query(near: origin, radius: length)
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            let toEnemy = enemy.position - origin
            let dist = toEnemy.length()
            
            if dist <= length {
                let enemyAngle = atan2(toEnemy.y, toEnemy.x)
                var angleDiff = abs(enemyAngle - facingAngle)
                if angleDiff > .pi { angleDiff = 2 * .pi - angleDiff }
                
                if angleDiff < angleWidth / 2 {
                    // HIT
                    enemy.takeDamage(getDamage())
                    
                    // Always poison
                    applyPotentPoison(to: enemy)
                }
            }
        }
    }
    
    private func applyPotentPoison(to enemy: BaseEnemy) {
        // Potent poison: 5 damage every 0.5s for 5s
        let poisonTick = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak enemy] in
                enemy?.takeDamage(5.0) 
                enemy?.setColor(.green)
                enemy?.spriteNode.colorBlendFactor = 0.8
            },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { [weak enemy] in
                 enemy?.spriteNode.colorBlendFactor = 0.0 // Flash effect
            }
        ])
        enemy.run(SKAction.repeat(poisonTick, count: 10))
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

extension CGVector {
    func normalized() -> CGVector {
        let len = sqrt(dx*dx + dy*dy)
        return len > 0 ? CGVector(dx: dx/len, dy: dy/len) : CGVector(dx: 1, dy: 0)
    }
}
extension CGPoint {
    func toVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }
}
