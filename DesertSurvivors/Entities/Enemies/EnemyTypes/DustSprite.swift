//
//  DustSprite.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Floats, low HP, ranged sand attack
class DustSprite: BaseEnemy {
    init() {
        super.init(name: "Dust Sprite", maxHealth: 15, moveSpeed: 100, damage: 4, xpValue: 6, textureName: "enemy_dust_sprite")
        setColor(SKColor(red: 0.9, green: 0.8, blue: 0.5, alpha: 1.0)) // Sandy yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

