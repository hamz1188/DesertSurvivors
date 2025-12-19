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
    var player: Player!
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
    private var worldManager: WorldManager!
    
    var selectedCharacter: CharacterType = .tariq
    
    // Game state
    private var lastUpdateTime: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private var killCount: Int = 0
    private var isGamePaused: Bool = false
    private var gold: Int = 0
    
    // Camera
    private var gameCamera: SKCameraNode!
    
    // Performance Monitoring
    #if DEBUG
    private var frameCounter = 0
    private var fpsTimer: TimeInterval = 0
    private var fpsLabel: SKLabelNode!
    #endif
    
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
        hud.positionHUD(in: self)
        
        // Start Music
        SoundManager.shared.playBackgroundMusic(filename: "bgm_desert.mp3")
    }
    
    private func setupScene() {
        backgroundColor = Constants.Colors.desertSand
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Ensure clean state
        removeAllChildren()
        
        gameCamera = SKCameraNode()
        camera = gameCamera
        addChild(gameCamera)
    }
    
    private func setupPlayer() {
        player = Player(character: selectedCharacter)
        player.position = .zero
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
        worldManager = WorldManager(scene: self, player: player)
        
        let startingWeapon = CurvedDagger()
        player.addChild(startingWeapon)
        weaponManager.addWeapon(startingWeapon)
    }
    
    private func setupHUD() {
        hud = HUD()
        gameCamera.addChild(hud)
        
        #if DEBUG
        fpsLabel = SKLabelNode(fontNamed: "Arial")
        fpsLabel.fontSize = 14
        fpsLabel.fontColor = .green
        fpsLabel.zPosition = 1000
        gameCamera.addChild(fpsLabel)
        #endif
    }
    
    private func setupJoystick() {
        joystick = VirtualJoystick()
        gameCamera.addChild(joystick)
        joystick.zPosition = Constants.ZPosition.hud
    }
    
    private func setupLevelUpUI() {
        levelUpUI = LevelUpUI()
        gameCamera.addChild(levelUpUI)
        levelUpUI.position = .zero
        
        levelUpUI.onChoiceSelected = { [weak self] choice in
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
        hud.positionHUD(in: self)
        
        #if DEBUG
        if let fpsLabel = fpsLabel {
            fpsLabel.position = CGPoint(x: -size.width/2 + 50, y: size.height/2 - 100)
        }
        #endif
    }
    
    @objc private func handleLevelUpNotification(_ notification: Notification) {
        if let level = notification.userInfo?["level"] as? Int {
            hud.updateLevel(level)
            levelUp()
        }
    }
    
    @objc private func handleEnemyDeath(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let position = userInfo["position"] as? CGPoint,
              let xp = userInfo["xp"] as? Float else { return }
        
        pickupManager.spawnExperienceGem(at: position, xpValue: xp)
        addKill()
        hud.updateKillCount(killCount)
    }
    
    @objc private func handleExperienceCollection(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let xp = userInfo["xp"] as? Float else { return }
        
        levelUpSystem.addXP(xp, multiplier: player.stats.experienceMultiplier)
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        if isGamePaused { return }
        
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

        // Check obstacle collisions and push player out
        let playerRadius: CGFloat = 15
        if let pushOut = worldManager.getObstacleCollision(at: player.position, radius: playerRadius) {
            player.position = player.position + pushOut
        }

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
        
        // HUD
        hud.updateTimer(gameTime)
        hud.updateHealth(player.stats.currentHealth / player.stats.maxHealth)
        hud.updateXP(levelUpSystem.currentXP / levelUpSystem.xpForNextLevel)
        hud.updateKillCount(killCount)
        hud.updateGold(gold)
        
        // hud.positionHUD removed from here - now handled by rotation notification
        
        if !player.stats.isAlive {
            gameOver()
        }
        
        #if DEBUG
        frameCounter += 1
        fpsTimer += deltaTime
        if fpsTimer >= 1.0 {
            fpsLabel.text = "FPS: \(frameCounter)"
            frameCounter = 0
            fpsTimer = 0
        }
        #endif
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
        
        SceneManager.shared.presentGameOver(finalLevel: levelUpSystem.currentLevel, kills: killCount, timeSurvived: timeString)
    }
    
    // MARK: - Pause & UI Logic
    
    func togglePause() {
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
         guard let gameCamera = gameCamera else { return }
         
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
        guard !isGamePaused else { return }
        joystick.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.touchesCancelled(touches, with: event)
    }
    func getCollisionManager() -> CollisionManager {
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
