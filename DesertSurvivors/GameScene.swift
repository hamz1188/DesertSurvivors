//
//  GameScene.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Core game objects
    private var player: Player!
    private var weaponManager: WeaponManager!
    private var enemySpawner: EnemySpawner!
    private var pickupManager: PickupManager!
    private var collisionManager: CollisionManager!
    private var levelUpSystem: LevelUpSystem!
    private var passiveItemManager: PassiveItemManager!
    private var levelUpChoiceGenerator: LevelUpChoiceGenerator!
    private var hud: HUD!
    private var joystick: VirtualJoystick!
    private var levelUpUI: LevelUpUI!
    
    // Game state
    private var lastUpdateTime: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private var killCount: Int = 0
    private var isGamePaused: Bool = false
    private var gold: Int = 0
    
    // Camera (non-optional after setup)
    private var gameCamera: SKCameraNode!
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupSystems()
        setupHUD()
        setupJoystick()
        setupLevelUpUI()
        setupNotifications()
    }
    
    private func setupScene() {
        backgroundColor = Constants.Colors.desertSand
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Set camera to follow player (will be set up after player is created)
        gameCamera = SKCameraNode()
        camera = gameCamera
        addChild(gameCamera)
    }
    
    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
    }
    
    private func setupSystems() {
        weaponManager = WeaponManager(scene: self)
        weaponManager.updatePlayerStats(player.stats)
        
        enemySpawner = EnemySpawner(scene: self, player: player)
        pickupManager = PickupManager(scene: self, player: player)
        collisionManager = CollisionManager()
        levelUpSystem = LevelUpSystem()
        passiveItemManager = PassiveItemManager()
        levelUpChoiceGenerator = LevelUpChoiceGenerator()
        
        // Give player starting weapon (after weaponManager is initialized)
        let startingWeapon = CurvedDagger()
        player.addChild(startingWeapon) // Add weapon as child of player so it follows
        weaponManager.addWeapon(startingWeapon)
    }
    
    private func setupHUD() {
        hud = HUD()
        gameCamera.addChild(hud)
        hud.positionHUD(in: self)
    }
    
    private func setupJoystick() {
        joystick = VirtualJoystick()
        gameCamera.addChild(joystick)
        joystick.position = CGPoint(x: -size.width/2 + 80, y: -size.height/2 + 80)
    }
    
    private func setupLevelUpUI() {
        levelUpUI = LevelUpUI()
        gameCamera.addChild(levelUpUI)
        levelUpUI.position = CGPoint(x: 0, y: 0)
        
        levelUpUI.onChoiceSelected = { [weak self] choice in
            self?.handleLevelUpChoice(choice)
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExperienceCollected),
            name: .experienceCollected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLevelUp),
            name: .playerLevelUp,
            object: nil
        )
    }
    
    @objc private func handleExperienceCollected(_ notification: Notification) {
        if let xp = notification.userInfo?["xp"] as? Float {
            levelUpSystem.addXP(xp, multiplier: player.stats.experienceMultiplier)
        }
    }
    
    @objc private func handleLevelUp(_ notification: Notification) {
        if let level = notification.userInfo?["level"] as? Int {
            hud.updateLevel(level)
            showLevelUpChoices()
        }
    }
    
    private func showLevelUpChoices() {
        isGamePaused = true
        
        let choices = levelUpChoiceGenerator.generateChoices(
            currentLevel: levelUpSystem.currentLevel,
            currentWeapons: weaponManager.getWeapons(),
            currentPassives: passiveItemManager.getPassives(),
            playerStats: player.stats
        )
        
        levelUpUI.showChoices(choices, in: self)
    }
    
    private func handleLevelUpChoice(_ choice: LevelUpChoice) {
        switch choice {
        case .newWeapon(let weapon):
            player.addChild(weapon)
            weaponManager.addWeapon(weapon)
            
        case .weaponUpgrade(let weapon):
            weapon.upgrade()
            
        case .newPassive(let item):
            passiveItemManager.addPassive(item)
            applyAllPassiveEffects()
            
        case .passiveUpgrade(let item):
            passiveItemManager.upgradePassive(item)
            applyAllPassiveEffects()
            
        case .gold(let amount):
            gold += Int(Float(amount) * player.stats.goldMultiplier)
            hud.updateGold(gold)
            
        case .healthRestore(let amount):
            player.heal(amount)
        }
        
        // Update weapon manager with new stats
        weaponManager.updatePlayerStats(player.stats)
        
        isGamePaused = false
    }
    
    /// Recalculates and applies all passive effects to player stats
    private func applyAllPassiveEffects() {
        // Save current health percentage to restore after stat changes
        let healthPercent = player.stats.healthPercentage
        let currentHP = player.stats.currentHealth
        
        // Reset stats that are affected by passives to base values
        var newStats = PlayerStats()
        
        // Apply all passive effects
        passiveItemManager.applyAllEffects(to: &newStats)
        
        // Update player stats
        player.stats.damageMultiplier = newStats.damageMultiplier
        player.stats.cooldownReduction = min(newStats.cooldownReduction, 0.9) // Cap at 90%
        player.stats.projectileSpeed = newStats.projectileSpeed
        player.stats.areaMultiplier = newStats.areaMultiplier
        player.stats.duration = newStats.duration
        player.stats.armor = newStats.armor
        player.stats.moveSpeed = 200 + (newStats.moveSpeed - 200) // Base + bonus
        player.stats.pickupRadius = 50 + (newStats.pickupRadius - 50) // Base + bonus
        player.stats.luck = newStats.luck
        player.stats.experienceMultiplier = newStats.experienceMultiplier
        player.stats.goldMultiplier = newStats.goldMultiplier
        player.stats.dodgeChance = min(newStats.dodgeChance, 0.75) // Cap at 75%
        player.stats.burnChance = newStats.burnChance
        player.stats.lifesteal = newStats.lifesteal
        player.stats.poisonChance = newStats.poisonChance
        player.stats.critChance = min(newStats.critChance, 1.0) // Cap at 100%
        player.stats.attackSpeedMultiplier = newStats.attackSpeedMultiplier
        player.stats.damageReduction = min(newStats.damageReduction, 0.75) // Cap at 75%
        player.stats.healthRegenPerSecond = newStats.healthRegenPerSecond
        
        // Handle max health changes - keep current HP but allow max to increase
        let oldMaxHealth = player.stats.maxHealth
        player.stats.maxHealth = newStats.maxHealth
        
        // If max health increased, also increase current health by the same amount
        if newStats.maxHealth > oldMaxHealth {
            player.stats.currentHealth = min(currentHP + (newStats.maxHealth - oldMaxHealth), newStats.maxHealth)
        } else {
            player.stats.currentHealth = min(currentHP, newStats.maxHealth)
        }
        
        // Update player's health regeneration
        player.healthRegenPerSecond = player.stats.healthRegenPerSecond
    }
    
    // Touch handling
    private var joystickTouch: UITouch?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameCamera = gameCamera else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let cameraLocation = touch.location(in: gameCamera)
            
            // Check if level up UI is visible and handle touch
            if levelUpUI.isVisible {
                if levelUpUI.handleTouch(at: cameraLocation) {
                    return
                }
            }
            
            // Check if touch is on left side (joystick area) and we don't already have a joystick touch
            if joystickTouch == nil && location.x < size.width / 3 && !isGamePaused {
                joystickTouch = touch
                joystick.activate(at: cameraLocation)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let gameCamera = gameCamera else { return }
        
        for touch in touches {
            if touch == joystickTouch {
                let cameraLocation = touch.location(in: gameCamera)
                joystick.updateStickPosition(cameraLocation)
                player?.setMovementDirection(joystick.direction)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystickTouch = nil
                joystick.deactivate()
                player?.setMovementDirection(.zero)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch == joystickTouch {
                joystickTouch = nil
                joystick.deactivate()
                player?.setMovementDirection(.zero)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize lastUpdateTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        guard !isGamePaused else { return }
        guard let player = player, let weaponManager = weaponManager, 
              let enemySpawner = enemySpawner, let pickupManager = pickupManager,
              let collisionManager = collisionManager, let levelUpSystem = levelUpSystem,
              let hud = hud, let gameCamera = gameCamera else { return }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update game time
        gameTime += deltaTime
        hud.updateTimer(gameTime)
        
        // Update player
        player.update(deltaTime: deltaTime)
        
        // Update camera to follow player
        gameCamera.position = player.position
        
        // Update enemies
        enemySpawner.update(deltaTime: deltaTime)
        let enemies = enemySpawner.getActiveEnemies()
        
        // Update weapons
        weaponManager.update(deltaTime: deltaTime, playerPosition: player.position, enemies: enemies)
        
        // Update pickups
        pickupManager.update(deltaTime: deltaTime)
        
        // Check collisions
        collisionManager.checkCollisions(player: player, enemies: enemies, pickups: [])
        
        // Update HUD
        hud.updateHealth(player.stats.healthPercentage)
        hud.updateXP(levelUpSystem.xpProgress)
        
        // Check for enemy deaths and spawn experience gems
        checkEnemyDeaths(enemies)
        
        // Check game over
        if !player.stats.isAlive {
            gameOver()
        }
    }
    
    private func checkEnemyDeaths(_ enemies: [BaseEnemy]) {
        for enemy in enemies {
            if enemy.currentHealth <= 0 && enemy.parent != nil {
                // Spawn experience gem before removing (using enemy's XP value)
                pickupManager.spawnExperienceGem(at: enemy.position, xpValue: enemy.xpValue)
                killCount += 1
                hud.updateKillCount(killCount)
                enemy.removeFromParent()
            }
        }
    }
    
    private func gameOver() {
        isGamePaused = true
        
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        SceneManager.shared.presentGameOver(
            finalLevel: levelUpSystem.currentLevel,
            kills: killCount,
            timeSurvived: timeString
        )
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions if needed
    }
}
