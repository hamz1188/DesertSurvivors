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

    // Vampire Survivors-style animation
    private var bodyNode: SKNode!
    private var headNode: SKShapeNode!
    private var torsoNode: SKShapeNode!
    private var leftLeg: SKShapeNode!
    private var rightLeg: SKShapeNode!
    private var leftArm: SKShapeNode!
    private var rightArm: SKShapeNode!
    private var shadowNode: SKShapeNode!
    private var walkAnimationTime: TimeInterval = 0
    private var facingRight: Bool = true

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

        // Try to load pixel art sprite first
        let textureName = "player_\(character.rawValue)"
        let testSprite = SKSpriteNode(imageNamed: textureName)

        // If asset found, use it - otherwise create procedural character
        if testSprite.texture != nil {
            spriteNode = testSprite
            spriteNode.scale(to: CGSize(width: 40, height: 40))
            spriteNode.zPosition = Constants.ZPosition.player
            visualContainer.addChild(spriteNode)
        } else {
            // Create procedural Vampire Survivors-style character
            createProceduralCharacter()
        }

        // Setup dust trail (attached to visual container but behind sprite)
        setupDustTrail()
    }

    private func createProceduralCharacter() {
        // Body container for the whole character
        bodyNode = SKNode()
        bodyNode.zPosition = Constants.ZPosition.player
        visualContainer.addChild(bodyNode)

        // Get character-specific colors
        let (skinColor, robeColor, accentColor) = getCharacterColors()

        // Shadow (ellipse under character)
        shadowNode = SKShapeNode(ellipseOf: CGSize(width: 24, height: 10))
        shadowNode.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 0, y: -18)
        shadowNode.zPosition = -1
        bodyNode.addChild(shadowNode)

        // Legs (animated during walk)
        leftLeg = createLeg(color: robeColor)
        leftLeg.position = CGPoint(x: -5, y: -12)
        leftLeg.zPosition = 0
        bodyNode.addChild(leftLeg)

        rightLeg = createLeg(color: robeColor)
        rightLeg.position = CGPoint(x: 5, y: -12)
        rightLeg.zPosition = 0
        bodyNode.addChild(rightLeg)

        // Torso (robe/body)
        let torsoPath = CGMutablePath()
        torsoPath.move(to: CGPoint(x: -10, y: 8))
        torsoPath.addLine(to: CGPoint(x: 10, y: 8))
        torsoPath.addLine(to: CGPoint(x: 8, y: -8))
        torsoPath.addLine(to: CGPoint(x: -8, y: -8))
        torsoPath.closeSubpath()

        torsoNode = SKShapeNode(path: torsoPath)
        torsoNode.fillColor = robeColor
        torsoNode.strokeColor = robeColor.darker(by: 0.2)
        torsoNode.lineWidth = 1
        torsoNode.zPosition = 1
        bodyNode.addChild(torsoNode)

        // Belt/sash detail
        let belt = SKShapeNode(rectOf: CGSize(width: 18, height: 3), cornerRadius: 1)
        belt.fillColor = accentColor
        belt.strokeColor = .clear
        belt.position = CGPoint(x: 0, y: -2)
        belt.zPosition = 2
        bodyNode.addChild(belt)

        // Arms (animated during walk)
        leftArm = createArm(color: skinColor)
        leftArm.position = CGPoint(x: -11, y: 2)
        leftArm.zPosition = 0.5
        bodyNode.addChild(leftArm)

        rightArm = createArm(color: skinColor)
        rightArm.position = CGPoint(x: 11, y: 2)
        rightArm.zPosition = 2.5
        bodyNode.addChild(rightArm)

        // Head
        headNode = SKShapeNode(circleOfRadius: 9)
        headNode.fillColor = skinColor
        headNode.strokeColor = skinColor.darker(by: 0.15)
        headNode.lineWidth = 1
        headNode.position = CGPoint(x: 0, y: 14)
        headNode.zPosition = 3
        bodyNode.addChild(headNode)

        // Headwear based on character
        addCharacterHeadwear(accentColor: accentColor, robeColor: robeColor)

        // Eyes
        let eyeOffset: CGFloat = 3
        let leftEye = SKShapeNode(circleOfRadius: 2)
        leftEye.fillColor = .black
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -eyeOffset, y: 16)
        leftEye.zPosition = 4
        bodyNode.addChild(leftEye)

        let rightEye = SKShapeNode(circleOfRadius: 2)
        rightEye.fillColor = .black
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: eyeOffset, y: 16)
        rightEye.zPosition = 4
        bodyNode.addChild(rightEye)
    }

    private func createLeg(color: SKColor) -> SKShapeNode {
        let legPath = CGMutablePath()
        legPath.move(to: CGPoint(x: -3, y: 4))
        legPath.addLine(to: CGPoint(x: 3, y: 4))
        legPath.addLine(to: CGPoint(x: 3, y: -6))
        legPath.addLine(to: CGPoint(x: -3, y: -6))
        legPath.closeSubpath()

        let leg = SKShapeNode(path: legPath)
        leg.fillColor = color.darker(by: 0.1)
        leg.strokeColor = color.darker(by: 0.25)
        leg.lineWidth = 0.5
        return leg
    }

    private func createArm(color: SKColor) -> SKShapeNode {
        let armPath = CGMutablePath()
        armPath.move(to: CGPoint(x: -2, y: 4))
        armPath.addLine(to: CGPoint(x: 2, y: 4))
        armPath.addLine(to: CGPoint(x: 2, y: -8))
        armPath.addLine(to: CGPoint(x: -2, y: -8))
        armPath.closeSubpath()

        let arm = SKShapeNode(path: armPath)
        arm.fillColor = color
        arm.strokeColor = color.darker(by: 0.15)
        arm.lineWidth = 0.5
        return arm
    }

    private func getCharacterColors() -> (skin: SKColor, robe: SKColor, accent: SKColor) {
        switch character {
        case .tariq:
            // Desert wanderer - tan skin, brown/sand robes, red accent
            return (
                SKColor(red: 0.87, green: 0.72, blue: 0.53, alpha: 1.0),
                SKColor(red: 0.55, green: 0.42, blue: 0.32, alpha: 1.0),
                SKColor(red: 0.8, green: 0.25, blue: 0.2, alpha: 1.0)
            )
        case .amara:
            // Nomad - darker skin, blue robes, gold accent
            return (
                SKColor(red: 0.72, green: 0.55, blue: 0.42, alpha: 1.0),
                SKColor(red: 0.2, green: 0.35, blue: 0.55, alpha: 1.0),
                SKColor(red: 0.85, green: 0.7, blue: 0.25, alpha: 1.0)
            )
        case .zahra:
            // Mage - pale skin, purple robes, cyan accent
            return (
                SKColor(red: 0.92, green: 0.85, blue: 0.78, alpha: 1.0),
                SKColor(red: 0.45, green: 0.25, blue: 0.55, alpha: 1.0),
                SKColor(red: 0.3, green: 0.8, blue: 0.85, alpha: 1.0)
            )
        }
    }

    private func addCharacterHeadwear(accentColor: SKColor, robeColor: SKColor) {
        switch character {
        case .tariq:
            // Keffiyeh/head scarf
            let headwrap = SKShapeNode(circleOfRadius: 11)
            headwrap.fillColor = SKColor(red: 0.95, green: 0.9, blue: 0.85, alpha: 1.0)
            headwrap.strokeColor = accentColor
            headwrap.lineWidth = 1.5
            headwrap.position = CGPoint(x: 0, y: 15)
            headwrap.zPosition = 2.5
            bodyNode.addChild(headwrap)

        case .amara:
            // Hood
            let hoodPath = CGMutablePath()
            hoodPath.move(to: CGPoint(x: -11, y: 10))
            hoodPath.addQuadCurve(to: CGPoint(x: 11, y: 10), control: CGPoint(x: 0, y: 28))
            hoodPath.addLine(to: CGPoint(x: 8, y: 6))
            hoodPath.addQuadCurve(to: CGPoint(x: -8, y: 6), control: CGPoint(x: 0, y: 18))
            hoodPath.closeSubpath()

            let hood = SKShapeNode(path: hoodPath)
            hood.fillColor = robeColor.darker(by: 0.1)
            hood.strokeColor = robeColor.darker(by: 0.25)
            hood.lineWidth = 1
            hood.zPosition = 2.5
            bodyNode.addChild(hood)

        case .zahra:
            // Mystical circlet/tiara
            let circlet = SKShapeNode(rectOf: CGSize(width: 16, height: 4), cornerRadius: 2)
            circlet.fillColor = accentColor
            circlet.strokeColor = accentColor.lighter(by: 0.3)
            circlet.lineWidth = 1
            circlet.position = CGPoint(x: 0, y: 20)
            circlet.zPosition = 4.5
            bodyNode.addChild(circlet)

            // Gem in center
            let gem = SKShapeNode(circleOfRadius: 3)
            gem.fillColor = SKColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1.0)
            gem.strokeColor = .white
            gem.lineWidth = 0.5
            gem.position = CGPoint(x: 0, y: 21)
            gem.zPosition = 5
            bodyNode.addChild(gem)
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

            // Vampire Survivors style: flip entire character based on horizontal direction
            let newFacingRight = movementDirection.x >= 0
            if newFacingRight != facingRight {
                facingRight = newFacingRight
                isVisualDirty = true
            }

            // Update character facing
            visualContainer.xScale = facingRight ? 1.0 : -1.0

            // Subtle lean in movement direction
            let targetLean: CGFloat = movementDirection.x > 0.3 ? -0.08 : (movementDirection.x < -0.3 ? 0.08 : 0)
            visualContainer.zRotation = visualContainer.zRotation + (targetLean - visualContainer.zRotation) * 0.15

            isVisualDirty = true
        } else {
            // Reset lean when not moving
            if abs(visualContainer.zRotation) > 0.01 {
                visualContainer.zRotation = visualContainer.zRotation * 0.85
                isVisualDirty = true
            } else {
                visualContainer.zRotation = 0
            }
        }

        // Update walk animation for procedural character
        if bodyNode != nil {
            updateProceduralAnimation(deltaTime: deltaTime)
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
                if spriteNode != nil {
                    spriteNode.alpha = 1.0
                } else if bodyNode != nil {
                    bodyNode.alpha = 1.0
                }
            } else {
                let flashAlpha: CGFloat = sin(invincibilityTimer * 20) > 0 ? 1.0 : 0.3
                if spriteNode != nil {
                    spriteNode.alpha = flashAlpha
                } else if bodyNode != nil {
                    bodyNode.alpha = flashAlpha
                }
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

    private func updateProceduralAnimation(deltaTime: TimeInterval) {
        guard leftLeg != nil, rightLeg != nil, leftArm != nil, rightArm != nil else { return }

        if isMoving {
            // Advance animation timer
            walkAnimationTime += deltaTime * 12.0 // Speed of walk cycle

            // Leg animation - alternating swing
            let legSwing = sin(walkAnimationTime) * 0.5
            let legOffset = sin(walkAnimationTime) * 4

            leftLeg.zRotation = legSwing
            leftLeg.position.y = -12 + abs(legOffset) * 0.3

            rightLeg.zRotation = -legSwing
            rightLeg.position.y = -12 + abs(-legOffset) * 0.3

            // Arm animation - opposite to legs (natural walk)
            let armSwing = sin(walkAnimationTime) * 0.4
            leftArm.zRotation = -armSwing
            rightArm.zRotation = armSwing

            // Subtle body bob
            let bodyBob = abs(sin(walkAnimationTime * 2)) * 2
            bodyNode.position.y = bodyBob

            // Head slight lag/bounce
            if headNode != nil {
                headNode.position.y = 14 + sin(walkAnimationTime * 2 + 0.5) * 1
            }
        } else {
            // Idle animation - subtle breathing
            walkAnimationTime += deltaTime * 2.0

            // Reset leg positions smoothly
            leftLeg.zRotation = leftLeg.zRotation * 0.9
            rightLeg.zRotation = rightLeg.zRotation * 0.9
            leftLeg.position.y = leftLeg.position.y + (-12 - leftLeg.position.y) * 0.1
            rightLeg.position.y = rightLeg.position.y + (-12 - rightLeg.position.y) * 0.1

            // Reset arm positions
            leftArm.zRotation = leftArm.zRotation * 0.9
            rightArm.zRotation = rightArm.zRotation * 0.9

            // Gentle breathing
            let breathe = sin(walkAnimationTime) * 1.5
            bodyNode.position.y = breathe

            if headNode != nil {
                headNode.position.y = 14 + sin(walkAnimationTime + 0.3) * 0.8
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

        // Initial state - only for sprite-based characters
        if spriteNode != nil {
            if visualContainer.action(forKey: idleActionKey) == nil && visualContainer.action(forKey: walkActionKey) == nil {
                startIdleAnimation()
            }
        }

        wasMoving = isMoving
    }

    private func startIdleAnimation() {
        // Only apply SKAction animations to sprite-based characters
        guard spriteNode != nil else { return }

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
        // Only apply SKAction animations to sprite-based characters
        guard spriteNode != nil else { return }

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

