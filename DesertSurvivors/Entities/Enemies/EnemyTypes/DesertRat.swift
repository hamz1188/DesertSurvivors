//
//  DesertRat.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DesertRat: BaseEnemy {
    init() {
        super.init(name: "Desert Rat", maxHealth: 10, moveSpeed: 180, damage: 3)
        spriteNode?.color = .gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

