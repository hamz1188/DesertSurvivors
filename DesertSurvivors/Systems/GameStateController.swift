//
//  GameStateController.swift
//  DesertSurvivors
//
//  Manages game state transitions: pause, level-up flow, and game over.
//

import SpriteKit

protocol GameStateControllerDelegate: AnyObject {
    var physicsWorldSpeed: CGFloat { get set }
    var lastUpdateTime: TimeInterval { get set }
    func getPlayer() -> Player?
    func getWeaponManager() -> WeaponManager?
    func getPassiveItemManager() -> PassiveItemManager?
    func getLevelUpChoiceGenerator() -> LevelUpChoiceGenerator?
    func getLevelUpSystem() -> LevelUpSystem?
    func getLevelUpUI() -> LevelUpUI?
    func getJoystick() -> VirtualJoystick?
    func getCamera() -> SKCameraNode?
    func getScene() -> SKScene?
}

class GameStateController {
    weak var delegate: GameStateControllerDelegate?

    private(set) var isGamePaused: Bool = false
    private(set) var gameTime: TimeInterval = 0
    private(set) var killCount: Int = 0
    private(set) var gold: Int = 0

    init() {}

    // MARK: - Time & Stats

    func addTime(_ deltaTime: TimeInterval) {
        gameTime += deltaTime
    }

    func addKill() {
        killCount += 1
    }

    func addGold(_ amount: Int) {
        gold += amount
    }

    // MARK: - Pause

    func togglePause() {
        guard let camera = delegate?.getCamera(),
              let joystick = delegate?.getJoystick() else { return }

        isGamePaused.toggle()

        if isGamePaused {
            let pauseMenu = PauseMenuUI()
            pauseMenu.name = "pauseMenu"
            pauseMenu.resumeAction = { [weak self] in
                self?.togglePause()
            }
            pauseMenu.quitAction = {
                SceneManager.shared.presentMainMenu()
            }
            camera.addChild(pauseMenu)

            delegate?.physicsWorldSpeed = 0
            joystick.isUserInteractionEnabled = false
        } else {
            camera.childNode(withName: "pauseMenu")?.removeFromParent()
            delegate?.physicsWorldSpeed = 1.0
            delegate?.lastUpdateTime = 0
            joystick.isUserInteractionEnabled = true
        }
    }

    // MARK: - Level Up

    func showLevelUpChoices() {
        guard let levelUpChoiceGenerator = delegate?.getLevelUpChoiceGenerator(),
              let levelUpSystem = delegate?.getLevelUpSystem(),
              let weaponManager = delegate?.getWeaponManager(),
              let passiveItemManager = delegate?.getPassiveItemManager(),
              let player = delegate?.getPlayer(),
              let levelUpUI = delegate?.getLevelUpUI(),
              let scene = delegate?.getScene() else { return }

        isGamePaused = true
        delegate?.physicsWorldSpeed = 0

        let choices = levelUpChoiceGenerator.generateChoices(
            currentLevel: levelUpSystem.currentLevel,
            currentWeapons: weaponManager.getWeapons(),
            currentPassives: passiveItemManager.getPassives(),
            playerStats: player.stats
        )

        levelUpUI.showChoices(choices, in: scene, rerolls: player.stats.reroll)
    }

    func handleLevelUpSelection(_ choice: LevelUpChoice) {
        guard let weaponManager = delegate?.getWeaponManager(),
              let passiveItemManager = delegate?.getPassiveItemManager(),
              let player = delegate?.getPlayer(),
              let levelUpUI = delegate?.getLevelUpUI() else { return }

        switch choice {
        case .newWeapon(let weapon):
            weaponManager.addWeapon(weapon)
            player.addChild(weapon)
        case .weaponUpgrade(let weapon):
            weapon.upgrade()
        case .newPassive(let item):
            passiveItemManager.addPassive(item)
            item.applyEffect(to: &player.stats)
            weaponManager.updatePlayerStats(player.stats)
        case .passiveUpgrade(let item):
            item.upgrade()
            item.applyEffect(to: &player.stats)
            weaponManager.updatePlayerStats(player.stats)
        case .healthRestore:
            player.heal(30)
        case .gold:
            gold += 50
        }

        // Resume game
        levelUpUI.hide()
        isGamePaused = false
        delegate?.physicsWorldSpeed = 1.0
        delegate?.lastUpdateTime = 0
    }

    func handleLevelUpReroll() {
        guard let levelUpChoiceGenerator = delegate?.getLevelUpChoiceGenerator(),
              let levelUpSystem = delegate?.getLevelUpSystem(),
              let weaponManager = delegate?.getWeaponManager(),
              let passiveItemManager = delegate?.getPassiveItemManager(),
              let player = delegate?.getPlayer(),
              let levelUpUI = delegate?.getLevelUpUI(),
              let scene = delegate?.getScene() else { return }

        // Check if player has rerolls available
        guard player.stats.reroll > 0 else { return }

        // Consume one reroll
        player.stats.reroll -= 1

        // Generate new choices
        let choices = levelUpChoiceGenerator.generateChoices(
            currentLevel: levelUpSystem.currentLevel,
            currentWeapons: weaponManager.getWeapons(),
            currentPassives: passiveItemManager.getPassives(),
            playerStats: player.stats
        )

        // Play reroll sound
        SoundManager.shared.playSFX(filename: "sfx_level_up.wav", scene: scene)

        // Show new choices with updated reroll count
        levelUpUI.showChoices(choices, in: scene, rerolls: player.stats.reroll)
    }

    // MARK: - Game Over

    func triggerGameOver() {
        guard let levelUpSystem = delegate?.getLevelUpSystem() else { return }

        // Format time string
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)

        // Save Data
        PersistenceManager.shared.addGold(gold)
        PersistenceManager.shared.updateProgression(runKills: killCount, runTime: gameTime)

        let finalLevel = levelUpSystem.currentLevel
        SceneManager.shared.presentGameOver(finalLevel: finalLevel, kills: killCount, timeSurvived: timeString)
    }
}
