//
//  LevelUpChoiceGenerator.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation

class LevelUpChoiceGenerator {
    private var weaponFactories: [() -> BaseWeapon] = []
    private var ownedPassives: [PassiveItem] = []
    
    init() {
        // Initialize available weapons using factory closures
        weaponFactories = [
            { CurvedDagger() },
            { SandBolt() },
            { SunRay() },
            { DustDevil() }
        ]
    }
    
    func generateChoices(
        currentLevel: Int,
        currentWeapons: [BaseWeapon],
        currentPassives: [PassiveItem],
        playerStats: PlayerStats
    ) -> [LevelUpChoice] {
        var choices: [LevelUpChoice] = []
        let numChoices = Int.random(in: 3...4)
        
        // Track what we've already added to avoid duplicates
        var addedWeaponTypes: Set<String> = Set(currentWeapons.map { $0.weaponName })
        var addedPassiveTypes: Set<PassiveItemType> = Set(currentPassives.map { $0.type })
        
        // Generate choices
        while choices.count < numChoices {
            let choiceType = Int.random(in: 0...5)
            
            switch choiceType {
            case 0: // New weapon
                if currentWeapons.count < 6 {
                    if let weaponChoice = generateNewWeapon(excluding: addedWeaponTypes) {
                        choices.append(.newWeapon(weaponChoice))
                        addedWeaponTypes.insert(weaponChoice.weaponName)
                    }
                }
                
            case 1: // Weapon upgrade
                if let weapon = currentWeapons.randomElement(), weapon.level < weapon.maxLevel {
                    // Check if we already have an upgrade for this weapon
                    let alreadyHasUpgrade = choices.contains { choice in
                        if case .weaponUpgrade(let w) = choice {
                            return w === weapon
                        }
                        return false
                    }
                    if !alreadyHasUpgrade {
                        choices.append(.weaponUpgrade(weapon))
                    }
                }
                
            case 2: // New passive
                if let passiveChoice = generateNewPassive(excluding: addedPassiveTypes) {
                    choices.append(.newPassive(passiveChoice))
                    addedPassiveTypes.insert(passiveChoice.type)
                }
                
            case 3: // Passive upgrade
                if let passive = currentPassives.randomElement(), passive.level < passive.maxLevel {
                    // Check if we already have an upgrade for this passive
                    let alreadyHasUpgrade = choices.contains { choice in
                        if case .passiveUpgrade(let p) = choice {
                            return p === passive
                        }
                        return false
                    }
                    if !alreadyHasUpgrade {
                        choices.append(.passiveUpgrade(passive))
                    }
                }
                
            case 4: // Gold
                let goldAmount = currentLevel * 10 + Int.random(in: 0...20)
                choices.append(.gold(goldAmount))
                
            case 5: // Health restore
                let healAmount = playerStats.maxHealth * 0.25
                choices.append(.healthRestore(healAmount))
                
            default:
                break
            }
            
            // Prevent infinite loop
            if choices.count >= numChoices {
                break
            }
        }
        
        // Fill remaining slots with fallback options
        while choices.count < numChoices {
            if currentWeapons.count < 6 {
                if let weapon = generateNewWeapon(excluding: addedWeaponTypes) {
                    choices.append(.newWeapon(weapon))
                    addedWeaponTypes.insert(weapon.weaponName)
                } else {
                    choices.append(.gold(currentLevel * 10))
                }
            } else if let weapon = currentWeapons.randomElement(), weapon.level < weapon.maxLevel {
                choices.append(.weaponUpgrade(weapon))
            } else {
                choices.append(.gold(currentLevel * 10))
            }
        }
        
        return Array(choices.prefix(numChoices))
    }
    
    private func generateNewWeapon(excluding: Set<String>) -> BaseWeapon? {
        // Get available weapons that aren't already owned
        let available = weaponFactories.compactMap { factory -> BaseWeapon? in
            let weapon = factory()
            return excluding.contains(weapon.weaponName) ? nil : weapon
        }
        
        return available.randomElement()
    }
    
    private func generateNewPassive(excluding: Set<PassiveItemType>) -> PassiveItem? {
        let allPassives = PassiveItemType.allCases
        let available = allPassives.filter { !excluding.contains($0) }
        
        if let randomType = available.randomElement() {
            return PassiveItem(type: randomType)
        }
        return nil
    }
}

