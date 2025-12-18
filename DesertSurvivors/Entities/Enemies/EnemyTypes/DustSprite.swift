//
//  DustSprite.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class DustSprite: BaseEnemy {
    init() {
        super.init(name: "Dust Sprite", maxHealth: 15, moveSpeed: 100, damage: 4)
        spriteNode?.color = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

