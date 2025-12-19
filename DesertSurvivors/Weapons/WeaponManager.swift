//
//  WeaponManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class WeaponManager {
    private var weapons: [BaseWeapon] = []
    weak var scene: SKScene?
    var playerStats: PlayerStats?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func addWeapon(_ weapon: BaseWeapon) {
        // Apply current player stats to new weapon
        if let stats = playerStats {
            weapon.updateStats(from: stats)
        }
        weapons.append(weapon)
        // Weapon should be added as child of player, not scene directly
        // This is handled in GameScene
    }
    
    func removeWeapon(_ weapon: BaseWeapon) {
        if let index = weapons.firstIndex(where: { $0 === weapon }) {
            weapons.remove(at: index)
            weapon.removeFromParent()
        }
    }
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        for weapon in weapons {
            weapon.update(deltaTime: deltaTime, playerPosition: playerPosition, spatialHash: spatialHash)
        }
    }
    
    func updatePlayerStats(_ stats: PlayerStats) {
        playerStats = stats
        for weapon in weapons {
            weapon.updateStats(from: stats)
        }
    }
    
    func getWeapons() -> [BaseWeapon] {
        return weapons
    }
    
    func getWeaponCount() -> Int {
        return weapons.count
    }
}

