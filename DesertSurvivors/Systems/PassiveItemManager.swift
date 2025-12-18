//
//  PassiveItemManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation

class PassiveItemManager {
    private var ownedPassives: [PassiveItem] = []
    
    func addPassive(_ item: PassiveItem) {
        ownedPassives.append(item)
    }
    
    func upgradePassive(_ item: PassiveItem) {
        item.upgrade()
    }
    
    func getPassives() -> [PassiveItem] {
        return ownedPassives
    }
    
    func applyAllEffects(to stats: inout PlayerStats) {
        for passive in ownedPassives {
            passive.applyEffect(to: &stats)
        }
    }
    
    func hasPassive(_ type: PassiveItemType) -> Bool {
        return ownedPassives.contains { $0.type == type }
    }
}

