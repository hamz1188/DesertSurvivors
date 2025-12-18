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
        // scene property is readonly, but weapon will have access to it when added to scene
        if let stats = playerStats {
            weapon.damageMultiplier = stats.damageMultiplier
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
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        for weapon in weapons {
            weapon.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        }
    }
    
    func updatePlayerStats(_ stats: PlayerStats) {
        playerStats = stats
        for weapon in weapons {
            weapon.damageMultiplier = stats.damageMultiplier
        }
    }
    
    func getWeapons() -> [BaseWeapon] {
        return weapons
    }
}

