//
//  DesertRat.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

/// Fast, very low HP, comes in groups
class DesertRat: BaseEnemy {
    override var animationFrameCount: Int { 8 }

    init() {
        super.init(name: "Desert Rat", maxHealth: 10, moveSpeed: 180, damage: 3, xpValue: 3, textureName: "desert_rat")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

