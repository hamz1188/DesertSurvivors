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
    private var spriteNode: SKSpriteNode!
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
        let size = CGSize(width: 15, height: 15)
        spriteNode = SKSpriteNode(color: Constants.Colors.xpBlue, size: size)
        spriteNode.zPosition = Constants.ZPosition.pickup
        addChild(spriteNode)
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

