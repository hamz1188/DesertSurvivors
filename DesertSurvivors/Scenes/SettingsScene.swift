//
//  SettingsScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class SettingsScene: SKScene {
    
    private var musicLabel: SKLabelNode!
    private var sfxLabel: SKLabelNode!
    private var hapticsLabel: SKLabelNode!
    private var resetLabel: SKLabelNode!
    
    private var resetConfirmStage = false
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        setupUI()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "SETTINGS"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(titleLabel)
        
        let startY: CGFloat = size.height - 200
        let spacing: CGFloat = 80
        
        // Music Toggle
        musicLabel = createToggle(name: "musicToggle", text: "MUSIC: ON", y: startY)
        updateMusicLabel()
        
        // SFX Toggle
        sfxLabel = createToggle(name: "sfxToggle", text: "SFX: ON", y: startY - spacing)
        updateSFXLabel()
        
        // Haptics Toggle
        hapticsLabel = createToggle(name: "hapticsToggle", text: "VIBRATION: ON", y: startY - spacing * 2)
        updateHapticsLabel()
        
        // Reset Data
        resetLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resetLabel.name = "resetButton"
        resetLabel.text = "RESET SAVE DATA"
        resetLabel.fontSize = 28
        resetLabel.fontColor = .red
        resetLabel.position = CGPoint(x: size.width / 2, y: startY - spacing * 3.5)
        addChild(resetLabel)
        
        // Back Button
        let backButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backButton.name = "backButton"
        backButton.text = "BACK"
        backButton.fontSize = 28
        backButton.fontColor = .white
        backButton.position = CGPoint(x: size.width / 2, y: 50)
        addChild(backButton)
    }
    
    private func createToggle(name: String, text: String, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.name = name
        label.text = text
        label.fontSize = 32
        label.fontColor = .yellow
        label.position = CGPoint(x: size.width / 2, y: y)
        addChild(label)
        return label
    }
    
    private func updateMusicLabel() {
        let state = SoundManager.shared.isMusicEnabled ? "ON" : "OFF"
        musicLabel.text = "MUSIC: \(state)"
        musicLabel.fontColor = SoundManager.shared.isMusicEnabled ? .yellow : .gray
    }
    
    private func updateSFXLabel() {
        let state = SoundManager.shared.isSFXEnabled ? "ON" : "OFF"
        sfxLabel.text = "SFX: \(state)"
        sfxLabel.fontColor = SoundManager.shared.isSFXEnabled ? .yellow : .gray
    }
    
    private func updateHapticsLabel() {
        let state = HapticManager.shared.isHapticsEnabled ? "ON" : "OFF"
        hapticsLabel.text = "VIBRATION: \(state)"
        hapticsLabel.fontColor = HapticManager.shared.isHapticsEnabled ? .yellow : .gray
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" {
                SoundManager.shared.playSFX(filename: "sfx_gem_collect.wav", scene: self)
                SceneManager.shared.presentMainMenu()
                return
            }
            
            if node.name == "musicToggle" {
                SoundManager.shared.isMusicEnabled.toggle()
                updateMusicLabel()
                SoundManager.shared.playSFX(filename: "sfx_gem_collect.wav", scene: self)
            }
            
            if node.name == "sfxToggle" {
                SoundManager.shared.isSFXEnabled.toggle()
                updateSFXLabel()
                // Play sound only if enabled (which it just became, or was)
                if SoundManager.shared.isSFXEnabled {
                    SoundManager.shared.playSFX(filename: "sfx_gem_collect.wav", scene: self)
                }
            }
            
            if node.name == "hapticsToggle" {
                HapticManager.shared.isHapticsEnabled.toggle()
                updateHapticsLabel()
                if HapticManager.shared.isHapticsEnabled {
                    HapticManager.shared.selection()
                }
            }
            
            if node.name == "resetButton" {
                if resetConfirmStage {
                    // Perform Reset
                    resetData()
                } else {
                    // Ask confirm
                    resetConfirmStage = true
                    resetLabel.text = "CONFIRM DELETE?"
                    resetLabel.run(SKAction.sequence([
                        SKAction.scale(to: 1.2, duration: 0.1),
                        SKAction.scale(to: 1.0, duration: 0.1)
                    ]))
                }
            } else if node.name != "resetButton" && resetConfirmStage {
                // Cancel reset if clicked elsewhere
                resetConfirmStage = false
                resetLabel.text = "RESET SAVE DATA"
            }
        }
    }
    
    private func resetData() {
        // Reset Logic
        PersistenceManager.shared.resetData()
        
        resetLabel.text = "DATA ERASED"
        resetLabel.fontColor = .gray
        resetConfirmStage = false
        
        SoundManager.shared.playSFX(filename: "sfx_enemy_die.wav", scene: self)
        HapticManager.shared.notification(type: .success)
    }
}
