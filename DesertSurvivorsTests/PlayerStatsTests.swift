//
//  PlayerStatsTests.swift
//  DesertSurvivorsTests
//
//  Created by Ahmed AlHameli on 21/12/2025.
//

import Testing
@testable import DesertSurvivors

struct PlayerStatsTests {
    
    // MARK: - Damage Calculation Tests
    
    @Test func testBaseDamageNoModifiers() {
        let stats = PlayerStats()
        let damage = stats.calculateDamage(baseDamage: 100)
        
        // With default stats (no crit, 1.0 multiplier), damage should be 100
        #expect(damage == 100)
    }
    
    @Test func testDamageWithMultiplier() {
        var stats = PlayerStats()
        stats.damageMultiplier = 1.5
        stats.critChance = 0 // Disable crit for this test
        
        let damage = stats.calculateDamage(baseDamage: 100)
        #expect(damage == 150)
    }
    
    // MARK: - Armor Tests
    
    @Test func testArmorReducesDamage() {
        var stats = PlayerStats()
        stats.armor = 50
        stats.dodgeChance = 0 // Disable dodge
        stats.damageReduction = 0
        
        let initialHealth = stats.currentHealth
        let wasDamaged = stats.takeDamage(100)
        
        #expect(wasDamaged == true)
        
        // Armor formula: damage * (1 - armor/(armor+100))
        // With 50 armor: 100 * (1 - 50/150) = 100 * 0.667 = 66.67
        let expectedDamage: Float = 100 * (1.0 - 50.0 / 150.0)
        let actualDamage = initialHealth - stats.currentHealth
        
        #expect(abs(actualDamage - expectedDamage) < 0.1)
    }
    
    @Test func testDamageReduction() {
        var stats = PlayerStats()
        stats.armor = 0
        stats.dodgeChance = 0
        stats.damageReduction = 0.25 // 25% reduction
        
        let initialHealth = stats.currentHealth
        _ = stats.takeDamage(100)
        
        // With 25% reduction: 100 * 0.75 = 75 damage
        let actualDamage = initialHealth - stats.currentHealth
        #expect(abs(actualDamage - 75) < 0.1)
    }
    
    // MARK: - Dodge Tests
    
    @Test func testFullDodgeChancePreventsAllDamage() {
        var stats = PlayerStats()
        stats.dodgeChance = 1.0 // 100% dodge
        
        let initialHealth = stats.currentHealth
        let wasDamaged = stats.takeDamage(100)
        
        #expect(wasDamaged == false, "Should have dodged")
        #expect(stats.currentHealth == initialHealth, "Health should not change on dodge")
    }
    
    @Test func testZeroDodgeChanceAlwaysTakesDamage() {
        var stats = PlayerStats()
        stats.dodgeChance = 0
        stats.armor = 0
        stats.damageReduction = 0
        
        let initialHealth = stats.currentHealth
        let wasDamaged = stats.takeDamage(50)
        
        #expect(wasDamaged == true)
        #expect(stats.currentHealth == initialHealth - 50)
    }
    
    // MARK: - Health Tests
    
    @Test func testHealingCapsAtMaxHealth() {
        var stats = PlayerStats()
        stats.maxHealth = 100
        stats.currentHealth = 80
        
        stats.heal(50) // Try to heal 50, but only 20 room
        
        #expect(stats.currentHealth == 100, "Health should not exceed max")
    }
    
    @Test func testHealingFromLowHealth() {
        var stats = PlayerStats()
        stats.maxHealth = 100
        stats.currentHealth = 10
        
        stats.heal(30)
        
        #expect(stats.currentHealth == 40)
    }
    
    @Test func testHealthPercentage() {
        var stats = PlayerStats()
        stats.maxHealth = 100
        stats.currentHealth = 75
        
        #expect(stats.healthPercentage == 0.75)
    }
    
    @Test func testIsAlive() {
        var stats = PlayerStats()
        stats.currentHealth = 1
        #expect(stats.isAlive == true)
        
        stats.currentHealth = 0
        #expect(stats.isAlive == false)
    }
    
    // MARK: - Damage Floor
    
    @Test func testHealthCannotGoBelowZero() {
        var stats = PlayerStats()
        stats.currentHealth = 10
        stats.armor = 0
        stats.dodgeChance = 0
        
        _ = stats.takeDamage(1000)
        
        #expect(stats.currentHealth == 0, "Health should not go negative")
    }
}
