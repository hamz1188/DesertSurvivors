//
//  PickupManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class PickupManager {
    weak var scene: SKScene?
    weak var player: Player?
    private var activePickups: [ExperienceGem] = []
    
    init(scene: SKScene, player: Player) {
        self.scene = scene
        self.player = player
    }
    
    func spawnExperienceGem(at position: CGPoint, xpValue: Float = 10) {
        guard let scene = scene else { return }
        
        let gem = ExperienceGem(xpValue: xpValue)
        gem.position = position
        scene.addChild(gem)
        activePickups.append(gem)
    }
    
    func update(deltaTime: TimeInterval) {
        guard let player = player else { return }
        
        activePickups.removeAll { gem in
            if gem.parent == nil {
                return true
            }
            
            gem.update(deltaTime: deltaTime, 
                      playerPosition: player.position, 
                      pickupRadius: CGFloat(player.stats.pickupRadius))
            
            // Check if collected
            if gem.position.distance(to: player.position) < 10 {
                collectGem(gem)
                return true
            }
            
            return false
        }
    }
    
    private func collectGem(_ gem: ExperienceGem) {
        // Audio
        SoundManager.shared.playSFX(filename: "sfx_gem_collect.wav", scene: scene)
        
        // Notify level up system
        NotificationCenter.default.post(name: .experienceCollected, object: nil, userInfo: ["xp": gem.xpValue])
        gem.removeFromParent()
    }
    
    func clearAll() {
        for pickup in activePickups {
            pickup.removeFromParent()
        }
        activePickups.removeAll()
    }
}

extension Notification.Name {
    static let experienceCollected = Notification.Name("experienceCollected")
}

