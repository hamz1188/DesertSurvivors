//
//  InputValidation.swift
//  DesertSurvivors
//
//  Provides input validation and clamping utilities for game values.
//  Helps prevent exploits and ensures data integrity.
//

import Foundation
import CoreGraphics

// MARK: - Numeric Validation

enum InputValidation {

    // MARK: - Clamping

    /// Clamps a value to a valid range
    static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        return Swift.min(Swift.max(value, min), max)
    }

    /// Clamps a CGFloat to a valid range
    static func clamp(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(value, min), max)
    }

    // MARK: - Joystick Input

    /// Validates and normalizes joystick direction
    /// - Parameter direction: Raw joystick direction
    /// - Returns: Normalized direction with magnitude clamped to 1.0
    static func validateJoystickInput(_ direction: CGPoint) -> CGPoint {
        let length = sqrt(direction.x * direction.x + direction.y * direction.y)

        // If magnitude is zero or very small, return zero
        guard length > 0.001 else {
            return .zero
        }

        // Clamp magnitude to maximum of 1.0
        if length > 1.0 {
            return CGPoint(x: direction.x / length, y: direction.y / length)
        }

        return direction
    }

    // MARK: - Damage Validation

    /// Validates damage values to prevent negative or extreme values
    /// - Parameter damage: Raw damage value
    /// - Returns: Validated damage (minimum 0, maximum 99999)
    static func validateDamage(_ damage: Float) -> Float {
        return clamp(damage, min: 0, max: 99999)
    }

    /// Validates enemy damage to ensure it's within expected range
    /// - Parameter damage: Enemy damage value
    /// - Returns: Validated damage (minimum 1, maximum 1000)
    static func validateEnemyDamage(_ damage: Float) -> Float {
        return clamp(damage, min: 1, max: 1000)
    }

    // MARK: - Cooldown Validation

    /// Validates weapon cooldown to prevent zero or negative values
    /// - Parameter cooldown: Raw cooldown in seconds
    /// - Returns: Validated cooldown (minimum 0.1 seconds, maximum 60 seconds)
    static func validateCooldown(_ cooldown: TimeInterval) -> TimeInterval {
        return clamp(cooldown, min: 0.1, max: 60.0)
    }

    // MARK: - Health Validation

    /// Validates health values
    /// - Parameter health: Raw health value
    /// - Returns: Validated health (minimum 0, maximum 99999)
    static func validateHealth(_ health: Float) -> Float {
        return clamp(health, min: 0, max: 99999)
    }

    /// Validates max health (must be at least 1)
    /// - Parameter maxHealth: Raw max health value
    /// - Returns: Validated max health (minimum 1, maximum 99999)
    static func validateMaxHealth(_ maxHealth: Float) -> Float {
        return clamp(maxHealth, min: 1, max: 99999)
    }

    // MARK: - Speed Validation

    /// Validates movement speed
    /// - Parameter speed: Raw speed value
    /// - Returns: Validated speed (minimum 0, maximum 2000)
    static func validateSpeed(_ speed: CGFloat) -> CGFloat {
        return clamp(speed, min: 0, max: 2000)
    }

    // MARK: - Currency Validation

    /// Validates gold amount
    /// - Parameter gold: Raw gold value
    /// - Returns: Validated gold (minimum 0, maximum Int.max / 2 to prevent overflow)
    static func validateGold(_ gold: Int) -> Int {
        return clamp(gold, min: 0, max: Int.max / 2)
    }

    /// Validates experience points
    /// - Parameter xp: Raw XP value
    /// - Returns: Validated XP (minimum 0, maximum 999999)
    static func validateXP(_ xp: Float) -> Float {
        return clamp(xp, min: 0, max: 999999)
    }

    // MARK: - Multiplier Validation

    /// Validates multiplier values (damage, area, etc.)
    /// - Parameter multiplier: Raw multiplier value
    /// - Returns: Validated multiplier (minimum 0.1, maximum 10.0)
    static func validateMultiplier(_ multiplier: Float) -> Float {
        return clamp(multiplier, min: 0.1, max: 10.0)
    }

    // MARK: - Position Validation

    /// Validates position is within world bounds
    /// - Parameters:
    ///   - position: Raw position
    ///   - worldSize: Size of the game world
    /// - Returns: Position clamped to world bounds
    static func validatePosition(_ position: CGPoint, worldSize: CGSize) -> CGPoint {
        let halfWidth = worldSize.width / 2
        let halfHeight = worldSize.height / 2

        return CGPoint(
            x: clamp(position.x, min: -halfWidth, max: halfWidth),
            y: clamp(position.y, min: -halfHeight, max: halfHeight)
        )
    }

    // MARK: - Level Validation

    /// Validates level values
    /// - Parameter level: Raw level value
    /// - Returns: Validated level (minimum 1, maximum 999)
    static func validateLevel(_ level: Int) -> Int {
        return clamp(level, min: 1, max: 999)
    }

    /// Validates upgrade level
    /// - Parameters:
    ///   - level: Current upgrade level
    ///   - maxLevel: Maximum allowed level
    /// - Returns: Validated level (minimum 0, maximum maxLevel)
    static func validateUpgradeLevel(_ level: Int, maxLevel: Int) -> Int {
        return clamp(level, min: 0, max: maxLevel)
    }
}

// MARK: - CGPoint Extension for Validation

extension CGPoint {
    /// Returns a normalized version of this point (magnitude clamped to 1.0)
    var validated: CGPoint {
        return InputValidation.validateJoystickInput(self)
    }
}
