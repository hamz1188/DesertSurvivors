//
//  HUD.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class HUD: SKNode {
    private var healthBar: SKShapeNode!
    private var healthBarBackground: SKShapeNode!
    private var healthBarBorder: SKShapeNode!
    private var xpBar: SKShapeNode!
    private var xpBarBackground: SKShapeNode!
    private var xpBarBorder: SKShapeNode!
    private var levelLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var killCountLabel: SKLabelNode!
    private var goldLabel: SKLabelNode!
    private var goldIcon: SKSpriteNode!
    
    private let healthBarWidth: CGFloat = 200
    private let healthBarHeight: CGFloat = 20
    private let xpBarWidth: CGFloat = 200
    private let xpBarHeight: CGFloat = 10
    
    override init() {
        super.init()
        setupHUD()
        setupAccessibility()
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = false // Container is not an element, its children are
        
        healthBarBackground.isAccessibilityElement = true
        healthBarBackground.accessibilityLabel = "Health Bar"
        
        xpBarBackground.isAccessibilityElement = true
        xpBarBackground.accessibilityLabel = "Experience Bar"
        
        levelLabel.isAccessibilityElement = true
        levelLabel.accessibilityLabel = "Player Level"
        
        timerLabel.isAccessibilityElement = true
        timerLabel.accessibilityLabel = "Game Timer"
        
        killCountLabel.isAccessibilityElement = true
        killCountLabel.accessibilityLabel = "Kills"
        
        goldLabel.isAccessibilityElement = true
        goldLabel.accessibilityLabel = "Gold"
        
        if let pauseBtn = childNode(withName: "pauseButton") {
            pauseBtn.isAccessibilityElement = true
            pauseBtn.accessibilityLabel = "Pause Game"
            pauseBtn.accessibilityHint = "Double tap to pause or resume the game"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        zPosition = Constants.ZPosition.hud
        
        // Health Bar Background - use path for left-aligned fill
        let healthBgRect = CGRect(x: 0, y: -healthBarHeight/2, width: healthBarWidth, height: healthBarHeight)
        healthBarBackground = SKShapeNode(path: CGPath(roundedRect: healthBgRect, cornerWidth: 4, cornerHeight: 4, transform: nil))
        healthBarBackground.fillColor = SKColor(white: 0.2, alpha: 0.8)
        healthBarBackground.strokeColor = .clear
        healthBarBackground.position = CGPoint(x: 0, y: 0)
        addChild(healthBarBackground)
        
        // Health Bar Fill - starts from left
        healthBar = SKShapeNode()
        healthBar.fillColor = Constants.Colors.healthRed
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: 0, y: 0)
        addChild(healthBar)
        updateHealth(1.0) // Initialize full health
        
        // Health Bar Border
        let healthBorderRect = CGRect(x: -2, y: -healthBarHeight/2 - 2, width: healthBarWidth + 4, height: healthBarHeight + 4)
        healthBarBorder = SKShapeNode(path: CGPath(roundedRect: healthBorderRect, cornerWidth: 5, cornerHeight: 5, transform: nil))
        healthBarBorder.fillColor = .clear
        healthBarBorder.strokeColor = .white
        healthBarBorder.lineWidth = 2
        healthBarBorder.position = CGPoint(x: 0, y: 0)
        addChild(healthBarBorder)
        
        // XP Bar Background - use path for left-aligned fill
        let xpBgRect = CGRect(x: 0, y: -xpBarHeight/2, width: xpBarWidth, height: xpBarHeight)
        xpBarBackground = SKShapeNode(path: CGPath(roundedRect: xpBgRect, cornerWidth: 2, cornerHeight: 2, transform: nil))
        xpBarBackground.fillColor = SKColor(white: 0.2, alpha: 0.8)
        xpBarBackground.strokeColor = .clear
        xpBarBackground.position = CGPoint(x: 0, y: -20)
        addChild(xpBarBackground)
        
        // XP Bar Fill
        xpBar = SKShapeNode()
        xpBar.fillColor = Constants.Colors.xpBlue
        xpBar.strokeColor = .clear
        xpBar.position = CGPoint(x: 0, y: -20)
        addChild(xpBar)
        updateXP(0.0) // Initialize empty XP
        
        // XP Bar Border
        let xpBorderRect = CGRect(x: -1, y: -xpBarHeight/2 - 1, width: xpBarWidth + 2, height: xpBarHeight + 2)
        xpBarBorder = SKShapeNode(path: CGPath(roundedRect: xpBorderRect, cornerWidth: 3, cornerHeight: 3, transform: nil))
        xpBarBorder.fillColor = .clear
        xpBarBorder.strokeColor = SKColor(white: 0.7, alpha: 0.8)
        xpBarBorder.lineWidth = 1
        xpBarBorder.position = CGPoint(x: 0, y: -20)
        addChild(xpBarBorder)
        
        // Level Label (left of health bar)
        levelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .right
        levelLabel.position = CGPoint(x: -10, y: 0)
        levelLabel.text = "Lv.1"
        addChild(levelLabel)
        
        // Timer Label (right side)
        timerLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        timerLabel.fontSize = 16
        timerLabel.fontColor = .white
        timerLabel.verticalAlignmentMode = .center
        timerLabel.horizontalAlignmentMode = .left
        timerLabel.position = CGPoint(x: healthBarWidth + 15, y: 0)
        timerLabel.text = "00:00"
        addChild(timerLabel)
        
        // Kill Count Label
        killCountLabel = SKLabelNode(fontNamed: "Arial")
        killCountLabel.fontSize = 12
        killCountLabel.fontColor = SKColor(white: 0.9, alpha: 1.0)
        killCountLabel.verticalAlignmentMode = .center
        killCountLabel.horizontalAlignmentMode = .left
        killCountLabel.position = CGPoint(x: healthBarWidth + 15, y: -20)
        killCountLabel.text = "Kills: 0"
        addChild(killCountLabel)
        
        // Gold Icon (small square)
        goldIcon = SKSpriteNode(color: Constants.Colors.desertOrange, size: CGSize(width: 12, height: 12))
        goldIcon.position = CGPoint(x: healthBarWidth + 15, y: -38)
        addChild(goldIcon)
        
        // Gold Label
        goldLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        goldLabel.fontSize = 12
        goldLabel.fontColor = Constants.Colors.desertOrange
        goldLabel.verticalAlignmentMode = .center
        goldLabel.horizontalAlignmentMode = .left
        goldLabel.position = CGPoint(x: healthBarWidth + 30, y: -38)
        goldLabel.text = "0"
        addChild(goldLabel)
        
        // Pause Button
        let pauseBtn = SKSpriteNode(color: .white, size: CGSize(width: 30, height: 30)) // Placeholder icon
        pauseBtn.name = "pauseButton"
        // Position relative to top-right
        pauseBtn.position = CGPoint(x: healthBarWidth + 100, y: 0) // Will be adjusted in positionHUD
        addChild(pauseBtn)
        
        // Simple pause icon lines
        let l1 = SKShapeNode(rectOf: CGSize(width: 6, height: 16))
        l1.fillColor = .black
        l1.position = CGPoint(x: -5, y: 0)
        pauseBtn.addChild(l1)
        let l2 = SKShapeNode(rectOf: CGSize(width: 6, height: 16))
        l2.fillColor = .black
        l2.position = CGPoint(x: 5, y: 0)
        pauseBtn.addChild(l2)
    }
    
    func updateHealth(_ percentage: Float) {
        let clampedPercent = CGFloat(percentage.clamped(min: 0, max: 1))
        let width = max(1, healthBarWidth * clampedPercent) // Minimum 1 to avoid 0-width path
        let rect = CGRect(x: 0, y: -healthBarHeight/2, width: width, height: healthBarHeight)
        healthBar.path = CGPath(roundedRect: rect, cornerWidth: 4, cornerHeight: 4, transform: nil)
        
        // Accessibility
        healthBarBackground.accessibilityValue = "\(Int(percentage * 100)) percent health"
        
        // Change color based on health
        if percentage < 0.25 {
            healthBar.fillColor = SKColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 1.0)
        } else if percentage < 0.5 {
            healthBar.fillColor = SKColor(red: 0.9, green: 0.5, blue: 0.1, alpha: 1.0)
        } else {
            healthBar.fillColor = Constants.Colors.healthRed
        }
    }
    
    func updateXP(_ percentage: Float) {
        let clampedPercent = CGFloat(percentage.clamped(min: 0, max: 1))
        if clampedPercent <= 0 {
            xpBar.path = nil
            xpBarBackground.accessibilityValue = "0 percent experience"
            return
        }
        let width = xpBarWidth * clampedPercent
        let rect = CGRect(x: 0, y: -xpBarHeight/2, width: width, height: xpBarHeight)
        xpBar.path = CGPath(roundedRect: rect, cornerWidth: 2, cornerHeight: 2, transform: nil)
        
        // Accessibility
        xpBarBackground.accessibilityValue = "\(Int(percentage * 100)) percent experience"
    }
    
    func updateLevel(_ level: Int) {
        levelLabel.text = "Lv.\(level)"
        levelLabel.accessibilityValue = "Level \(level)"
        
        // Flash effect on level up
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        levelLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    func updateTimer(_ time: TimeInterval) {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let timeStr = String(format: "%02d:%02d", minutes, seconds)
        timerLabel.text = timeStr
        timerLabel.accessibilityValue = "\(minutes) minutes \(seconds) seconds"
    }
    
    func updateKillCount(_ kills: Int) {
        killCountLabel.text = "Kills: \(kills)"
        killCountLabel.accessibilityValue = "\(kills) kills"
    }
    
    func updateGold(_ gold: Int) {
        goldLabel.text = "\(gold)"
        goldLabel.accessibilityValue = "\(gold) gold"
        
        // Small pop effect when gold changes
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.05)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.05)
        goldLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    func positionHUD(in scene: SKScene) {
        guard let view = scene.view else { return }
        
        // Use actual safe area insets if available, otherwise use substantial default
        let topInset = view.safeAreaInsets.top
        let leftInset = view.safeAreaInsets.left
        
        // Dynamic Island/Notch safety. 
        // 100pts is safe for almost all modern iPhones to be well below the pill/clock area.
        let topMargin = max(topInset, 100) 
        let leftMargin = max(leftInset, 20)
        
        let levelLabelSpace: CGFloat = 40
        
        // Calculate the visible height/width in scene coordinates
        let visibleHeight = scene.size.height
        let visibleWidth = scene.size.width
        
        // Determine position
        let xPos = -visibleWidth/2 + leftMargin + levelLabelSpace
        let yPos = visibleHeight/2 - topMargin
        
        position = CGPoint(x: xPos, y: yPos)
        
        // Reposition Pause Button to far right
        if let pauseBtn = childNode(withName: "pauseButton") {
            let rightLimit = visibleWidth - leftMargin * 2 - levelLabelSpace
            pauseBtn.position = CGPoint(x: rightLimit - 20, y: 0)
        }
    }
}

