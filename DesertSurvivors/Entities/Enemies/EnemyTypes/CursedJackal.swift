//
//  CursedJackal.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Pack enemy - average stats, fast
class CursedJackal: BaseEnemy {
    init() {
        super.init(name: "Cursed Jackal", maxHealth: 35, moveSpeed: 140, damage: 6, xpValue: 14, textureName: "enemy_cursed_jackal")
        setColor(.purple)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
