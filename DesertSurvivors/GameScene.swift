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
            item.applyEffect(to: &player.stats)
            
        case .passiveUpgrade(let item):
            passiveItemManager.upgradePassive(item)
            // Reapply all passive effects
            var baseStats = PlayerStats()
            passiveItemManager.applyAllEffects(to: &baseStats)
            // Merge with current stats (simplified - in real game would be more complex)
            player.stats.damageMultiplier = baseStats.damageMultiplier
            player.stats.cooldownReduction = baseStats.cooldownReduction
            // ... apply other stat changes
            
        case .gold(let amount):
            gold += amount
            
        case .healthRestore(let amount):
            player.heal(amount)
        }
        
        isGamePaused = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let gameCamera = gameCamera else { return }
        let location = touch.location(in: self)
        let cameraLocation = touch.location(in: gameCamera)
        
        // Check if level up UI is visible and handle touch
        if levelUpUI.isVisible {
            if levelUpUI.handleTouch(at: cameraLocation) {
                return // Touch was handled by level up UI
            }
        }
        
        // Check if touch is on left side (joystick area)
        if location.x < size.width / 3 && !isGamePaused {
            joystick.activate(at: cameraLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let gameCamera = gameCamera else { return }
        let cameraLocation = touch.location(in: gameCamera)
        joystick.updateStickPosition(cameraLocation)
        
        // Update player movement
        player?.setMovementDirection(joystick.direction)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.deactivate()
        player?.setMovementDirection(.zero)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.deactivate()
        player?.setMovementDirection(.zero)
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
                // Spawn experience gem before removing
                pickupManager.spawnExperienceGem(at: enemy.position)
                killCount += 1
                hud.updateKillCount(killCount)
                enemy.removeFromParent()
            }
        }
    }
    
    private func gameOver() {
        isGamePaused = true
        // TODO: Show game over scene
        print("Game Over! Survived for \(Int(gameTime)) seconds. Kills: \(killCount)")
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Handle collisions if needed
    }
}
