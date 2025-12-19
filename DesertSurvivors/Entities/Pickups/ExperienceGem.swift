//
//  ExperienceGem.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class ExperienceGem: SKNode {
    var xpValue: Float = 10
    weak var player: Player?
    private var magnetSpeed: CGFloat = 200 // speed when being attracted to player
    
    init(xpValue: Float = 10, player: Player?) {
        self.xpValue = xpValue
        self.player = player
        super.init()
        setupSprite()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprite() {
        // Procedural Crystal Shape
        let path = CGMutablePath()
        // Hexagonal Gem Shape
        path.move(to: CGPoint(x: 0, y: 10))
        path.addLine(to: CGPoint(x: 8, y: 5))
        path.addLine(to: CGPoint(x: 8, y: -5))
        path.addLine(to: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: -8, y: -5))
        path.addLine(to: CGPoint(x: -8, y: 5))
        path.closeSubpath()
        
        // Main body
        let gemBody = SKShapeNode(path: path)
        gemBody.fillColor = Constants.Colors.xpBlue
        gemBody.strokeColor = .white
        gemBody.lineWidth = 1.0
        
        // Inner highlight (for "shine")
        let highlightPath = CGMutablePath()
        highlightPath.move(to: CGPoint(x: -4, y: 4))
        highlightPath.addLine(to: CGPoint(x: 0, y: 6))
        highlightPath.addLine(to: CGPoint(x: 4, y: 4))
        
        let highlight = SKShapeNode(path: highlightPath)
        highlight.strokeColor = .white
        highlight.lineWidth = 1.0
        highlight.alpha = 0.6
        gemBody.addChild(highlight)
        
        // Add subtle pulse action
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.9, duration: 1.0)
        let pulse = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        gemBody.run(pulse)
        
        gemBody.zPosition = Constants.ZPosition.pickup
        addChild(gemBody)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        physicsBody?.categoryBitMask = Constants.PhysicsCategory.pickup
        physicsBody?.collisionBitMask = Constants.PhysicsCategory.none
        physicsBody?.contactTestBitMask = Constants.PhysicsCategory.player
        physicsBody?.isDynamic = false
    }
    
    func update(deltaTime: TimeInterval) {
        guard let player = player else { return }
        
        let playerPosition = player.position
        let pickupRadius = CGFloat(player.stats.pickupRadius)
        let distance = position.distance(to: playerPosition)
        
        // If within pickup radius, move toward player
        if distance < pickupRadius {
            let direction = (playerPosition - position).normalized()
            let movement = direction * magnetSpeed * CGFloat(deltaTime)
            position = position + movement
        }
    }
    
    func collect() {
        // Will be handled by the experience system
        removeFromParent()
    }
}

