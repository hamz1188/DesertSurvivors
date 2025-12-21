//
//  LevelUpUI.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

enum LevelUpChoice {
    case newWeapon(BaseWeapon)
    case weaponUpgrade(BaseWeapon)
    case newPassive(PassiveItem)
    case passiveUpgrade(PassiveItem)
    case gold(Int)
    case healthRestore(Float)
    
    var displayName: String {
        switch self {
        case .newWeapon(let weapon):
            return "New: \(weapon.weaponName)"
        case .weaponUpgrade(let weapon):
            return "Upgrade: \(weapon.weaponName) Lv.\(weapon.level + 1)"
        case .newPassive(let item):
            return "New: \(item.name)"
        case .passiveUpgrade(let item):
            return "Upgrade: \(item.name) Lv.\(item.level + 1)"
        case .gold(let amount):
            return "Gold: \(amount)"
        case .healthRestore(let amount):
            return "Heal: \(Int(amount)) HP"
        }
    }
    
    var description: String {
        switch self {
        case .newWeapon(let weapon):
            return "Add \(weapon.weaponName) to your arsenal"
        case .weaponUpgrade(let weapon):
            return "Increase \(weapon.weaponName) power"
        case .newPassive(let item):
            return item.description
        case .passiveUpgrade(let item):
            return "Improve \(item.name) effect"
        case .gold(let amount):
            return "Collect \(amount) gold coins"
        case .healthRestore(let amount):
            return "Restore \(Int(amount)) health"
        }
    }
}

class LevelUpUI: SKNode {
    private var background: SKShapeNode?
    private var titleLabel: SKLabelNode?
    private var choiceButtons: [SKNode] = []
    private var choices: [LevelUpChoice] = []
    
    var onChoiceSelected: ((LevelUpChoice) -> Void)?
    var isVisible: Bool = false
    
    override init() {
        super.init()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        zPosition = Constants.ZPosition.ui

        // Background overlay
        let newBackground = SKShapeNode(rectOf: CGSize(width: 400, height: 500))
        newBackground.fillColor = SKColor(white: 0.1, alpha: 0.95)
        newBackground.strokeColor = .white
        newBackground.lineWidth = 3
        newBackground.isHidden = true
        background = newBackground
        addChild(newBackground)

        // Title
        let newTitleLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        newTitleLabel.fontSize = 32
        newTitleLabel.fontColor = .yellow
        newTitleLabel.text = "LEVEL UP!"
        newTitleLabel.position = CGPoint(x: 0, y: 200)
        newTitleLabel.isHidden = true
        titleLabel = newTitleLabel
        addChild(newTitleLabel)
    }
    
    func showChoices(_ choices: [LevelUpChoice], in scene: SKScene) {
        self.choices = choices
        isVisible = true

        // Show background and title
        background?.isHidden = false
        titleLabel?.isHidden = false
        
        // Play Sound
        SoundManager.shared.playSFX(filename: "sfx_level_up.wav", scene: scene)
        
        // Clear old buttons
        for button in choiceButtons {
            button.removeFromParent()
        }
        choiceButtons.removeAll()
        
        // Create choice buttons
        let buttonHeight: CGFloat = 80
        let spacing: CGFloat = 10
        let startY: CGFloat = 120
        
        for (index, choice) in choices.enumerated() {
            let button = createChoiceButton(choice: choice, index: index)
            let yPosition = startY - CGFloat(index) * (buttonHeight + spacing)
            button.position = CGPoint(x: 0, y: yPosition)
            addChild(button)
            choiceButtons.append(button)
        }
    }
    
    private func createChoiceButton(choice: LevelUpChoice, index: Int) -> SKNode {
        let container = SKNode()
        
        // Button background
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 350, height: 80), cornerRadius: 10)
        buttonBg.fillColor = SKColor(white: 0.2, alpha: 0.9)
        buttonBg.strokeColor = .white
        buttonBg.lineWidth = 2
        buttonBg.name = "choice_\(index)"
        container.addChild(buttonBg)
        
        // Choice name
        let nameLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        nameLabel.fontSize = 20
        nameLabel.fontColor = .white
        nameLabel.text = choice.displayName
        nameLabel.position = CGPoint(x: 0, y: 15)
        nameLabel.horizontalAlignmentMode = .center
        container.addChild(nameLabel)
        
        // Choice description
        let descLabel = SKLabelNode(fontNamed: "Arial")
        descLabel.fontSize = 14
        descLabel.fontColor = .lightGray
        descLabel.text = choice.description
        descLabel.position = CGPoint(x: 0, y: -10)
        descLabel.horizontalAlignmentMode = .center
        container.addChild(descLabel)
        
        return container
    }
    
    func hide() {
        isVisible = false
        background?.isHidden = true
        titleLabel?.isHidden = true
        for button in choiceButtons {
            button.removeFromParent()
        }
        choiceButtons.removeAll()
    }
    
    func handleTouch(at location: CGPoint) -> Bool {
        guard isVisible else { return false }
        
        for (index, button) in choiceButtons.enumerated() {
            if button.contains(location) {
                if index < choices.count {
                    onChoiceSelected?(choices[index])
                    hide()
                    return true
                }
            }
        }
        return false
    }
}

