//
//  Scorpion.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Slow, tanky, poison attack
class Scorpion: BaseEnemy {
    init() {
        super.init(name: "Scorpion", maxHealth: 30, moveSpeed: 80, damage: 8, xpValue: 8, textureName: "scorpion")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

