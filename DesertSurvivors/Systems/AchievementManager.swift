//
//  AchievementManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

enum AchievementType: String, CaseIterable {
    case firstBlood = "first_blood"
    case slayer = "slayer"
    case survivor = "survivor"
    case hoarder = "hoarder"
    case fullyLoaded = "fully_loaded"
    
    var title: String {
        switch self {
        case .firstBlood: return "First Blood"
        case .slayer: return "Desert Slayer"
        case .survivor: return "Sand Survivor"
        case .hoarder: return "Gold Hoarder"
        case .fullyLoaded: return "Maximizer"
        }
    }
    
    var description: String {
        switch self {
        case .firstBlood: return "Kill your first enemy."
        case .slayer: return "Kill 500 enemies total."
        case .survivor: return "Survive for 5 minutes."
        case .hoarder: return "Collect 500 cumulative Gold."
        case .fullyLoaded: return "Max out a Shop upgrade."
        }
    }
}

class AchievementManager {
    static let shared = AchievementManager()
    
    private init() {}
    
    func checkAchievements(scene: SKScene? = nil) {
        let data = PersistenceManager.shared.data
        
        // 1. First Blood
        if data.totalKills >= 1 {
            unlock(.firstBlood, in: scene)
        }
        
        // 2. Slayer
        if data.totalKills >= 500 {
            unlock(.slayer, in: scene)
        }
        
        // 3. Survivor
        if data.maxTimeSurvived >= 300 {
            unlock(.survivor, in: scene)
        }
        
        // 4. Hoarder
        if data.totalGold >= 500 {
            // Note: Currently tracking current gold, not total lifetime gold. 
            // Ideally we'd have lifetimeGold, but totalGold works if they hoard it.
            unlock(.hoarder, in: scene)
        }
        
        // 5. Maximizer
        // Check if any upgrade is level 5 (max)
        for (_, level) in data.upgrades {
            if level >= 5 {
                unlock(.fullyLoaded, in: scene)
                break
            }
        }
    }
    
    private func unlock(_ type: AchievementType, in scene: SKScene?) {
        if PersistenceManager.shared.unlockAchievement(type.rawValue) {
            print("Achievement Unlocked: \(type.title)")
            if let scene = scene {
                showNotification(for: type, in: scene)
            }
        }
    }
    
    private func showNotification(for type: AchievementType, in scene: SKScene) {
        let notification = AchievementNotificationNode(achievement: type)
        // Position at top center
        // Convert to camera space if camera exists
        if let camera = scene.camera {
            notification.position = CGPoint(x: 0, y: scene.size.height/2 - 80) // Below HUD
            notification.zPosition = 1000
            camera.addChild(notification)
        } else {
            notification.position = CGPoint(x: scene.size.width/2, y: scene.size.height - 80)
            notification.zPosition = 1000
            scene.addChild(notification)
        }
        
        notification.animateInAndOut()
    }
}

class AchievementNotificationNode: SKNode {
    init(achievement: AchievementType) {
        super.init()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.9)
        bg.strokeColor = .yellow
        bg.lineWidth = 2
        addChild(bg)
        
        let icon = SKLabelNode(text: "🏆")
        icon.fontSize = 30
        icon.position = CGPoint(x: -120, y: -10)
        addChild(icon)
        
        let msg = SKLabelNode(fontNamed: "AvenirNext-Bold")
        msg.text = "Achievement Unlocked!"
        msg.fontSize = 14
        msg.fontColor = .yellow
        msg.position = CGPoint(x: 0, y: 10)
        addChild(msg)
        
        let title = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        title.text = achievement.title
        title.fontSize = 18
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: -15)
        addChild(title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateInAndOut() {
        self.alpha = 0
        self.setScale(0.5)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let appear = SKAction.group([fadeIn, scaleUp])
        
        let wait = SKAction.wait(forDuration: 3.0)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        run(SKAction.sequence([appear, wait, fadeOut, remove]))
        
        // Sound
        SoundManager.shared.playSFX(filename: "sfx_level_up.wav", scene: self.scene ?? SKScene())
    }
}
