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

    /// Delegate for experience collection events (preferred over NotificationCenter)
    weak var delegate: ExperienceEventDelegate?

    /// Injected sound manager (falls back to shared instance if nil)
    private let soundManager: SoundManager

    init(scene: SKScene, player: Player, soundManager: SoundManager = .shared) {
        self.scene = scene
        self.player = player
        self.soundManager = soundManager
    }

    func spawnExperienceGem(at position: CGPoint, xpValue: Float = 10) {
        guard let scene = scene else { return }

        let gem = ExperienceGem(xpValue: xpValue, player: player)
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

            gem.update(deltaTime: deltaTime)

            // Check if collected
            if gem.position.distance(to: player.position) < 15 {
                collectGem(gem)
                return true
            }

            return false
        }
    }

    private func collectGem(_ gem: ExperienceGem) {
        // Audio
        soundManager.playSFX(filename: "sfx_gem_collect.wav", scene: scene)

        // Notify via delegate (preferred)
        delegate?.experienceDidCollect(xp: gem.xpValue)

        // Also post notification for backward compatibility
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

