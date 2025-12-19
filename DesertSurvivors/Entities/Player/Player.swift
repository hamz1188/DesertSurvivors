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
    
    // Invincibility frames system
    private var isInvincible: Bool = false
    private var invincibilityTimer: TimeInterval = 0
    private let invincibilityDuration: TimeInterval = 0.5 // 0.5 seconds of invincibility after hit
    
    // Health regeneration
    private var regenTimer: TimeInterval = 0
    
    init(stats: PlayerStats = PlayerStats()) {
        self.stats = stats
        
        // Apply permanent upgrades
        ShopManager.shared.applyUpgrades(to: &self.stats)
        
        super.init()
        
        setupSprite()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSprite() {
        // Load pixel art sprite
        spriteNode = SKSpriteNode(imageNamed: "player_tariq")
        
        // If asset not found, fallback to color
        if spriteNode.texture == nil {
            spriteNode = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
        } else {
            // Scale if needed (16px art might be too small or big depending on export)
            // Assuming standard size approx 40x40
            spriteNode.scale(to: CGSize(width: 40, height: 40))
        }
        
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
        
        // Update invincibility timer
        if isInvincible {
            invincibilityTimer -= deltaTime
            if invincibilityTimer <= 0 {
                isInvincible = false
                spriteNode.alpha = 1.0
            } else {
                // Flash effect during invincibility
                spriteNode.alpha = sin(invincibilityTimer * 20) > 0 ? 1.0 : 0.3
            }
        }
        
        // Health regeneration
        if stats.healthRegenPerSecond > 0 && stats.currentHealth < stats.maxHealth {
            regenTimer += deltaTime
            if regenTimer >= 1.0 {
                heal(stats.healthRegenPerSecond)
                regenTimer = 0
            }
        }
    }
    
    func setMovementDirection(_ direction: CGPoint) {
        movementDirection = direction
        isMoving = direction.length() > 0.1
    }
    
    func takeDamage(_ amount: Float) {
        // Don't take damage if invincible
        guard !isInvincible else { return }
        
        stats.takeDamage(amount)
        
        // Activate invincibility frames
        isInvincible = true
        invincibilityTimer = invincibilityDuration
        
        // Visual feedback - flash red
        flashDamage()
    }
    
    func heal(_ amount: Float) {
        stats.heal(amount)
    }
    
    private func flashDamage() {
        let flashRed = SKAction.run { [weak self] in
            self?.spriteNode.color = .red
        }
        let wait = SKAction.wait(forDuration: 0.1)
        let resetColor = SKAction.run { [weak self] in
            self?.spriteNode.color = .blue
        }
        spriteNode.run(SKAction.sequence([flashRed, wait, resetColor]))
    }
    
    var canTakeDamage: Bool {
        return !isInvincible
    }
}

