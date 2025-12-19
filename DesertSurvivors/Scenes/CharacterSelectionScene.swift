//
//  CharacterSelectionScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class CharacterSelectionScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.25, alpha: 1.0)
        setupUI()
    }
    
    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "SELECT CHARACTER"
        titleLabel.fontSize = 32
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(titleLabel)
        
        // Character Card (Tariq)
        let card = createCharacterCard(name: "Tariq", description: "The Survivor", isLocked: false)
        card.position = CGPoint(x: size.width / 2, y: size.height / 2)
        card.name = "tariqCard"
        addChild(card)
        
        // Locked Slot (coming soon)
        let locked = createCharacterCard(name: "???", description: "Coming Soon", isLocked: true)
        locked.position = CGPoint(x: size.width / 2, y: size.height / 2 - 120)
        addChild(locked)
        
        // Back Button
        let backButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backButton.text = "< Back"
        backButton.fontSize = 20
        backButton.fontColor = .gray
        backButton.position = CGPoint(x: 60, y: size.height - 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    private func createCharacterCard(name: String, description: String, isLocked: Bool) -> SKNode {
        let card = SKNode()
        
        let bg = SKShapeNode(rectOf: CGSize(width: 300, height: 80), cornerRadius: 8)
        bg.fillColor = isLocked ? .darkGray : Constants.Colors.desertSand
        bg.strokeColor = .white
        bg.lineWidth = 2
        card.addChild(bg)
        
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = name
        nameLabel.fontSize = 24
        nameLabel.fontColor = isLocked ? .gray : .black
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -130, y: 10)
        card.addChild(nameLabel)
        
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = description
        descLabel.fontSize = 16
        descLabel.fontColor = isLocked ? .gray : .darkGray
        descLabel.horizontalAlignmentMode = .left
        descLabel.position = CGPoint(x: -130, y: -20)
        card.addChild(descLabel)
        
        return card
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            // Check usage of parent node name if children are hit
            let hitName = node.name ?? node.parent?.name
            
            if hitName == "tariqCard" {
                // Select Tariq and Start Game
                SceneManager.shared.presentGameScene()
            } else if hitName == "backButton" {
                SceneManager.shared.presentMainMenu()
            }
        }
    }
}
