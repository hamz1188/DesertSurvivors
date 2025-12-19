//
//  BaseWeapon.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

protocol WeaponProtocol {
    var weaponName: String { get }
    var baseDamage: Float { get }
    var baseCooldown: TimeInterval { get }
    var level: Int { get set }
    var maxLevel: Int { get }
    
    func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval)
    func upgrade()
}

class BaseWeapon: SKNode, WeaponProtocol {
    var weaponName: String
    let baseDamage: Float
    let baseCooldown: TimeInterval
    var level: Int = 1
    let maxLevel: Int = 8
    var isAwakened: Bool = false
    
    private var currentCooldown: TimeInterval = 0
    var damageMultiplier: Float = 1.0
    var cooldownReduction: Float = 0 // 0.0 to 0.9 (90% max)
    var attackSpeedMultiplier: Float = 1.0
    var critChance: Float = 0
    var critMultiplier: Float = 2.0
    
    /// The effective cooldown after applying cooldown reduction and attack speed
    var effectiveCooldown: TimeInterval {
        let reducedCooldown = baseCooldown * Double(1.0 - cooldownReduction)
        return reducedCooldown / Double(attackSpeedMultiplier)
    }
    
    init(name: String, baseDamage: Float, cooldown: TimeInterval) {
        self.weaponName = name
        self.baseDamage = baseDamage
        self.baseCooldown = cooldown
        super.init()
        self.name = name // Set SKNode's name property (optional String)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        currentCooldown -= deltaTime
        
        if currentCooldown <= 0 {
            attack(playerPosition: playerPosition, spatialHash: spatialHash, deltaTime: deltaTime)
            playAttackSound()
            currentCooldown = effectiveCooldown
        }
    }
    
    private func playAttackSound() {
        // Sanitize name: "Curved Dagger" -> "curved_dagger"
        let sanitizedName = weaponName.lowercased().replacingOccurrences(of: " ", with: "_")
        let soundName = "sfx_attack_\(sanitizedName).wav"
        
        // Find scene to play sound
        if let scene = scene {
            SoundManager.shared.playSFX(filename: soundName, scene: scene)
        }
    }
    
    func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        // Override in subclasses
    }
    
    func upgrade() {
        guard level < maxLevel else { return }
        level += 1
    }
    
    /// Calculate damage including level scaling and critical hits
    func getDamage() -> Float {
        var damage = baseDamage * damageMultiplier * Float(level)
        
        // Check for critical hit
        if critChance > 0 && Float.random(in: 0...1) < critChance {
            damage *= critMultiplier
        }
        
        return damage
    }
    
    /// Update weapon stats from player stats
    func updateStats(from playerStats: PlayerStats) {
        damageMultiplier = playerStats.damageMultiplier
        cooldownReduction = playerStats.cooldownReduction
        attackSpeedMultiplier = playerStats.attackSpeedMultiplier
        critChance = playerStats.critChance
        critMultiplier = playerStats.critMultiplier
    }
}

