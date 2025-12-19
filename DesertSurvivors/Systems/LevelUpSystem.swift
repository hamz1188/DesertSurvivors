//
//  LevelUpSystem.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation

class LevelUpSystem {
    var currentLevel: Int = 1
    var currentXP: Float = 0
    var xpForNextLevel: Float
    
    init() {
        xpForNextLevel = LevelUpSystem.calculateXPForLevel(2)
    }
    
    func addXP(_ amount: Float, multiplier: Float = 1.0) {
        currentXP += amount * multiplier
        
        while currentXP >= xpForNextLevel {
            levelUp()
        }
    }
    
    private func levelUp() {
        currentLevel += 1
        currentXP -= xpForNextLevel
        xpForNextLevel = LevelUpSystem.calculateXPForLevel(currentLevel + 1)
        
        // Trigger level up event (will show UI)
        NotificationCenter.default.post(name: .playerLevelUp, object: nil, userInfo: ["level": currentLevel])
    }
    
    private static func calculateXPForLevel(_ level: Int) -> Float {
        return Constants.baseXP * pow(Constants.xpMultiplier, Float(level - 1))
    }
    
    var xpProgress: Float {
        guard xpForNextLevel > 0 else { return 0 }
        return currentXP / xpForNextLevel
    }
}

extension Notification.Name {
    static let playerLevelUp = Notification.Name("playerLevelUp")
}

