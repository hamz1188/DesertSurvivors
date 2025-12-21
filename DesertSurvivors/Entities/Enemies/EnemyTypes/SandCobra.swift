//
//  SandCobra.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Fast enemy - low HP, high speed, lunging attacks
class SandCobra: BaseEnemy {
    private var attackTimer: TimeInterval = 0
    private let lungeCooldown: TimeInterval = 2.0
    private let lungeSpeedMultiplier: CGFloat = 2.5
    private var isLunging = false
    
    init() {
        super.init(name: "Sand Cobra", maxHealth: 25, moveSpeed: 160, damage: 8, xpValue: 12, textureName: "sand_cobra")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition)
        
        // Simple lunge logic
        attackTimer += deltaTime
        if attackTimer >= lungeCooldown && !isLunging {
            // Lunge!
            isLunging = true
            let originalSpeed = moveSpeed
            moveSpeed *= lungeSpeedMultiplier
            
            // Reset speed after short duration
            let wait = SKAction.wait(forDuration: 0.5)
            let reset = SKAction.run { [weak self] in
                self?.moveSpeed = originalSpeed
                self?.isLunging = false
            }
            run(SKAction.sequence([wait, reset]))
            
            attackTimer = 0
        }
    }
}
