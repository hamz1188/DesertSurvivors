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
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        guard let scene = scene else { return }
        
        // Determine facing
        // We need player velocity or last input. Since BaseWeapon doesn't accept velocity in attack(),
        // we might assume BaseWeapon's update() stores it if we modify BaseWeapon, OR we infer it.
        // For now, let's just target nearest enemy to determine "forward".
        
        var forwardVec = lastDirection
        if let nearest = findNearestEnemy(from: playerPosition, enemies: enemies) {
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
        
        // Damage Logic (Cone Area)
        checkConeDamage(origin: playerPosition, direction: forwardVec, angleWidth: .pi / 1.5, length: 250, enemies: enemies)
    }
    
    private func createWhip(color: SKColor) -> SKShapeNode {
        let length: CGFloat = 250
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: length, y: 0)) // Simple straight line visual for now, or curve
        
        // Let's make it look like a stinger
        // ... (simplified visual)
        
        // NOTE: SKShapeNode is drawn relative to its origin, so anchorPoint is effectively (0,0) by default logic
        
        let node = SKShapeNode(rectOf: CGSize(width: length, height: 20))
        node.fillColor = color
        node.strokeColor = .black
        // node.anchorPoint = CGPoint(x: 0, y: 0.5) // REMOVED: SKShapeNode doesn't have anchorPoint per se.
        // To pivot from player (0,0), we need to ensure the geometry is offset correctly OR set the position.
        // Actually, rectOf: creates a centered rect. To pivot at end, we need a custom path or offset.
        // For now, let's just stick to the centered rect but we might need to offset the position.
        // Alternatively, use path-based shape which we defined but didn't use!
        // The previous code created 'path' but didn't use it for SKShapeNode init.
        // Let's use the path which starts at 0,0.
        
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
    
    private func checkConeDamage(origin: CGPoint, direction: CGVector, angleWidth: CGFloat, length: CGFloat, enemies: [BaseEnemy]) {
        let facingAngle = atan2(direction.dy, direction.dx)
        
        for enemy in enemies where enemy.isAlive {
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
    
    private func findNearestEnemy(from position: CGPoint, enemies: [BaseEnemy]) -> BaseEnemy? {
        var nearest: BaseEnemy?
        var nearestDistance: CGFloat = CGFloat.greatestFiniteMagnitude
        
        for enemy in enemies where enemy.isAlive {
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
