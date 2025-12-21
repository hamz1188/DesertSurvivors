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

    private var visualContainer: SKNode!
    private var spriteNode: SKSpriteNode!
    private var dustTrail: SKEmitterNode?

    // 8-directional sprite system
    enum Direction: String, CaseIterable {
        case south, north, east, west
        case southEast = "south-east"
        case southWest = "south-west"
        case northEast = "north-east"
        case northWest = "north-west"
    }

    private var directionalTextures: [Direction: SKTexture] = [:]
    private var currentDirection: Direction = .south
    private var hasDirectionalSprites: Bool = false
    
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
    
    
    private func setupSprite() {
        // Container for all visual elements (sprite, trails, etc.)
        visualContainer = SKNode()
        addChild(visualContainer)

        // Try to load 8-directional sprites first (new PixelLab sprites)
        loadDirectionalTextures()

        if hasDirectionalSprites {
            // Use new directional sprite system
            spriteNode = SKSpriteNode(texture: directionalTextures[.south])
            spriteNode.size = CGSize(width: 48, height: 48) // 64x64 canvas scaled to gameplay size
        } else {
            // Fallback to legacy single sprite
            let textureName = "player_\(character.rawValue)"
            spriteNode = SKSpriteNode(imageNamed: textureName)

            if spriteNode.texture == nil {
                spriteNode = SKSpriteNode(color: .blue, size: CGSize(width: 30, height: 30))
            } else {
                spriteNode.scale(to: CGSize(width: 40, height: 40))
            }
        }

        spriteNode.zPosition = Constants.ZPosition.player
        visualContainer.addChild(spriteNode)

        // Setup dust trail (attached to visual container but behind sprite)
        setupDustTrail()
    }

    private func loadDirectionalTextures() {
        // Character name mapping for PixelLab sprites
        let characterName: String
        switch character {
        case .tariq:
            characterName = "Tariq"
        case .amara:
            characterName = "Amara"
        case .zahra:
            characterName = "Zahra"
        }

        // Try to load all 8 directions
        var loadedCount = 0
        for direction in Direction.allCases {
            let textureName = direction == .south ? characterName : "\(characterName)-\(direction.rawValue)"
            let texture = SKTexture(imageNamed: textureName)

            // Check if texture loaded successfully (has valid size)
            if texture.size().width > 0 && texture.size().height > 0 {
                directionalTextures[direction] = texture
                loadedCount += 1
            }
        }

        // Consider directional sprites available if we loaded at least 4 directions
        hasDirectionalSprites = loadedCount >= 4

        // If we have directional sprites but missing some, fill in with south as fallback
        if hasDirectionalSprites {
            if let southTexture = directionalTextures[.south] {
                for direction in Direction.allCases where directionalTextures[direction] == nil {
                    directionalTextures[direction] = southTexture
                }
            }
        }
    }

    private func updateSpriteDirection() {
        guard hasDirectionalSprites else { return }

        let newDirection = getDirectionFromMovement(movementDirection)

        // Only update texture if direction changed
        if newDirection != currentDirection {
            currentDirection = newDirection
            if let texture = directionalTextures[newDirection] {
                spriteNode.texture = texture
            }
        }
    }

    private func getDirectionFromMovement(_ direction: CGPoint) -> Direction {
        let angle = atan2(direction.y, direction.x)
        let degrees = angle * 180 / .pi

        // Map angle to 8 directions (SpriteKit uses standard math coordinates)
        // East = 0°, North = 90°, West = 180°/-180°, South = -90°
        switch degrees {
        case -22.5..<22.5:
            return .east
        case 22.5..<67.5:
            return .northEast
        case 67.5..<112.5:
            return .north
        case 112.5..<157.5:
            return .northWest
        case 157.5...180, -180..<(-157.5):
            return .west
        case -157.5..<(-112.5):
            return .southWest
        case -112.5..<(-67.5):
            return .south
        case -67.5..<(-22.5):
            return .southEast
        default:
            return .south
        }
    }

    private func setupDustTrail() {
        let trail = SKEmitterNode()
        trail.particleBirthRate = 0
        trail.particleLifetime = 0.4
        trail.particlePositionRange = CGVector(dx: 15, dy: 5)
        trail.particleSpeed = 30
        trail.particleSpeedRange = 10
        trail.emissionAngle = .pi * 1.5
        trail.emissionAngleRange = 0.6
        trail.particleAlpha = 0.5
        trail.particleAlphaSpeed = -1.2
        trail.particleScale = 0.08
        trail.particleScaleSpeed = 0.1
        trail.particleColor = SKColor(red: 0.96, green: 0.87, blue: 0.70, alpha: 1.0)
        trail.particleColorBlendFactor = 1.0
        trail.zPosition = -1
        trail.position = CGPoint(x: 0, y: -15)
        
        visualContainer.addChild(trail)
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
    private let idleActionKey = "player_animation_idle"
    private let walkActionKey = "player_animation_walk"
    
    // Track previous movement state to detect transitions
    private var isVisualDirty: Bool = true
    private var wasMoving: Bool = false

    func update(deltaTime: TimeInterval) {
        // Update movement
        if isMoving && movementDirection.length() > 0 {
            let speed = CGFloat(stats.moveSpeed) * CGFloat(deltaTime)
            let movement = movementDirection.normalized() * speed
            position = position + movement

            if hasDirectionalSprites {
                // Use 8-directional sprites - update texture based on movement direction
                updateSpriteDirection()
                // Subtle lean for visual feedback
                let leanAngle: CGFloat = movementDirection.x > 0 ? -0.08 : (movementDirection.x < 0 ? 0.08 : 0)
                visualContainer.zRotation = visualContainer.zRotation + (leanAngle - visualContainer.zRotation) * 0.1
            } else {
                // Legacy: Flip and Lean based on direction
                let leanAngle: CGFloat = movementDirection.x > 0 ? -0.15 : 0.15
                let targetXScale: CGFloat = movementDirection.x > 0 ? 1.0 : -1.0
                visualContainer.xScale = visualContainer.xScale + (targetXScale - visualContainer.xScale) * 0.2
                visualContainer.zRotation = visualContainer.zRotation + (leanAngle - visualContainer.zRotation) * 0.1
            }

            isVisualDirty = true
        } else {
            // Only reset rotation if it's not already zeroed
            if abs(visualContainer.zRotation) > 0.01 {
                visualContainer.zRotation = visualContainer.zRotation * 0.8
                isVisualDirty = true
            } else {
                visualContainer.zRotation = 0
            }

            if !hasDirectionalSprites {
                if visualContainer.xScale != 1.0 && visualContainer.xScale != -1.0 {
                    visualContainer.xScale = visualContainer.xScale > 0 ? 1.0 : -1.0
                    isVisualDirty = true
                }
            }
        }
        
        // Update animations
        if isVisualDirty || isMoving != wasMoving {
            updateAnimations()
            isVisualDirty = false
        }
        
        // Update invincibility timer
        if isInvincible {
            invincibilityTimer -= deltaTime
            if invincibilityTimer <= 0 {
                isInvincible = false
                spriteNode.alpha = 1.0
            } else {
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
            dustTrail?.particleBirthRate = 40
        } else if !isMoving && wasMoving {
            startIdleAnimation()
            dustTrail?.particleBirthRate = 0
        }
        
        // Initial state
        if visualContainer.action(forKey: idleActionKey) == nil && visualContainer.action(forKey: walkActionKey) == nil {
            startIdleAnimation()
        }
        
        wasMoving = isMoving
    }
    
    private func startIdleAnimation() {
        visualContainer.removeAction(forKey: walkActionKey)
        
        // Breathing effect: subtle scale and lift
        let breatheUp = SKAction.group([
            SKAction.moveBy(x: 0, y: 3, duration: 0.8),
            SKAction.scaleY(to: 1.05, duration: 0.8)
        ])
        let breatheDown = SKAction.group([
            SKAction.moveBy(x: 0, y: -3, duration: 0.8),
            SKAction.scaleY(to: 1.0, duration: 0.8)
        ])
        
        breatheUp.timingMode = .easeInEaseOut
        breatheDown.timingMode = .easeInEaseOut
        
        let idleCycle = SKAction.repeatForever(SKAction.sequence([breatheUp, breatheDown]))
        visualContainer.run(idleCycle, withKey: idleActionKey)
    }
    
    private func startWalkAnimation() {
        visualContainer.removeAction(forKey: idleActionKey)
        
        // Bouncy walk with "jump" and "squash" feel
        // Part 1: Jump up
        let jump = SKAction.group([
            SKAction.moveBy(x: 0, y: 8, duration: 0.12),
            SKAction.scaleY(to: 1.15, duration: 0.12),
            SKAction.scaleX(to: 0.9, duration: 0.12)
        ])
        jump.timingMode = .easeOut
        
        // Part 2: Fall and squash
        let land = SKAction.group([
            SKAction.moveBy(x: 0, y: -8, duration: 0.12),
            SKAction.scaleY(to: 0.85, duration: 0.12),
            SKAction.scaleX(to: 1.15, duration: 0.12)
        ])
        land.timingMode = .easeIn
        
        // Part 3: Reset to neutral
        let reset = SKAction.group([
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        let walkCycle = SKAction.repeatForever(SKAction.sequence([jump, land, reset]))
        visualContainer.run(walkCycle, withKey: walkActionKey)
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

