//
//  Player.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Player: SKNode {
    var stats: PlayerStats
    var movementDirection: CGPoint = .zero
    var isMoving: Bool = false
    
    private var spriteNode: SKSpriteNode!
    
    init(stats: PlayerStats = PlayerStats()) {
        self.stats = stats
        super.init()
        
        setupSprite()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprite() {
        // Create a simple colored circle as placeholder sprite
        let size = CGSize(width: 30, height: 30)
        spriteNode = SKSpriteNode(color: .blue, size: size)
        spriteNode.zPosition = Constants.ZPosition.player
        addChild(spriteNode)
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 15)
        physicsBody?.categoryBitMask = Constants.PhysicsCategory.player
        physicsBody?.collisionBitMask = Constants.PhysicsCategory.none
        physicsBody?.contactTestBitMask = Constants.PhysicsCategory.enemy | Constants.PhysicsCategory.pickup
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    func update(deltaTime: TimeInterval) {
        // Update movement
        if isMoving && movementDirection.length() > 0 {
            let speed = CGFloat(stats.moveSpeed) * CGFloat(deltaTime)
            let movement = movementDirection.normalized() * speed
            position = position + movement
        }
    }
    
    func setMovementDirection(_ direction: CGPoint) {
        movementDirection = direction
        isMoving = direction.length() > 0.1
    }
    
    func takeDamage(_ amount: Float) {
        stats.takeDamage(amount)
    }
    
    func heal(_ amount: Float) {
        stats.heal(amount)
    }
}

