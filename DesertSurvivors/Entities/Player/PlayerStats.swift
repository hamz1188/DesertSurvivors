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
    var cooldownReduction: Float = 0 // percentage (0.0 - 1.0)
    var damageMultiplier: Float = 1.0
    var projectileSpeed: Float = 1.0
    var projectileCount: Int = 0 // bonus projectiles
    var areaMultiplier: Float = 1.0
    var duration: Float = 1.0 // effect duration multiplier
    var revival: Int = 0 // extra lives
    var reroll: Int = 0 // reroll level-up choices
    var skip: Int = 0 // skip level-up choices
    var banish: Int = 0 // remove options permanently
    
    // New stats for passive items
    var healthRegenPerSecond: Float = 0 // HP regeneration per second
    var goldMultiplier: Float = 1.0 // gold drop multiplier
    var dodgeChance: Float = 0 // chance to avoid damage (0.0 - 1.0)
    var burnChance: Float = 0 // chance to burn enemies on hit
    var lifesteal: Float = 0 // percentage of damage healed (0.0 - 1.0)
    var poisonChance: Float = 0 // chance to poison enemies on hit
    var critChance: Float = 0 // critical hit chance (0.0 - 1.0)
    var critMultiplier: Float = 2.0 // critical hit damage multiplier
    var attackSpeedMultiplier: Float = 1.0 // attack speed multiplier
    var damageReduction: Float = 0 // flat damage reduction percentage (0.0 - 1.0)
    
    mutating func takeDamage(_ amount: Float) -> Bool {
        // Check dodge chance first
        if dodgeChance > 0 && Float.random(in: 0...1) < dodgeChance {
            // Dodged! Take no damage
            return false
        }
        
        // Apply armor reduction
        let damageAfterArmor = amount * (1.0 - armor / (armor + 100.0))
        
        // Apply flat damage reduction
        let finalDamage = damageAfterArmor * (1.0 - damageReduction)
        
        currentHealth = max(0, currentHealth - finalDamage)
        return true
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
    
    /// Calculate damage with critical hit chance
    func calculateDamage(baseDamage: Float) -> Float {
        var damage = baseDamage * damageMultiplier
        
        // Check for critical hit
        if critChance > 0 && Float.random(in: 0...1) < critChance {
            damage *= critMultiplier
        }
        
        return damage
    }
}

