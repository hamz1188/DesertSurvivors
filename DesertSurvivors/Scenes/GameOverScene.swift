//
//  GameOverScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class GameOverScene: SKScene {
    private let finalLevel: Int
    private let kills: Int
    private let timeSurvived: String
    
    init(size: CGSize, level: Int, kills: Int, time: String) {
        self.finalLevel = level
        self.kills = kills
        self.timeSurvived = time
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0.05, blue: 0.05, alpha: 1.0)
        setupUI()
    }
    
    private func setupUI() {
        // Game Over Label
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "GAME OVER"
        titleLabel.fontSize = 54
        titleLabel.fontColor = .red
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        addChild(titleLabel)
        
        // Stats Container
        let startY = size.height * 0.6
        let gap: CGFloat = 50
        
        addStat(text: "Time Survived: \(timeSurvived)", y: startY)
        addStat(text: "Level Reached: \(finalLevel)", y: startY - gap)
        addStat(text: "Enemies Defeated: \(kills)", y: startY - gap * 2)
        
        // Restart Button
        let restartButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartButton.name = "restartButton"
        restartButton.text = "TRY AGAIN"
        restartButton.fontSize = 32
        restartButton.fontColor = .white
        restartButton.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        addChild(restartButton)
        
        // Menu Button
        let menuButton = SKLabelNode(fontNamed: "AvenirNext-Medium")
        menuButton.name = "menuButton"
        menuButton.text = "Main Menu"
        menuButton.fontSize = 24
        menuButton.fontColor = .lightGray
        menuButton.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(menuButton)
    }
    
    private func addStat(text: String, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: y)
        addChild(label)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "restartButton" {
                SceneManager.shared.presentGameScene()
            } else if node.name == "menuButton" {
                SceneManager.shared.presentMainMenu()
            }
        }
    }
}
