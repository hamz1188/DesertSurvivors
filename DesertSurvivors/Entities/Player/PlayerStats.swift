//
//  PlayerStats.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation

struct PlayerStats {
    var maxHealth: Float = 100
    var currentHealth: Float = 100
    var moveSpeed: Float = 200 // points per second
    var armor: Float = 0 // damage reduction
    var luck: Float = 1.0 // affects drop rates
    var pickupRadius: Float = 50
    var experienceMultiplier: Float = 1.0
    var cooldownReduction: Float = 0 // percentage
    var damageMultiplier: Float = 1.0
    var projectileSpeed: Float = 1.0
    var projectileCount: Int = 0 // bonus projectiles
    var areaMultiplier: Float = 1.0
    var duration: Float = 1.0 // effect duration multiplier
    var revival: Int = 0 // extra lives
    var reroll: Int = 0 // reroll level-up choices
    var skip: Int = 0 // skip level-up choices
    var banish: Int = 0 // remove options permanently
    
    mutating func takeDamage(_ amount: Float) {
        let damageAfterArmor = amount * (1.0 - armor / (armor + 100.0))
        currentHealth = max(0, currentHealth - damageAfterArmor)
    }
    
    mutating func heal(_ amount: Float) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }
    
    var healthPercentage: Float {
        return currentHealth / maxHealth
    }
    
    var isAlive: Bool {
        return currentHealth > 0
    }
}

