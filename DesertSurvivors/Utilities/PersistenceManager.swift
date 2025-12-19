//
//  PersistenceManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import Foundation

struct PlayerData: Codable {
    var totalGold: Int = 0
    var upgrades: [String: Int] = [:] // UpgradeID: Level
    var unlockedCharacters: [String] = ["tariq"]
    var highScores: [Int] = [] // Top 10 scores?
}

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let fileName = "playerData.json"
    private(set) var data: PlayerData
    
    private init() {
        self.data = PlayerData()
        load()
    }
    
    // MARK: - Save & Load
    
    private var fileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(fileName)
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            try encodedData.write(to: fileURL)
            // print("Data saved to \(fileURL)")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func load() {
        do {
            let fileData = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            data = try decoder.decode(PlayerData.self, from: fileData)
        } catch {
            // print("No saved data found, creating new.")
            data = PlayerData()
        }
    }
    
    // MARK: - Accessors
    
    func addGold(_ amount: Int) {
        data.totalGold += amount
        save()
    }
    
    func spendGold(_ amount: Int) -> Bool {
        guard data.totalGold >= amount else { return false }
        data.totalGold -= amount
        save()
        return true
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
}
