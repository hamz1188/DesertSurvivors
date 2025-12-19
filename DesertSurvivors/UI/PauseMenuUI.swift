//
//  PauseMenuUI.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class PauseMenuUI: SKNode {
    var resumeAction: (() -> Void)?
    var quitAction: (() -> Void)?
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        zPosition = Constants.ZPosition.hud + 10 // Above everything
        isUserInteractionEnabled = true
        
        // Semi-transparent background
        // We rely on the parent scene size, but since this is a node, let's make a big enough rect
        // Or updated when added. For now, a fixed large size covering most screens.
        let background = SKShapeNode(rectOf: CGSize(width: 3000, height: 3000))
        background.fillColor = SKColor.black.withAlphaComponent(0.7)
        background.strokeColor = .clear
        background.position = .zero
        addChild(background)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "PAUSED"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 100)
        addChild(titleLabel)
        
        // Resume Button
        let resumeButton = createButton(text: "RESUME", name: "resumeButton", position: CGPoint(x: 0, y: 0))
        addChild(resumeButton)
        
        // Quit Button
        let quitButton = createButton(text: "QUIT", name: "quitButton", position: CGPoint(x: 0, y: -80))
        addChild(quitButton)
    }
    
    private func createButton(text: String, name: String, position: CGPoint) -> SKNode {
        let button = SKNode()
        button.name = name
        button.position = position
        
        let background = SKShapeNode(rectOf: CGSize(width: 200, height: 50), cornerRadius: 10)
        background.fillColor = Constants.Colors.desertOrange
        background.strokeColor = .white
        background.lineWidth = 2
        background.name = name // Hit test needs name
        button.addChild(background)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name // Hit test needs name
        button.addChild(label)
        
        return button
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "resumeButton" {
                resumeAction?()
            } else if node.name == "quitButton" {
                quitAction?()
            }
        }
    }
}
