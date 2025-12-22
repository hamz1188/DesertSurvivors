//
//  GameEventDelegate.swift
//  DesertSurvivors
//
//  Defines protocols for game events, replacing NotificationCenter
//  with typed delegate patterns for clearer dependencies.
//

import CoreGraphics

// MARK: - Enemy Events

protocol EnemyEventDelegate: AnyObject {
    /// Called when an enemy dies
    /// - Parameters:
    ///   - position: The position where the enemy died (for spawning pickups)
    ///   - xpValue: The experience value to award
    func enemyDidDie(at position: CGPoint, xpValue: Float)
}

// MARK: - Experience Events

protocol ExperienceEventDelegate: AnyObject {
    /// Called when experience is collected
    /// - Parameter xp: The amount of experience collected
    func experienceDidCollect(xp: Float)
}

// MARK: - Level Up Events

protocol LevelUpEventDelegate: AnyObject {
    /// Called when the player levels up
    /// - Parameter level: The new level reached
    func playerDidLevelUp(to level: Int)
}

// MARK: - Combined Game Event Delegate

/// A combined protocol for classes that handle all game events
protocol GameEventDelegate: EnemyEventDelegate, ExperienceEventDelegate, LevelUpEventDelegate {}
