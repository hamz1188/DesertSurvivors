//
//  SandScarab.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SandScarab: BaseEnemy {
    init() {
        super.init(name: "Sand Scarab", maxHealth: 20, moveSpeed: 120, damage: 5)
        spriteNode?.color = .brown
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

