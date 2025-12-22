//
//  PersistenceManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import Foundation
import os.log

struct PlayerData: Codable {
    /// Schema version for data migration support
    var schemaVersion: Int = PlayerData.currentSchemaVersion

    var totalGold: Int = 0
    var lifetimeGoldCollected: Int = 0 // Total gold ever collected (for achievements)
    var upgrades: [String: Int] = [:] // UpgradeID: Level
    var unlockedCharacters: [String] = ["tariq"]
    var unlockedAchievements: [String] = []
    var totalKills: Int = 0
    var maxTimeSurvived: TimeInterval = 0
    var highScores: [Int] = [] // Top 10 scores?

    // MARK: - Schema Versioning

    /// Current schema version - increment when making breaking changes
    static let currentSchemaVersion = 1

    /// Migrates data from older schema versions to current
    mutating func migrateIfNeeded() {
        // Example migration logic for future versions:
        // if schemaVersion < 2 {
        //     // Migrate from v1 to v2
        //     schemaVersion = 2
        // }

        // Ensure we're at current version
        schemaVersion = PlayerData.currentSchemaVersion
    }
}

class PersistenceManager {
    static let shared = PersistenceManager()

    private let fileName = "playerData.encrypted"
    private let legacyFileName = "playerData.json"
    private(set) var data: PlayerData

    /// Whether to use encryption (can be disabled for debugging)
    var encryptionEnabled: Bool = true

    private let logger = Logger(subsystem: "com.desertsurvivors", category: "PersistenceManager")

    private init() {
        self.data = PlayerData()
        load()
    }

    // MARK: - Save & Load

    private var fileURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documents.appendingPathComponent(fileName)
    }

    private var legacyFileURL: URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documents.appendingPathComponent(legacyFileName)
    }

    func save() {
        guard let url = fileURL else {
            logger.error("Failed to get file URL for saving")
            return
        }

        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)

            let dataToWrite: Data
            if encryptionEnabled {
                dataToWrite = try DataEncryption.shared.encrypt(jsonData)
            } else {
                dataToWrite = jsonData
            }

            // Write with file protection
            try dataToWrite.write(to: url, options: [.atomic, .completeFileProtection])
            logger.debug("Data saved successfully (encrypted: \(self.encryptionEnabled))")
        } catch {
            logger.error("Failed to save data: \(error.localizedDescription)")
            #if DEBUG
            assertionFailure("Failed to save data: \(error)")
            #endif
        }
    }

    func load() {
        // First try to load encrypted data
        if let url = fileURL, FileManager.default.fileExists(atPath: url.path) {
            loadEncrypted(from: url)
            return
        }

        // Try to migrate from legacy unencrypted file
        if let legacyURL = legacyFileURL, FileManager.default.fileExists(atPath: legacyURL.path) {
            logger.info("Migrating from legacy unencrypted save file")
            loadLegacy(from: legacyURL)

            // Re-save with encryption and delete legacy file
            save()
            try? FileManager.default.removeItem(at: legacyURL)
            return
        }

        // No saved data - start fresh
        data = PlayerData()
        logger.info("No saved data found, starting fresh")
    }

    private func loadEncrypted(from url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            let jsonData: Data

            if encryptionEnabled {
                jsonData = try DataEncryption.shared.decrypt(fileData)
            } else {
                jsonData = fileData
            }

            let decoder = JSONDecoder()
            data = try decoder.decode(PlayerData.self, from: jsonData)

            // Run migrations if needed
            data.migrateIfNeeded()

            logger.debug("Data loaded successfully (version: \(self.data.schemaVersion))")
        } catch {
            logger.error("Failed to load encrypted data: \(error.localizedDescription)")
            data = PlayerData()
        }
    }

    private func loadLegacy(from url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            data = try decoder.decode(PlayerData.self, from: fileData)
            data.migrateIfNeeded()
            logger.info("Legacy data migrated successfully")
        } catch {
            logger.error("Failed to load legacy data: \(error.localizedDescription)")
            data = PlayerData()
        }
    }
    
    // MARK: - Accessors
    
    func addGold(_ amount: Int) {
        // Validate gold amount to prevent negative values or overflow
        let validatedAmount = InputValidation.validateGold(amount)
        data.totalGold = InputValidation.validateGold(data.totalGold + validatedAmount)
        data.lifetimeGoldCollected = InputValidation.validateGold(data.lifetimeGoldCollected + validatedAmount)
        save()
    }
    
    /// Spend gold (legacy Bool-based API for backward compatibility)
    func spendGold(_ amount: Int) -> Bool {
        switch trySpendGold(amount) {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Spend gold with type-safe error handling
    /// - Parameter amount: The amount of gold to spend
    /// - Returns: Result with remaining gold on success, or ShopError on failure
    func trySpendGold(_ amount: Int) -> ShopResult<Int> {
        guard data.totalGold >= amount else {
            return .failure(.insufficientGold(required: amount, available: data.totalGold))
        }
        data.totalGold -= amount
        save()
        return .success(data.totalGold)
    }
    
    func getUpgradeLevel(id: String) -> Int {
        return data.upgrades[id] ?? 0
    }
    
    func setUpgradeLevel(id: String, level: Int) {
        data.upgrades[id] = level
        save()
    }
    
    func unlockCharacter(_ id: String) {
        if !data.unlockedCharacters.contains(id) {
            data.unlockedCharacters.append(id)
            save()
        }
    }
    
    func isCharacterUnlocked(_ id: String) -> Bool {
        return data.unlockedCharacters.contains(id)
    }
    
    func unlockAchievement(_ id: String) -> Bool {
        if !data.unlockedAchievements.contains(id) {
            data.unlockedAchievements.append(id)
            save()
            return true // Newly unlocked
        }
        return false // Already unlocked
    }
    
    func updateProgression(runKills: Int, runTime: TimeInterval) {
        data.totalKills += runKills
        if runTime > data.maxTimeSurvived {
            data.maxTimeSurvived = runTime
        }
        
        checkUnlocks(runTime: runTime)
        save()
    }
    
    func resetData() {
        data = PlayerData(totalGold: 0, lifetimeGoldCollected: 0, upgrades: [:], unlockedCharacters: ["tariq"], unlockedAchievements: [], totalKills: 0, maxTimeSurvived: 0, highScores: [])
        save()
    }
    
    private func checkUnlocks(runTime: TimeInterval) {
        // Amara: Survive 5 mins (300s)
        if runTime >= 300 {
            unlockCharacter(CharacterType.amara.rawValue)
        }
        
        // Zahra: 1000 Total Kills
        if data.totalKills >= 1000 {
            unlockCharacter(CharacterType.zahra.rawValue)
        }
    }
}
