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
    var player: Player?
    private var weaponManager: WeaponManager?
    private var enemySpawner: EnemySpawner?
    private var pickupManager: PickupManager?
    private var collisionManager: CollisionManager?
    private var levelUpSystem: LevelUpSystem?
    private var passiveItemManager: PassiveItemManager?
    private var levelUpChoiceGenerator: LevelUpChoiceGenerator?
    private var hud: HUD?
    private var joystick: VirtualJoystick?
    private var levelUpUI: LevelUpUI?
    private var worldManager: WorldManager?
    
    var selectedCharacter: CharacterType = .tariq
    
    // Game state
    private var lastUpdateTime: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private var killCount: Int = 0
    private var isGamePaused: Bool = false
    private var gold: Int = 0

    // HUD optimization - cached values to reduce update frequency
    private var cachedHealthPercent: Float = 1.0
    private var cachedXPPercent: Float = 0.0
    private var cachedKillCount: Int = 0
    private var cachedGold: Int = 0
    private var cachedTimerSeconds: Int = 0
    private var hudTimerAccumulator: TimeInterval = 0
    
    // Camera
    private var gameCamera: SKCameraNode?
    
    // Performance Monitoring (runtime toggleable via Settings)
    private var frameCounter = 0
    private var fpsTimer: TimeInterval = 0
    private var debugLabel: SKLabelNode?
    private var lastDebugUpdateTime: TimeInterval = 0
    
    // Touch handling
    private var joystickTouch: UITouch?
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupSystems()
        setupHUD()
        setupJoystick()
        setupLevelUpUI()
        setupNotifications()

        // Initial HUD positioning
        hud?.positionHUD(in: self)

        // Start Music
        SoundManager.shared.playBackgroundMusic(filename: "bgm_desert.mp3")
    }
    
    private func setupScene() {
        // backgroundColor = Constants.Colors.desertSand // Replaced by generated map

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Ensure clean state
        removeAllChildren()

        // Generate Map
        MapGenerator.shared.generateMap(in: self)

        let newCamera = SKCameraNode()
        gameCamera = newCamera
        camera = newCamera
        addChild(newCamera)
    }
    
    private func setupPlayer() {
        let newPlayer = Player(character: selectedCharacter)
        newPlayer.position = .zero
        player = newPlayer
        addChild(newPlayer)
    }
    
    private func setupSystems() {
        guard let player = player else { return }

        let newWeaponManager = WeaponManager(scene: self)
        newWeaponManager.updatePlayerStats(player.stats)
        weaponManager = newWeaponManager

        enemySpawner = EnemySpawner(scene: self, player: player)
        pickupManager = PickupManager(scene: self, player: player)
        collisionManager = CollisionManager()
        levelUpSystem = LevelUpSystem()
        passiveItemManager = PassiveItemManager()
        levelUpChoiceGenerator = LevelUpChoiceGenerator()
        worldManager = WorldManager(scene: self, player: player)

        let startingWeapon = CurvedDagger()
        player.addChild(startingWeapon)
        newWeaponManager.addWeapon(startingWeapon)
    }
    
    private func setupHUD() {
        guard let gameCamera = gameCamera else { return }

        let newHUD = HUD()
        hud = newHUD
        gameCamera.addChild(newHUD)

        // Debug label (always created, visibility controlled by DebugSettings)
        let newDebugLabel = SKLabelNode(fontNamed: "Courier-Bold")
        newDebugLabel.fontSize = 12
        newDebugLabel.fontColor = .green
        newDebugLabel.zPosition = 1000
        newDebugLabel.horizontalAlignmentMode = .left
        newDebugLabel.verticalAlignmentMode = .bottom
        newDebugLabel.numberOfLines = 3
        newDebugLabel.isHidden = !DebugSettings.shared.isDeveloperModeEnabled
        newDebugLabel.position = CGPoint(x: -size.width/2 + 10, y: -size.height/2 + 60)
        debugLabel = newDebugLabel
        gameCamera.addChild(newDebugLabel)
    }
    
    private func setupJoystick() {
        guard let gameCamera = gameCamera else { return }

        let newJoystick = VirtualJoystick()
        newJoystick.zPosition = Constants.ZPosition.hud
        joystick = newJoystick
        gameCamera.addChild(newJoystick)
    }
    
    private func setupLevelUpUI() {
        guard let gameCamera = gameCamera else { return }

        let newLevelUpUI = LevelUpUI()
        newLevelUpUI.position = .zero
        levelUpUI = newLevelUpUI
        gameCamera.addChild(newLevelUpUI)

        newLevelUpUI.onChoiceSelected = { [weak self] choice in
            self?.handleLevelUpSelection(choice)
        }
    }
    
    private func setupNotifications() {
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleLevelUpNotification),
             name: .playerLevelUp,
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleEnemyDeath),
             name: .enemyDied,
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(deviceRotated),
             name: UIDevice.orientationDidChangeNotification,
             object: nil
         )
         
         NotificationCenter.default.addObserver(
             self,
             selector: #selector(handleExperienceCollection),
             name: .experienceCollected,
             object: nil
         )
    }
    
    @objc private func deviceRotated() {
        hud?.positionHUD(in: self)

        // Position debug label in bottom-left corner
        debugLabel?.position = CGPoint(x: -size.width/2 + 10, y: -size.height/2 + 60)
    }
    
    @objc private func handleLevelUpNotification(_ notification: Notification) {
        if let level = notification.userInfo?["level"] as? Int {
            hud?.updateLevel(level)
            levelUp()
        }
    }
    
    @objc private func handleEnemyDeath(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let position = userInfo["position"] as? CGPoint,
              let xp = userInfo["xp"] as? Float else { return }

        pickupManager?.spawnExperienceGem(at: position, xpValue: xp)
        addKill()
        hud?.updateKillCount(killCount)
    }

    @objc private func handleExperienceCollection(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let xp = userInfo["xp"] as? Float,
              let player = player else { return }

        levelUpSystem?.addXP(xp, multiplier: player.stats.experienceMultiplier)
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        if isGamePaused { return }

        // Guard all critical game objects
        guard let player = player,
              let weaponManager = weaponManager,
              let enemySpawner = enemySpawner,
              let pickupManager = pickupManager,
              let collisionManager = collisionManager,
              let levelUpSystem = levelUpSystem,
              let worldManager = worldManager,
              let hud = hud,
              let joystick = joystick,
              let gameCamera = gameCamera else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if deltaTime > 0.1 { deltaTime = 0.1 }

        gameTime += deltaTime

        // Logic
        player.update(deltaTime: deltaTime)
        player.setMovementDirection(joystick.direction) // Fixed: direction instead of velocity

        gameCamera.position = player.position
        worldManager.update(playerPos: player.position)

        // Update spatial hash grid for this frame
        let activeEnemies = enemySpawner.getActiveEnemies()
        collisionManager.update(nodes: activeEnemies)

        // System updates
        weaponManager.update(deltaTime: deltaTime, playerPosition: player.position, spatialHash: collisionManager.spatialHash)
        enemySpawner.update(deltaTime: deltaTime)
        // LevelUpSystem and Generator do not have update() methods

        pickupManager.update(deltaTime: deltaTime)

        // Collisions
        // Pickups handling is done in pickupManager.update()
        collisionManager.checkCollisions(player: player, activeEnemies: activeEnemies, pickups: [])

        // HUD - Optimized: only update when values change significantly
        updateHUDOptimized(deltaTime: deltaTime, player: player, levelUpSystem: levelUpSystem)

        // hud.positionHUD removed from here - now handled by rotation notification

        if !player.stats.isAlive {
            gameOver()
        }
        
        // Debug overlay (runtime toggleable via Settings > Developer Mode)
        updateDebugOverlay(deltaTime: deltaTime, activeEnemies: activeEnemies)
    }

    // MARK: - HUD Optimization
    private func updateHUDOptimized(deltaTime: TimeInterval, player: Player, levelUpSystem: LevelUpSystem) {
        guard let hud = hud else { return }

        // Update timer only once per second (not every frame)
        hudTimerAccumulator += deltaTime
        if hudTimerAccumulator >= 1.0 {
            let currentTimerSeconds = Int(gameTime)
            if currentTimerSeconds != cachedTimerSeconds {
                hud.updateTimer(gameTime)
                cachedTimerSeconds = currentTimerSeconds
            }
            hudTimerAccumulator = 0
        }

        // Update health only if changed by >1%
        let currentHealthPercent = player.stats.currentHealth / player.stats.maxHealth
        if abs(currentHealthPercent - cachedHealthPercent) > 0.01 {
            hud.updateHealth(currentHealthPercent)
            cachedHealthPercent = currentHealthPercent
        }

        // Update XP only if changed by >1%
        let currentXPPercent = levelUpSystem.currentXP / levelUpSystem.xpForNextLevel
        if abs(currentXPPercent - cachedXPPercent) > 0.01 {
            hud.updateXP(currentXPPercent)
            cachedXPPercent = currentXPPercent
        }

        // Update kill count only when it changes
        if killCount != cachedKillCount {
            hud.updateKillCount(killCount)
            cachedKillCount = killCount
        }

        // Update gold only when it changes
        if gold != cachedGold {
            hud.updateGold(gold)
            cachedGold = gold
        }
    }

    private func updateDebugOverlay(deltaTime: TimeInterval, activeEnemies: [BaseEnemy]) {
        // Check if developer mode is enabled (can change at runtime)
        let shouldShow = DebugSettings.shared.isDeveloperModeEnabled
        debugLabel?.isHidden = !shouldShow

        guard shouldShow else { return }

        frameCounter += 1
        fpsTimer += deltaTime

        // Update every second to avoid excessive string allocations
        if fpsTimer >= 1.0 {
            let fps = frameCounter
            let enemyCount = activeEnemies.count
            let weaponCount = weaponManager?.getWeapons().count ?? 0

            debugLabel?.text = "FPS: \(fps)\nEnemies: \(enemyCount)\nWeapons: \(weaponCount)"

            frameCounter = 0
            fpsTimer = 0
        }
    }
    
    // MARK: - Generic Logic
    
    func addKill() {
        killCount += 1
    }
    
    func gameOver() {
        // Format time string manually
        let minutes = Int(gameTime) / 60
        let seconds = Int(gameTime) % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)

        // Save Data
        PersistenceManager.shared.addGold(gold)
        PersistenceManager.shared.updateProgression(runKills: killCount, runTime: gameTime)

        let finalLevel = levelUpSystem?.currentLevel ?? 1
        SceneManager.shared.presentGameOver(finalLevel: finalLevel, kills: killCount, timeSurvived: timeString)
    }
    
    // MARK: - Pause & UI Logic
    
    func togglePause() {
        guard let gameCamera = gameCamera,
              let joystick = joystick else { return }

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
            gameCamera.addChild(pauseMenu)

            physicsWorld.speed = 0
            joystick.isUserInteractionEnabled = false
        } else {
            gameCamera.childNode(withName: "pauseMenu")?.removeFromParent()
            physicsWorld.speed = 1.0
            lastUpdateTime = 0
            joystick.isUserInteractionEnabled = true
        }
    }
    
    func levelUp() {
        guard let levelUpChoiceGenerator = levelUpChoiceGenerator,
              let levelUpSystem = levelUpSystem,
              let weaponManager = weaponManager,
              let passiveItemManager = passiveItemManager,
              let player = player,
              let levelUpUI = levelUpUI else { return }

        isGamePaused = true
        physicsWorld.speed = 0

        let choices = levelUpChoiceGenerator.generateChoices(
            currentLevel: levelUpSystem.currentLevel, // Fixed: Added currentLevel
            currentWeapons: weaponManager.getWeapons(), // Fixed: getWeapons()
            currentPassives: passiveItemManager.getPassives(), // Fixed: getPassives()
            playerStats: player.stats
        )

        levelUpUI.showChoices(choices, in: self) // Fixed: showChoices
    }
    
    func handleLevelUpSelection(_ choice: LevelUpChoice) {
        guard let weaponManager = weaponManager,
              let passiveItemManager = passiveItemManager,
              let player = player,
              let levelUpUI = levelUpUI else { return }

        switch choice {
        case .newWeapon(let weapon):
            weaponManager.addWeapon(weapon)
            player.addChild(weapon)
        case .weaponUpgrade(let weapon): // Fixed: weaponUpgrade
            weapon.upgrade()
        case .newPassive(let item):
            passiveItemManager.addPassive(item) // Fixed: addPassive
            item.applyEffect(to: &player.stats)
            weaponManager.updatePlayerStats(player.stats)
        case .passiveUpgrade(let item): // Fixed: passiveUpgrade
            item.upgrade()
            item.applyEffect(to: &player.stats)
            weaponManager.updatePlayerStats(player.stats)
        case .healthRestore: // Fixed: healthRestore
            player.heal(30)
        case .gold:
            gold += 50
        }

        // Resume
        levelUpUI.hide()
        isGamePaused = false
        physicsWorld.speed = 1.0
        lastUpdateTime = 0
    }
    
    // MARK: - Input
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let gameCamera = gameCamera,
               let levelUpUI = levelUpUI,
               let joystick = joystick else { return }

         for touch in touches {
             let location = touch.location(in: gameCamera)

             if levelUpUI.isVisible {
                 if levelUpUI.handleTouch(at: location) { return }
             }

             let nodes = gameCamera.nodes(at: location)
             for node in nodes {
                 if node.name == "pauseButton" || node.parent?.name == "pauseButton" {
                     togglePause()
                     return
                 }
             }
         }

        guard !isGamePaused else { return }
        joystick.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused,
              let joystick = joystick else { return }
        joystick.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.touchesCancelled(touches, with: event)
    }
    func getCollisionManager() -> CollisionManager? {
        return collisionManager
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // collisionManager.handleContact(contact, in: self) // removed as handleContact doesnt exist and checkCollisions handles logic
    }
}
