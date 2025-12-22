//
//  DustSprite.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Floats, low HP, ranged sand attack
class DustSprite: BaseEnemy {
    // Only 1 frame per direction (static sprite, animation failed to generate)
    override var animationFrameCount: Int { 1 }

    init() {
        super.init(name: "Dust Sprite", maxHealth: 15, moveSpeed: 100, damage: 4, xpValue: 6, textureName: "dust_sprite")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

