//
//  ShopScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class ShopScene: SKScene {
    
    private var goldLabel: SKLabelNode!
    private var backButton: SKLabelNode!
    private var upgradeNodes: [String: SKNode] = [:] // Map type to node
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        setupUpgrades()
    }
    
    private func setupBackground() {
        backgroundColor = SKColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1.0)
    }
    
    private func setupUI() {
        // Title
        let titleValues = SKLabelNode(fontNamed: "Arial-BoldMT")
        titleValues.text = "MERCHANT"
        titleValues.fontSize = 48
        titleValues.fontColor = .yellow
        titleValues.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(titleValues)
        
        // Gold Display
        goldLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        goldLabel.fontSize = 24
        goldLabel.fontColor = .white
        goldLabel.horizontalAlignmentMode = .right
        goldLabel.position = CGPoint(x: size.width - 50, y: size.height - 60)
        addChild(goldLabel)
        
        updateGoldDisplay()
        
        // Back Button - positioned below Dynamic Island safe area
        backButton = SKLabelNode(fontNamed: "Arial-BoldMT")
        backButton.text = "< BACK"
        backButton.fontSize = 28
        backButton.fontColor = .white
        backButton.name = "backButton"
        backButton.horizontalAlignmentMode = .left
        backButton.position = CGPoint(x: 20, y: size.height - 120)
        addChild(backButton)
    }
    
    private func updateGoldDisplay() {
        let gold = PersistenceManager.shared.data.totalGold
        goldLabel.text = "Gold: \(gold)"
    }
    
    private func setupUpgrades() {
        let upgrades = ShopUpgradeType.allCases
        let startX: CGFloat = size.width / 2
        let startY: CGFloat = size.height - 180
        let spacingY: CGFloat = 75
        
        for (index, type) in upgrades.enumerated() {
            let x = startX
            let y = startY - CGFloat(index) * spacingY
            
            createUpgradeNode(for: type, at: CGPoint(x: x, y: y))
        }
    }
    
    private func createUpgradeNode(for type: ShopUpgradeType, at position: CGPoint) {
        let container = SKNode()
        container.position = position
        container.name = type.rawValue
        addChild(container)
        
        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: 320, height: 65), cornerRadius: 8)
        bg.fillColor = SKColor(white: 0.2, alpha: 1.0)
        bg.strokeColor = .gray
        container.addChild(bg)
        
        // Name
        let nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.text = type.displayName
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.position = CGPoint(x: -140, y: 15)
        container.addChild(nameLabel)
        
        // Level
        let levelLabel = SKLabelNode(fontNamed: "Arial")
        levelLabel.fontSize = 14
        levelLabel.fontColor = .lightGray
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.position = CGPoint(x: -140, y: -5)
        levelLabel.name = "levelLabel"
        container.addChild(levelLabel)
        
        // Cost
        let costLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        costLabel.fontSize = 18
        costLabel.fontColor = .yellow
        costLabel.horizontalAlignmentMode = .right
        costLabel.position = CGPoint(x: 140, y: 0)
        costLabel.name = "costLabel"
        container.addChild(costLabel)
        
        // Update variable text
        updateUpgradeNode(container, type: type)
        
        // Store reference
        upgradeNodes[type.rawValue] = container
    }
    
    private func updateUpgradeNode(_ node: SKNode, type: ShopUpgradeType) {
        guard let levelLabel = node.childNode(withName: "levelLabel") as? SKLabelNode,
              let costLabel = node.childNode(withName: "costLabel") as? SKLabelNode else { return }
        
        let level = ShopManager.shared.getUpgradeLevel(type)
        let cost = ShopManager.shared.getCost(for: type)
        
        if cost == -1 {
            levelLabel.text = "MAX LEVEL"
            levelLabel.fontColor = .green
            costLabel.text = ""
        } else {
            levelLabel.text = "Lvl \(level) (\(type.description))"
            levelLabel.fontColor = .lightGray
            costLabel.text = "\(cost) G"
            
            // Red cost if unaffordable
            if PersistenceManager.shared.data.totalGold < cost {
                costLabel.fontColor = .red
            } else {
                costLabel.fontColor = .yellow
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = nodes(at: location)
            
            for node in nodes {
                if node.name == "backButton" {
                    SoundManager.shared.playSFX(filename: "sfx_gem_collect.wav", scene: self) // Reuse sound logic
                    SceneManager.shared.presentMainMenu()
                    return
                }
                
                // Check ancestors for upgrade container
                var currentNode: SKNode? = node
                while currentNode != nil {
                    if let name = currentNode?.name, let type = ShopUpgradeType(rawValue: name) {
                        buyUpgrade(type)
                        return
                    }
                    currentNode = currentNode?.parent
                }
            }
        }
    }
    
    private func buyUpgrade(_ type: ShopUpgradeType) {
        if ShopManager.shared.purchaseUpgrade(type) {
            // Success
            // SoundManager.shared.playSFX("buy_sound")
            SoundManager.shared.playSFX(filename: "sfx_level_up.wav", scene: self) // Reuse positive sound
            updateGoldDisplay()
            
            // Update node
            if let node = upgradeNodes[type.rawValue] {
                updateUpgradeNode(node, type: type)
            }
            
            // Update all nodes (to refresh Red/Yellow costs based on new gold)
            for (key, node) in upgradeNodes {
                if let type = ShopUpgradeType(rawValue: key) {
                    updateUpgradeNode(node, type: type)
                }
            }
            
            // Check Achievements
            AchievementManager.shared.checkAchievements(scene: self)
        } else {
            // Fail
            // specific fail sound?
        }
    }
}
