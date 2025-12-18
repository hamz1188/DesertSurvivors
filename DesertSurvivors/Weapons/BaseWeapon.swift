//
//  BaseWeapon.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

protocol WeaponProtocol {
    var name: String { get }
    var baseDamage: Float { get }
    var cooldown: TimeInterval { get }
    var level: Int { get set }
    var maxLevel: Int { get }
    
    func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval)
    func upgrade()
}

class BaseWeapon: SKNode, WeaponProtocol {
    let name: String
    let baseDamage: Float
    var cooldown: TimeInterval
    var level: Int = 1
    let maxLevel: Int = 8
    
    private var currentCooldown: TimeInterval = 0
    weak var scene: SKScene?
    var damageMultiplier: Float = 1.0
    
    init(name: String, baseDamage: Float, cooldown: TimeInterval) {
        self.name = name
        self.baseDamage = baseDamage
        self.cooldown = cooldown
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        currentCooldown -= deltaTime
        
        if currentCooldown <= 0 {
            attack(playerPosition: playerPosition, enemies: enemies, deltaTime: deltaTime)
            currentCooldown = cooldown
        }
    }
    
    func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Override in subclasses
    }
    
    func upgrade() {
        guard level < maxLevel else { return }
        level += 1
    }
    
    func getDamage() -> Float {
        return baseDamage * damageMultiplier * Float(level)
    }
}

