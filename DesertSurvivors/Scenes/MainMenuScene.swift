//
//  MainMenuScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0)
        
        setupUI()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "DESERT SURVIVORS"
        titleLabel.fontSize = 40 // Reduced from 48 to fit better
        titleLabel.fontColor = .orange
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        subtitleLabel.text = "Survive the Endless Sands"
        subtitleLabel.fontSize = 20
        subtitleLabel.fontColor = .white
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        addChild(subtitleLabel)
        
        // Start Button
        let startButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        startButton.name = "startButton"
        startButton.text = "START GAME"
        startButton.fontSize = 32
        startButton.fontColor = .white
        startButton.position = CGPoint(x: size.width / 2, y: size.height * 0.4)
        
        // Add minimal pulsing effect
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        startButton.run(SKAction.repeatForever(pulse))
        
        addChild(startButton)
        
        // Shop Button
        let shopButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shopButton.name = "shopButton"
        shopButton.text = "MERCHANT"
        shopButton.fontSize = 28
        shopButton.fontColor = .yellow
        shopButton.position = CGPoint(x: size.width / 2, y: size.height * 0.3)
        addChild(shopButton)
        
        // Credits
        let creditsLabel = SKLabelNode(fontNamed: "AvenirNext-Italic")
        creditsLabel.text = "v0.6 - Phase 4"
        creditsLabel.fontSize = 14
        creditsLabel.fontColor = .gray
        creditsLabel.position = CGPoint(x: size.width / 2, y: 50)
        addChild(creditsLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "startButton" {
                SceneManager.shared.presentCharacterSelection()
            } else if node.name == "shopButton" {
                SceneManager.shared.presentShop()
            }
        }
    }
}
