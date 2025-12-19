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
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(titleLabel)
        
        // Characters List
        let characters = CharacterType.allCases
        let startY: CGFloat = size.height - 160
        let spacing: CGFloat = 100
        
        for (index, charType) in characters.enumerated() {
            let isUnlocked = PersistenceManager.shared.isCharacterUnlocked(charType.rawValue)
            let card = createCharacterCard(type: charType, isUnlocked: isUnlocked)
            card.position = CGPoint(x: size.width / 2, y: startY - CGFloat(index) * spacing)
            card.name = "card_\(charType.rawValue)"
            addChild(card)
        }
        
        // Back Button
        let backButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backButton.text = "< Back"
        backButton.fontSize = 20
        backButton.fontColor = .gray
        backButton.position = CGPoint(x: 60, y: size.height - 50)
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    private func createCharacterCard(type: CharacterType, isUnlocked: Bool) -> SKNode {
        let card = SKNode()
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 320, height: 80), cornerRadius: 8)
        bg.fillColor = isUnlocked ? Constants.Colors.desertSand : .darkGray
        bg.strokeColor = .white
        bg.lineWidth = 2
        card.addChild(bg)
        
        // Name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = isUnlocked ? type.displayName : "???"
        nameLabel.fontSize = 24
        nameLabel.fontColor = isUnlocked ? .black : .lightGray
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -140, y: 15)
        card.addChild(nameLabel)
        
        // Description / Unlock Text
        let descLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        descLabel.text = isUnlocked ? type.description : type.unlockConditionText
        descLabel.fontSize = 14
        descLabel.fontColor = isUnlocked ? .darkGray : .yellow
        descLabel.horizontalAlignmentMode = .left
        descLabel.verticalAlignmentMode = .top
        descLabel.numberOfLines = 2
        descLabel.preferredMaxLayoutWidth = 280
        descLabel.position = CGPoint(x: -140, y: 5)
        card.addChild(descLabel)
        
        if !isUnlocked {
            let lockIcon = SKLabelNode(fontNamed: "Arial")
            lockIcon.text = "🔒"
            lockIcon.fontSize = 24
            lockIcon.position = CGPoint(x: 130, y: 0)
            card.addChild(lockIcon)
        }
        
        return card
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check back button first
        if atPoint(location).name == "backButton" {
             SceneManager.shared.presentMainMenu()
             return
        }
        
        let nodes = nodes(at: location)
        for node in nodes {
             // Traverse parents to find container
            var currentNode: SKNode? = node
            while currentNode != nil {
                if let name = currentNode?.name, name.hasPrefix("card_") {
                    let charID = String(name.dropFirst(5)) // remove "card_"
                    if let type = CharacterType(rawValue: charID) {
                        selectCharacter(type)
                        return
                    }
                }
                currentNode = currentNode?.parent
            }
        }
    }
        
    private func selectCharacter(_ type: CharacterType) {
        if PersistenceManager.shared.isCharacterUnlocked(type.rawValue) {
            SceneManager.shared.presentGameScene(character: type)
        } else {
             // Play default "locked" sound or wiggle effect
             SoundManager.shared.playSFX(filename: "sfx_enemy_hit.wav", scene: self) // reuse hit sound as "denied"
        }
    }
}
