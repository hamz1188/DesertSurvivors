//
//  PersistenceManagerTests.swift
//  DesertSurvivorsTests
//
//  Created by Claude on 22/12/2025.
//

import Testing
import Foundation
@testable import DesertSurvivors

// Run tests serially since they share PersistenceManager.shared singleton
@Suite(.serialized)
struct PersistenceManagerTests {

    // Helper to get a clean manager state
    private func cleanManager() -> PersistenceManager {
        let manager = PersistenceManager.shared
        manager.resetData()
        return manager
    }

    // MARK: - PlayerData Struct Tests

    @Test func testPlayerDataDefaultValues() {
        let data = PlayerData()

        #expect(data.totalGold == 0)
        #expect(data.lifetimeGoldCollected == 0)
        #expect(data.upgrades.isEmpty)
        #expect(data.unlockedCharacters == ["tariq"])
        #expect(data.unlockedAchievements.isEmpty)
        #expect(data.totalKills == 0)
        #expect(data.maxTimeSurvived == 0)
        #expect(data.highScores.isEmpty)
    }

    @Test func testPlayerDataCodable() throws {
        var data = PlayerData()
        data.totalGold = 500
        data.lifetimeGoldCollected = 1000
        data.upgrades = ["speed": 3, "damage": 2]
        data.unlockedCharacters = ["tariq", "amara"]
        data.totalKills = 250
        data.maxTimeSurvived = 300

        let encoder = JSONEncoder()
        let encoded = try encoder.encode(data)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerData.self, from: encoded)

