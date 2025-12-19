//
//  DesertBandit.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Ranged/Skirmisher enemy - maintains distance
class DesertBandit: BaseEnemy {
    private let preferredDistance: CGFloat = 200.0
    
    init() {
        super.init(name: "Desert Bandit", maxHealth: 40, moveSpeed: 100, damage: 7, xpValue: 18, textureName: "enemy_desert_bandit")
        setColor(.orange)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        guard isAlive else { return }
        
        // Custom movement logic to maintain distance
        let distanceToPlayer = position.distance(to: playerPosition)
        let direction = (playerPosition - position).normalized()
        
        var movementVector: CGPoint = .zero
        
        if distanceToPlayer > preferredDistance + 50 {
            // Move closer
             movementVector = direction * moveSpeed * CGFloat(deltaTime)
        } else if distanceToPlayer < preferredDistance - 50 {
            // Retreat
            movementVector = direction * -moveSpeed * CGFloat(deltaTime)
        } else {
            // Strafe / circle (can add later, for now just stand still or small jitters)
            // For simplicity, just small movement or stop
        }
        
        position = position + movementVector
        
        // Always face player
        if direction.length() > 0 {
            spriteNode.zRotation = atan2(direction.y, direction.x)
        }
    }
}
