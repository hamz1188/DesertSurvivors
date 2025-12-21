//
//  Constants.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import Foundation
import SpriteKit

struct Constants {
    // Game Configuration
    static let targetFPS: Int = 60
    static let maxEnemiesOnScreen: Int = 500
    
    // Debug Configuration
    #if DEBUG
    static let showFPSCounter: Bool = true
    static let showCollisionDebug: Bool = false
    static let enableProfiling: Bool = true
    #else
    static let showFPSCounter: Bool = false
    static let showCollisionDebug: Bool = false
    static let enableProfiling: Bool = false
    #endif
    
    // Player Defaults
    static let playerDefaultSpeed: CGFloat = 200 // points per second
    static let playerDefaultHealth: Float = 100
    static let playerDefaultPickupRadius: CGFloat = 50
    
    // Experience System
    static let baseXP: Float = 10
    static let xpMultiplier: Float = 1.1 // per level
    
    // Enemy Spawning
    static let baseEnemiesPerMinute: Int = 30
    static let enemiesPerMinuteGrowth: Float = 1.15
    static let spawnDistanceFromPlayer: CGFloat = 800 // spawn off-screen
    
    // Collision
    static let spatialHashCellSize: CGFloat = 100
    
    // Physics Categories
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let enemy: UInt32 = 0b10
        static let projectile: UInt32 = 0b100
        static let pickup: UInt32 = 0b1000
        static let weapon: UInt32 = 0b10000
        static let wall: UInt32 = 0b100000
    }
    
    // Colors
    struct Colors {
        static let desertSand = SKColor(red: 0.96, green: 0.87, blue: 0.70, alpha: 1.0)
        static let desertOrange = SKColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.0)
        static let healthRed = SKColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0)
        static let xpBlue = SKColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
    }
    
    // Z-Positions
    struct ZPosition {
        static let background: CGFloat = 0
        static let map: CGFloat = 10
        static let enemy: CGFloat = 50
        static let pickup: CGFloat = 40
        static let projectile: CGFloat = 60
        static let player: CGFloat = 70
        static let weapon: CGFloat = 65
        static let ui: CGFloat = 100
        static let hud: CGFloat = 90
    }
}

/// Runtime debug settings that can be toggled in-game via Settings menu.
/// These are separate from compile-time DEBUG flags.
class DebugSettings {
    static let shared = DebugSettings()
    
    private let developerModeKey = "isDeveloperModeEnabled"
    
    /// Master toggle for developer mode (shows FPS, enemy count, etc.)
    var isDeveloperModeEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: developerModeKey) }
        set { UserDefaults.standard.set(newValue, forKey: developerModeKey) }
    }
    
    /// Whether to show FPS counter in-game
    var showFPS: Bool {
        return isDeveloperModeEnabled
    }
    
    /// Whether to show enemy/projectile counts
    var showStats: Bool {
        return isDeveloperModeEnabled
    }
    
    private init() {}
}
