//
//  MummifiedWanderer.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Tanky enemy - high HP, slow speed
class MummifiedWanderer: BaseEnemy {
    init() {
        super.init(name: "Mummified Wanderer", maxHealth: 60, moveSpeed: 50, damage: 10, xpValue: 15, textureName: "enemy_mummified_wanderer")
        setColor(.gray) // Visual distinction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
