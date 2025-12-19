//
//  ShopManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import Foundation

enum ShopUpgradeType: String, CaseIterable {
    case might = "might" // Damage
    case armor = "armor"
    case maxHealth = "maxHealth"
    case recovery = "recovery"
    case cooldown = "cooldown"
    case area = "area"
    case speed = "speed"
    case magnet = "magnet"
    case luck = "luck"
    case greed = "greed"
    
    var displayName: String {
        switch self {
        case .might: return "Might"
        case .armor: return "Armor"
        case .maxHealth: return "Max Health"
        case .recovery: return "Recovery"
        case .cooldown: return "Cooldown"
        case .area: return "Area"
        case .speed: return "Speed"
        case .magnet: return "Magnet"
        case .luck: return "Luck"
        case .greed: return "Greed"
        }
    }
    
    var description: String {
        switch self {
        case .might: return "+10% Damage"
        case .armor: return "+1 Damage Reduction"
        case .maxHealth: return "+10% Max Health"
        case .recovery: return "+0.1 HP/s Regen"
        case .cooldown: return "-2.5% Cooldown"
        case .area: return "+10% Area Size"
        case .speed: return "+10% Move Speed"
        case .magnet: return "+25% Pickup Range"
        case .luck: return "+10% Crit Chance"
        case .greed: return "+10% Gold Gain"
        }
    }
    
    var maxLevel: Int {
        switch self {
        case .recovery, .armor: return 3
        case .cooldown: return 2
        default: return 5
        }
    }
}

class ShopManager {
    static let shared = ShopManager()
    
    private init() {}
    
    func getUpgradeLevel(_ type: ShopUpgradeType) -> Int {
        return PersistenceManager.shared.getUpgradeLevel(id: type.rawValue)
    }
    
    func getCost(for type: ShopUpgradeType) -> Int {
        let level = getUpgradeLevel(type)
        guard level < type.maxLevel else { return -1 } // Maxed out
        
        // Simple cost formula: Base * (Level + 1)
        let baseCost: Int
        switch type {
        case .might, .maxHealth, .area, .speed: baseCost = 200
        case .magnet, .greed, .luck: baseCost = 300
        case .recovery, .cooldown, .armor: baseCost = 500
        }
        
        return baseCost * (level + 1)
    }
    
    func purchaseUpgrade(_ type: ShopUpgradeType) -> Bool {
        let cost = getCost(for: type)
        guard cost > 0 else { return false } // Maxed
        
        if PersistenceManager.shared.spendGold(cost) {
            let currentLevel = getUpgradeLevel(type)
            PersistenceManager.shared.setUpgradeLevel(id: type.rawValue, level: currentLevel + 1)
            return true
        }
        return false
    }
    
    func applyUpgrades(to stats: inout PlayerStats) {
        // Might
        let might = getUpgradeLevel(.might)
        stats.damageMultiplier += Float(might) * 0.1
        
        // Max Health
        let maxHP = getUpgradeLevel(.maxHealth)
        stats.maxHealth += Float(maxHP) * 0.1 * 100 // 10% of base 100
        stats.currentHealth = stats.maxHealth
        
        // Armor
        let armor = getUpgradeLevel(.armor)
        stats.damageReduction += Float(armor) * 0.05 // say 5% reduction per level instead of flat? Let's do flat reduction property check.
        // PlayerStats.damageReduction is a percentage (0.0 - 1.0).
        // If description says "+1 Damage Reduction", it usually means flat damage reduced.
        // My PlayerStats has `damageReduction` as percentage and `armor` variable.
        // Let's use `armor` variable in PlayerStats which is reduction denominator.
        stats.armor += Float(armor) * 1.0 // +1 armor value
        
        // Recovery
        let recovery = getUpgradeLevel(.recovery)
        stats.healthRegenPerSecond += Float(recovery) * 0.1
        
        // Cooldown
        let cooldown = getUpgradeLevel(.cooldown)
        stats.cooldownReduction += Float(cooldown) * 0.025
        
        // Area
        let area = getUpgradeLevel(.area)
        stats.areaMultiplier += Float(area) * 0.1
        
        // Speed
        let speed = getUpgradeLevel(.speed)
        stats.moveSpeed += Float(speed) * 0.1 * 200 // +10%
        
        // Magnet
        let magnet = getUpgradeLevel(.magnet)
        stats.pickupRadius += Float(magnet) * 0.25 * 50 // +25%
        
        // Luck
        let luck = getUpgradeLevel(.luck)
        stats.critChance += Float(luck) * 0.1
        
        // Greed
        let greed = getUpgradeLevel(.greed)
        stats.goldMultiplier += Float(greed) * 0.1
    }
}
