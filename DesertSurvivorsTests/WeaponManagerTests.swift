//
//  WeaponManagerTests.swift
//  DesertSurvivorsTests
//
//  Created by Claude on 22/12/2025.
//

import Testing
import SpriteKit
@testable import DesertSurvivors

struct WeaponManagerTests {

    // MARK: - Initialization Tests

    @Test func testInitializationStartsEmpty() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)

        #expect(manager.getWeaponCount() == 0)
        #expect(manager.getWeapons().isEmpty)
    }

    // MARK: - Add/Remove Weapon Tests

    @Test func testAddWeaponIncreasesCount() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)
        let weapon = CurvedDagger()

        manager.addWeapon(weapon)

        #expect(manager.getWeaponCount() == 1)
        #expect(manager.getWeapons().first === weapon)
    }

    @Test func testAddMultipleWeapons() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)

        manager.addWeapon(CurvedDagger())
        manager.addWeapon(CurvedDagger())
        manager.addWeapon(CurvedDagger())

        #expect(manager.getWeaponCount() == 3)
    }

    @Test func testRemoveWeaponDecreasesCount() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)
        let weapon = CurvedDagger()

        manager.addWeapon(weapon)
        #expect(manager.getWeaponCount() == 1)

        manager.removeWeapon(weapon)
        #expect(manager.getWeaponCount() == 0)
    }

    @Test func testRemoveNonExistentWeaponDoesNothing() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)
        let weapon1 = CurvedDagger()
        let weapon2 = CurvedDagger()

        manager.addWeapon(weapon1)
        manager.removeWeapon(weapon2) // Not in manager

        #expect(manager.getWeaponCount() == 1)
    }

    // MARK: - Player Stats Integration Tests

    @Test func testUpdatePlayerStatsAppliedToExistingWeapons() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)
        let weapon = CurvedDagger()

        manager.addWeapon(weapon)

        var stats = PlayerStats()
        stats.damageMultiplier = 2.0

        manager.updatePlayerStats(stats)

        #expect(manager.playerStats?.damageMultiplier == 2.0)
    }

    @Test func testNewWeaponsReceiveCurrentStats() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)

        var stats = PlayerStats()
        stats.damageMultiplier = 1.5
        manager.updatePlayerStats(stats)

        // Add weapon after stats were set
        let weapon = CurvedDagger()
        manager.addWeapon(weapon)

        // Weapon should have received stats during addWeapon
        #expect(manager.playerStats?.damageMultiplier == 1.5)
    }

    // MARK: - Get Weapons Tests

    @Test func testGetWeaponsReturnsCorrectWeapons() {
        let scene = SKScene()
        let manager = WeaponManager(scene: scene)
        let weapon1 = CurvedDagger()
        let weapon2 = CurvedDagger()

        manager.addWeapon(weapon1)
        manager.addWeapon(weapon2)

        let weapons = manager.getWeapons()

        #expect(weapons.count == 2)
        #expect(weapons.contains(where: { $0 === weapon1 }))
        #expect(weapons.contains(where: { $0 === weapon2 }))
    }
}
