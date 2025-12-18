//
//  PassiveItem.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation

enum PassiveItemType: String, CaseIterable {
    // Offensive
    case sharpenedSteel = "Sharpened Steel"
    case swiftHands = "Swift Hands"
    case eagleEye = "Eagle Eye"
    case expansiveForce = "Expansive Force"
    case lastingEffect = "Lasting Effect"
    
    // Defensive
    case desertArmor = "Desert Armor"
    case oasisHeart = "Oasis Heart"
    case secondWind = "Second Wind"
    case mirageStep = "Mirage Step"
    
    // Utility
    case magneticCharm = "Magnetic Charm"
    case fortunesFavor = "Fortune's Favor"
    case scholarsMind = "Scholar's Mind"
    case merchantsEye = "Merchant's Eye"
    
    // Evolution Items
    case sandstormCloak = "Sandstorm Cloak"
    case djinnLamp = "Djinn Lamp"
    case scarabAmulet = "Scarab Amulet"
    case venomVial = "Venom Vial"
    case mirrorOfTruth = "Mirror of Truth"
    case eagleFeather = "Eagle Feather"
    case desertRose = "Desert Rose"
    case canopicJar = "Canopic Jar"
    case hourglass = "Hourglass"
}

class PassiveItem {
    let type: PassiveItemType
    var level: Int = 1
    let maxLevel: Int = 5
    
    var name: String {
        return type.rawValue
    }
    
    var description: String {
        switch type {
        case .sharpenedSteel:
            return "+\(level * 10)% damage"
        case .swiftHands:
            return "+\(level * 8)% cooldown reduction"
        case .eagleEye:
            return "+\(level * 10)% projectile speed"
        case .expansiveForce:
            return "+\(level * 10)% area"
        case .lastingEffect:
            return "+\(level * 10)% duration"
        case .desertArmor:
            return "+\(level * 5) armor"
        case .oasisHeart:
            return "+\(level * 20) max HP"
        case .secondWind:
            return "+\(Float(level) * 0.5) HP/s regeneration"
        case .mirageStep:
            return "+\(level * 10)% move speed"
        case .magneticCharm:
            return "+\(level * 20)% pickup radius"
        case .fortunesFavor:
            return "+\(level * 10)% luck"
        case .scholarsMind:
            return "+\(level * 10)% experience"
        case .merchantsEye:
            return "+\(level * 15)% gold"
        case .sandstormCloak:
            return "+\(level * 5)% dodge chance"
        case .djinnLamp:
            return "+\(level * 5)% damage, chance to burn"
        case .scarabAmulet:
            return "+\(level * 3)% lifesteal"
        case .venomVial:
            return "Attacks have chance to poison"
        case .mirrorOfTruth:
            return "+\(level * 5)% critical chance"
        case .eagleFeather:
            return "+\(level * 5)% attack speed"
        case .desertRose:
            return "+\(level * 10) HP, +\(level * 5)% damage reduction"
        case .canopicJar:
            return "Enemies drop +\(level * 10)% more XP"
        case .hourglass:
            return "+\(level * 8)% to all time-based effects"
        }
    }
    
    init(type: PassiveItemType) {
        self.type = type
    }
    
    func upgrade() {
        guard level < maxLevel else { return }
        level += 1
    }
    
    func applyEffect(to stats: inout PlayerStats) {
        switch type {
        case .sharpenedSteel:
            stats.damageMultiplier += Float(level) * 0.1
        case .swiftHands:
            stats.cooldownReduction += Float(level) * 0.08
        case .eagleEye:
            stats.projectileSpeed += Float(level) * 0.1
        case .expansiveForce:
            stats.areaMultiplier += Float(level) * 0.1
        case .lastingEffect:
            stats.duration += Float(level) * 0.1
        case .desertArmor:
            stats.armor += Float(level) * 5
        case .oasisHeart:
            stats.maxHealth += Float(level) * 20
            stats.currentHealth += Float(level) * 20 // Also heal
        case .secondWind:
            stats.healthRegenPerSecond += Float(level) * 0.5
        case .mirageStep:
            stats.moveSpeed += Float(level) * 0.1 * 200 // 10% of base speed
        case .magneticCharm:
            stats.pickupRadius += Float(level) * 0.2 * 50 // 20% of base radius
        case .fortunesFavor:
            stats.luck += Float(level) * 0.1
        case .scholarsMind:
            stats.experienceMultiplier += Float(level) * 0.1
        case .merchantsEye:
            stats.goldMultiplier += Float(level) * 0.15
        case .sandstormCloak:
            stats.dodgeChance += Float(level) * 0.05
        case .djinnLamp:
            stats.damageMultiplier += Float(level) * 0.05
            stats.burnChance += Float(level) * 0.05
        case .scarabAmulet:
            stats.lifesteal += Float(level) * 0.03
        case .venomVial:
            stats.poisonChance += Float(level) * 0.1
        case .mirrorOfTruth:
            stats.critChance += Float(level) * 0.05
        case .eagleFeather:
            stats.attackSpeedMultiplier += Float(level) * 0.05
        case .desertRose:
            stats.maxHealth += Float(level) * 10
            stats.currentHealth += Float(level) * 10
            stats.damageReduction += Float(level) * 0.05
        case .canopicJar:
            stats.experienceMultiplier += Float(level) * 0.1
        case .hourglass:
            stats.duration += Float(level) * 0.08
        }
    }
    
    /// Returns the regeneration bonus for Second Wind passive
    func getHealthRegen() -> Float {
        if type == .secondWind {
            return Float(level) * 0.5
        }
        return 0
    }
}