        #expect(decoded.totalGold == 500)
        #expect(decoded.lifetimeGoldCollected == 1000)
        #expect(decoded.upgrades["speed"] == 3)
        #expect(decoded.upgrades["damage"] == 2)
        #expect(decoded.unlockedCharacters.contains("amara"))
        #expect(decoded.totalKills == 250)
        #expect(decoded.maxTimeSurvived == 300)
    }

    // MARK: - Gold Management Tests

    @Test func testAddGoldIncreasesTotalAndLifetime() {
        let manager = cleanManager()

        #expect(manager.data.totalGold == 0)
        #expect(manager.data.lifetimeGoldCollected == 0)

        manager.addGold(100)

        #expect(manager.data.totalGold == 100)
        #expect(manager.data.lifetimeGoldCollected == 100)
    }

    @Test func testSpendGoldSucceedsWithSufficientFunds() {
        let manager = cleanManager()
        manager.addGold(200)

        let success = manager.spendGold(100)

        #expect(success == true)
        #expect(manager.data.totalGold == 100)
    }

    @Test func testSpendGoldFailsWithInsufficientFunds() {
        let manager = cleanManager()
        manager.addGold(50)

        let success = manager.spendGold(100)

        #expect(success == false)
        #expect(manager.data.totalGold == 50) // Unchanged
    }

    @Test func testSpendGoldDoesNotAffectLifetimeGold() {
        let manager = cleanManager()
        manager.addGold(200)

        let lifetimeBefore = manager.data.lifetimeGoldCollected
        _ = manager.spendGold(100)

        #expect(manager.data.lifetimeGoldCollected == lifetimeBefore)
    }

    // MARK: - Upgrade Tests

    @Test func testGetUpgradeLevelReturnsZeroForUnset() {
        let manager = cleanManager()

        let level = manager.getUpgradeLevel(id: "nonexistent_upgrade")

        #expect(level == 0)
    }

    @Test func testSetAndGetUpgradeLevel() {
        let manager = cleanManager()

        manager.setUpgradeLevel(id: "speed", level: 5)
        let level = manager.getUpgradeLevel(id: "speed")

        #expect(level == 5)
    }

    @Test func testUpgradeLevelCanBeUpdated() {
        let manager = cleanManager()

        manager.setUpgradeLevel(id: "damage", level: 1)
        manager.setUpgradeLevel(id: "damage", level: 3)

        #expect(manager.getUpgradeLevel(id: "damage") == 3)
    }

    // MARK: - Character Unlock Tests

    @Test func testTariqUnlockedByDefault() {
        let manager = cleanManager()

        #expect(manager.isCharacterUnlocked("tariq") == true)
    }

    @Test func testUnlockCharacter() {
        let manager = cleanManager()

        #expect(manager.isCharacterUnlocked("amara") == false)

        manager.unlockCharacter("amara")

        #expect(manager.isCharacterUnlocked("amara") == true)
    }

    @Test func testUnlockCharacterIdemptent() {
        let manager = cleanManager()

        manager.unlockCharacter("zahra")
        manager.unlockCharacter("zahra")
        manager.unlockCharacter("zahra")

        // Should only appear once
        let count = manager.data.unlockedCharacters.filter { $0 == "zahra" }.count
        #expect(count == 1)
    }

    // MARK: - Achievement Tests

    @Test func testUnlockAchievementReturnsTrue() {
        let manager = cleanManager()

        let result = manager.unlockAchievement("first_kill")

        #expect(result == true)
        #expect(manager.data.unlockedAchievements.contains("first_kill"))
    }

    @Test func testUnlockAchievementReturnsFalseIfAlreadyUnlocked() {
        let manager = cleanManager()

        _ = manager.unlockAchievement("survivor")
        let result = manager.unlockAchievement("survivor")

        #expect(result == false)
    }

    // MARK: - Progression Tests

    @Test func testUpdateProgressionTracksKills() {
        let manager = cleanManager()

        manager.updateProgression(runKills: 50, runTime: 100)
        manager.updateProgression(runKills: 30, runTime: 50)

        #expect(manager.data.totalKills == 80)
    }

    @Test func testUpdateProgressionTracksMaxTime() {
        let manager = cleanManager()

        manager.updateProgression(runKills: 10, runTime: 200)
        manager.updateProgression(runKills: 10, runTime: 100)

        #expect(manager.data.maxTimeSurvived == 200) // Should keep max, not overwrite
    }

    @Test func testUpdateProgressionUpdatesMaxTime() {
        let manager = cleanManager()

        manager.updateProgression(runKills: 10, runTime: 100)
        manager.updateProgression(runKills: 10, runTime: 250)

        #expect(manager.data.maxTimeSurvived == 250)
    }

    // MARK: - Auto-Unlock Tests

    @Test func testAmaraUnlocksAfter5Minutes() {
        let manager = cleanManager()

        #expect(manager.isCharacterUnlocked(CharacterType.amara.rawValue) == false)

        manager.updateProgression(runKills: 0, runTime: 300) // 5 minutes

        #expect(manager.isCharacterUnlocked(CharacterType.amara.rawValue) == true)
    }

    @Test func testZahraUnlocksAfter1000Kills() {
        let manager = cleanManager()

        #expect(manager.isCharacterUnlocked(CharacterType.zahra.rawValue) == false)

        // Accumulate 1000 kills over multiple runs
        manager.updateProgression(runKills: 500, runTime: 100)
        manager.updateProgression(runKills: 500, runTime: 100)

        #expect(manager.isCharacterUnlocked(CharacterType.zahra.rawValue) == true)
    }

    // MARK: - Reset Tests

    @Test func testResetDataRestoresDefaults() {
        let manager = cleanManager()

        // Modify state
        manager.addGold(9999)
        manager.setUpgradeLevel(id: "test", level: 10)
        manager.unlockCharacter("test_char")

        // Reset
        manager.resetData()

        #expect(manager.data.totalGold == 0)
        #expect(manager.data.lifetimeGoldCollected == 0)
        #expect(manager.data.upgrades.isEmpty)
        #expect(manager.data.unlockedCharacters == ["tariq"])
        #expect(manager.data.totalKills == 0)
    }
}
