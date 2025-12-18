//
//  Scorpion.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Scorpion: BaseEnemy {
    init() {
        super.init(name: "Scorpion", maxHealth: 30, moveSpeed: 80, damage: 8)
        spriteNode?.color = .darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

