//
//  Player.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class Player: SKNode {
    var stats: PlayerStats
    var character: CharacterType
    var movementDirection: CGPoint = .zero
    var isMoving: Bool = false
    
    private var spriteNode: SKSpriteNode!
    
    // Invincibility frames system
    private var isInvincible: Bool = false
    private var invincibilityTimer: TimeInterval = 0
    private let invincibilityDuration: TimeInterval = 0.5 // 0.5 seconds of invincibility after hit
    
    // Health regeneration
    private var regenTimer: TimeInterval = 0
    
    init(character: CharacterType = .tariq, stats: PlayerStats = PlayerStats(), applyShopUpgrades: Bool = true) {
        self.character = character
        self.stats = stats
        
        // Apply permanent upgrades if requested
        if applyShopUpgrades {
            ShopManager.shared.applyUpgrades(to: &self.stats)
        }
        
        // Apply character specific stats
        character.applyBaseStats(to: &self.stats)
        
        super.init()
        
        setupSprite()
        setupPhysics()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var dustTrail: SKEmitterNode?
    
    private func setupSprite() {
        // Load pixel art sprite
        let textureName = "player_\(character.rawValue)"
        spriteNode = SKSpriteNode(imageNamed: textureName)
        
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
        
        // Setup dust trail
        setupDustTrail()
    }
    
    private func setupDustTrail() {
        let trail = SKEmitterNode()
        trail.particleBirthRate = 0 // Start off
        trail.particleLifetime = 0.4
        trail.particlePositionRange = CGVector(dx: 10, dy: 5)
        trail.particleSpeed = 20
        trail.particleSpeedRange = 10
        trail.emissionAngle = .pi * 1.5 // Downwards
        trail.emissionAngleRange = 0.4
        trail.particleAlpha = 0.4
        trail.particleAlphaSpeed = -1.0
        trail.particleScale = 0.05
        trail.particleScaleSpeed = 0.2
        trail.particleColor = SKColor(red: 0.96, green: 0.87, blue: 0.70, alpha: 1.0) // Sand color
        trail.particleColorBlendFactor = 1.0
        trail.zPosition = -1 // Behind player
        
        addChild(trail)
        self.dustTrail = trail
    }
    
    private func setupPhysics() {
        physicsBody = SKPhysicsBody(circleOfRadius: 15)
        physicsBody?.categoryBitMask = Constants.PhysicsCategory.player
        physicsBody?.collisionBitMask = Constants.PhysicsCategory.none
        physicsBody?.contactTestBitMask = Constants.PhysicsCategory.enemy | Constants.PhysicsCategory.pickup
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = false
    }
    
    // Animation actions
    private let idleActionKey = "player_idle"
    private let walkActionKey = "player_walk"
    
    // Track previous movement state to detect transitions
    private var wasMoving: Bool = false
    
    func update(deltaTime: TimeInterval) {
        // Update movement
        if isMoving && movementDirection.length() > 0 {
            let speed = CGFloat(stats.moveSpeed) * CGFloat(deltaTime)
            let movement = movementDirection.normalized() * speed
            position = position + movement
            
            // Flip sprite based on direction
            if movementDirection.x > 0 {
                spriteNode.xScale = abs(spriteNode.xScale)
            } else if movementDirection.x < 0 {
                spriteNode.xScale = -abs(spriteNode.xScale)
            }
        }
        
        // Update animations
        updateAnimations()
        
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
    
    private func updateAnimations() {
        if isMoving && !wasMoving {
            startWalkAnimation()
            dustTrail?.particleBirthRate = 30
        } else if !isMoving && wasMoving {
            startIdleAnimation()
            dustTrail?.particleBirthRate = 0
        }
        
        // If first run, start idle
        if spriteNode.action(forKey: idleActionKey) == nil && spriteNode.action(forKey: walkActionKey) == nil {
            startIdleAnimation()
        }
        
        wasMoving = isMoving
    }
    
    private func startIdleAnimation() {
        spriteNode.removeAction(forKey: walkActionKey)
        
        let bobUp = SKAction.moveBy(x: 0, y: 2, duration: 0.6)
        let bobDown = SKAction.moveBy(x: 0, y: -2, duration: 0.6)
        bobUp.timingMode = .easeInEaseOut
        bobDown.timingMode = .easeInEaseOut
        
        let scaleLarge = SKAction.scaleY(to: 1.02, duration: 0.6)
        let scaleSmall = SKAction.scaleY(to: 0.98, duration: 0.6)
        scaleLarge.timingMode = .easeInEaseOut
        scaleSmall.timingMode = .easeInEaseOut
        
        let bobGroup = SKAction.group([
            SKAction.sequence([bobUp, bobDown]),
            SKAction.sequence([scaleSmall, scaleLarge])
        ])
        
        spriteNode.run(SKAction.repeatForever(bobGroup), withKey: idleActionKey)
        
        // Reset rotation and position offset gradually
        spriteNode.run(SKAction.rotate(toAngle: 0, duration: 0.2))
    }
    
    private func startWalkAnimation() {
        spriteNode.removeAction(forKey: idleActionKey)
        
        // Bouncy walk
        let bounceUp = SKAction.moveBy(x: 0, y: 4, duration: 0.15)
        let bounceDown = SKAction.moveBy(x: 0, y: -4, duration: 0.15)
        bounceUp.timingMode = .easeOut
        bounceDown.timingMode = .easeIn
        
        let tiltRight = SKAction.rotate(toAngle: -0.1, duration: 0.15)
        let tiltLeft = SKAction.rotate(toAngle: 0.1, duration: 0.15)
        
        let walkStep = SKAction.sequence([
            SKAction.group([bounceUp, tiltRight]),
            SKAction.group([bounceDown, tiltLeft])
        ])
        
        spriteNode.run(SKAction.repeatForever(walkStep), withKey: walkActionKey)
    }
    
    func setMovementDirection(_ direction: CGPoint) {
        movementDirection = direction
        isMoving = direction.length() > 0.1
    }
    
    func takeDamage(_ amount: Float) {
        // Don't take damage if invincible
        guard !isInvincible else { return }
        
        let wasDamaged = stats.takeDamage(amount)
        
        if wasDamaged {
            // Activate invincibility frames
            isInvincible = true
            invincibilityTimer = invincibilityDuration
            
            // Visual feedback - flash red
            flashDamage()
        } else {
            // Dodged!
            showDodgeEffect()
        }
    }
    
    private func showDodgeEffect() {
        let dodgeLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        dodgeLabel.text = "DODGE"
        dodgeLabel.fontSize = 14
        dodgeLabel.fontColor = .cyan
        dodgeLabel.position = CGPoint(x: 0, y: 30)
        dodgeLabel.zPosition = Constants.ZPosition.ui
        addChild(dodgeLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        dodgeLabel.run(SKAction.sequence([
            SKAction.group([moveUp, fadeOut]),
            remove
        ]))
    }
    
    func heal(_ amount: Float) {
        stats.heal(amount)
    }
    
    private func flashDamage() {
        let originalBlend = spriteNode.colorBlendFactor
        spriteNode.color = .red
        spriteNode.colorBlendFactor = 0.5
        
        let wait = SKAction.wait(forDuration: 0.1)
        let reset = SKAction.run { [weak self] in
            self?.spriteNode.colorBlendFactor = originalBlend
        }
        spriteNode.run(SKAction.sequence([wait, reset]))
    }
    
    var canTakeDamage: Bool {
        return !isInvincible
    }
}

