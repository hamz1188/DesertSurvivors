//
//  CharacterData.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import Foundation

enum CharacterType: String, CaseIterable, Codable {
    case tariq // The Wanderer
    case amara // The Nomad (Speed)
    case zahra // The Mage (Area/Magic)
    
    var displayName: String {
        switch self {
        case .tariq: return "Tariq"
        case .amara: return "Amara"
        case .zahra: return "Zahra"
        }
    }
    
    var title: String {
        switch self {
        case .tariq: return "The Wanderer"
        case .amara: return "The Nomad"
        case .zahra: return "The Mage"
        }
    }
    
    var description: String {
        switch self {
        case .tariq: return "A balanced survivor seeking the truth of the sands."
        case .amara: return "Swift as the wind, but fragile. Moves 20% faster."
        case .zahra: return "Master of elements. +20% Area, -10 Armor."
        }
    }
    
    var unlockConditionText: String {
        switch self {
        case .tariq: return "Unlocked"
        case .amara: return "Unlock: Survive 5 minutes in a single run."
        case .zahra: return "Unlock: Reach 1000 Total Kills."
        }
    }
    
    // Apply stats modifier to base stats
    func applyBaseStats(to stats: inout PlayerStats) {
        switch self {
        case .tariq:
            break // Baseline
        case .amara:
            stats.moveSpeed *= 1.2
            stats.maxHealth *= 0.8
            stats.currentHealth = stats.maxHealth
        case .zahra:
            stats.areaMultiplier += 0.2
            stats.cooldownReduction += 0.1
            stats.armor -= 10
        }
    }
}
