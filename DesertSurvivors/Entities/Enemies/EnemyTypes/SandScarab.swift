//
//  SandScarab.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Basic swarmer enemy - low HP, medium speed
class SandScarab: BaseEnemy {
    init() {
        super.init(name: "Sand Scarab", maxHealth: 20, moveSpeed: 120, damage: 5, xpValue: 5, textureName: "sand_scarab")

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

