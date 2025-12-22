//
//  GameErrors.swift
//  DesertSurvivors
//
//  Type-safe error definitions for game operations.
//  Replaces Bool returns with Result types for clearer error handling.
//

import Foundation

// MARK: - Shop Errors

enum ShopError: Error, LocalizedError {
    case insufficientGold(required: Int, available: Int)
    case maxLevelReached(upgrade: String, maxLevel: Int)
    case upgradeNotFound(id: String)

    var errorDescription: String? {
        switch self {
        case .insufficientGold(let required, let available):
            return "Insufficient gold: need \(required), have \(available)"
        case .maxLevelReached(let upgrade, let maxLevel):
            return "Upgrade '\(upgrade)' already at max level \(maxLevel)"
        case .upgradeNotFound(let id):
            return "Upgrade '\(id)' not found"
        }
    }
}

// MARK: - Persistence Errors

enum PersistenceError: Error, LocalizedError {
    case encodingFailed(underlying: Error)
    case decodingFailed(underlying: Error)
    case fileNotFound
    case writeFailed(underlying: Error)
    case directoryUnavailable

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .fileNotFound:
            return "Save file not found"
        case .writeFailed(let underlying):
            return "Failed to write data: \(underlying.localizedDescription)"
        case .directoryUnavailable:
            return "Documents directory unavailable"
        }
    }
}

// MARK: - Achievement Errors

enum AchievementError: Error, LocalizedError {
    case alreadyUnlocked(id: String)
    case notFound(id: String)

    var errorDescription: String? {
        switch self {
        case .alreadyUnlocked(let id):
            return "Achievement '\(id)' already unlocked"
        case .notFound(let id):
            return "Achievement '\(id)' not found"
        }
    }
}

// MARK: - Character Errors

enum CharacterError: Error, LocalizedError {
    case alreadyUnlocked(id: String)
    case notFound(id: String)
    case locked(id: String)

    var errorDescription: String? {
        switch self {
        case .alreadyUnlocked(let id):
            return "Character '\(id)' already unlocked"
        case .notFound(let id):
            return "Character '\(id)' not found"
        case .locked(let id):
            return "Character '\(id)' is locked"
        }
    }
}

// MARK: - Type Aliases for Convenience

typealias ShopResult<T> = Result<T, ShopError>
typealias PersistenceResult<T> = Result<T, PersistenceError>
typealias AchievementResult<T> = Result<T, AchievementError>
