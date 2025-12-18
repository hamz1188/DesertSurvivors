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
    private var xpBar: SKShapeNode!
    private var xpBarBackground: SKShapeNode!
    private var levelLabel: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var killCountLabel: SKLabelNode!
    
    private let healthBarWidth: CGFloat = 200
    private let healthBarHeight: CGFloat = 20
    private let xpBarWidth: CGFloat = 200
    private let xpBarHeight: CGFloat = 10
    
    override init() {
        super.init()
        setupHUD()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHUD() {
        zPosition = Constants.ZPosition.hud
        
        // Health Bar
        healthBarBackground = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthBarBackground.fillColor = .darkGray
        healthBarBackground.strokeColor = .black
        healthBarBackground.position = CGPoint(x: 0, y: 0)
        addChild(healthBarBackground)
        
        healthBar = SKShapeNode(rectOf: CGSize(width: healthBarWidth, height: healthBarHeight))
        healthBar.fillColor = Constants.Colors.healthRed
        healthBar.strokeColor = .clear
        healthBar.position = CGPoint(x: 0, y: 0)
        addChild(healthBar)
        
        // XP Bar
        xpBarBackground = SKShapeNode(rectOf: CGSize(width: xpBarWidth, height: xpBarHeight))
        xpBarBackground.fillColor = .darkGray
        xpBarBackground.strokeColor = .black
        xpBarBackground.position = CGPoint(x: 0, y: -30)
        addChild(xpBarBackground)
        
        xpBar = SKShapeNode(rectOf: CGSize(width: xpBarWidth, height: xpBarHeight))
        xpBar.fillColor = Constants.Colors.xpBlue
        xpBar.strokeColor = .clear
        xpBar.position = CGPoint(x: 0, y: -30)
        addChild(xpBar)
        
        // Level Label
        levelLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: -healthBarWidth/2 - 30, y: 0)
        levelLabel.text = "Lv.1"
        addChild(levelLabel)
        
        // Timer Label
        timerLabel = SKLabelNode(fontNamed: "Arial")
        timerLabel.fontSize = 16
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: healthBarWidth/2 + 50, y: 0)
        timerLabel.text = "00:00"
        addChild(timerLabel)
        
        // Kill Count Label
        killCountLabel = SKLabelNode(fontNamed: "Arial")
        killCountLabel.fontSize = 14
        killCountLabel.fontColor = .white
        killCountLabel.position = CGPoint(x: healthBarWidth/2 + 50, y: -20)
        killCountLabel.text = "Kills: 0"
        addChild(killCountLabel)
    }
    
    func updateHealth(_ percentage: Float) {
        let width = healthBarWidth * CGFloat(percentage.clamped(min: 0, max: 1))
        healthBar.path = CGPath(rect: CGRect(x: -width/2, y: -healthBarHeight/2, width: width, height: healthBarHeight), transform: nil)
    }
    
    func updateXP(_ percentage: Float) {
        let width = xpBarWidth * CGFloat(percentage.clamped(min: 0, max: 1))
        xpBar.path = CGPath(rect: CGRect(x: -width/2, y: -xpBarHeight/2, width: width, height: xpBarHeight), transform: nil)
    }
    
    func updateLevel(_ level: Int) {
        levelLabel.text = "Lv.\(level)"
    }
    
    func updateTimer(_ time: TimeInterval) {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func updateKillCount(_ kills: Int) {
        killCountLabel.text = "Kills: \(kills)"
    }
    
    func positionHUD(in scene: SKScene) {
        // Position at top of screen
        position = CGPoint(x: -scene.size.width/2 + 20, y: scene.size.height/2 - 40)
    }
}

