//
//  GameScene.swift
//  DesertSurvivors
//
//  Main game scene that coordinates gameplay systems.
//  Delegates input handling to GameInputHandler and state management to GameStateController.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // MARK: - Core Game Objects

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

    // MARK: - Controllers

    private var inputHandler: GameInputHandler?
    private var stateController: GameStateController?

    // MARK: - Internal State

    var lastUpdateTime: TimeInterval = 0

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

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupSystems()
        setupHUD()
        setupJoystick()
        setupLevelUpUI()
        setupControllers()
        setupNotifications()

        // Initial HUD positioning
        hud?.positionHUD(in: self)

        // Start Music
        SoundManager.shared.playBackgroundMusic(filename: "bgm_desert.mp3")
    }

    // MARK: - Setup

    private func setupScene() {
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
            self?.stateController?.handleLevelUpSelection(choice)
        }

        newLevelUpUI.onRerollRequested = { [weak self] in
            self?.stateController?.handleLevelUpReroll()
        }
    }

    private func setupControllers() {
        // Input Handler
        let newInputHandler = GameInputHandler(joystick: joystick, levelUpUI: levelUpUI, camera: gameCamera)
        newInputHandler.delegate = self
        inputHandler = newInputHandler

        // State Controller
        let newStateController = GameStateController()
        newStateController.delegate = self
        stateController = newStateController
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

    // MARK: - Notification Handlers

    @objc private func deviceRotated() {
        hud?.positionHUD(in: self)
        debugLabel?.position = CGPoint(x: -size.width/2 + 10, y: -size.height/2 + 60)
    }

    @objc private func handleLevelUpNotification(_ notification: Notification) {
        if let level = notification.userInfo?["level"] as? Int {
            hud?.updateLevel(level)
            stateController?.showLevelUpChoices()
        }
    }

    @objc private func handleEnemyDeath(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let position = userInfo["position"] as? CGPoint,
              let xp = userInfo["xp"] as? Float else { return }

        pickupManager?.spawnExperienceGem(at: position, xpValue: xp)
        stateController?.addKill()
        hud?.updateKillCount(stateController?.killCount ?? 0)
    }

    @objc private func handleExperienceCollection(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let xp = userInfo["xp"] as? Float,
              let player = player else { return }

        levelUpSystem?.addXP(xp, multiplier: player.stats.experienceMultiplier)
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard let stateController = stateController else { return }
        if stateController.isGamePaused { return }

        // Guard all critical game objects
        guard let player = player,
              let weaponManager = weaponManager,
              let enemySpawner = enemySpawner,
              let pickupManager = pickupManager,
              let collisionManager = collisionManager,
              let levelUpSystem = levelUpSystem,
              let worldManager = worldManager,
              let joystick = joystick,
              let gameCamera = gameCamera else { return }

        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if deltaTime > 0.1 { deltaTime = 0.1 }

        stateController.addTime(deltaTime)

        // Logic
        player.update(deltaTime: deltaTime)
        player.setMovementDirection(joystick.direction)

        gameCamera.position = player.position
        worldManager.update(playerPos: player.position)

        // Update spatial hash grid for this frame
        let activeEnemies = enemySpawner.getActiveEnemies()
        collisionManager.update(nodes: activeEnemies)

        // System updates
        weaponManager.update(deltaTime: deltaTime, playerPosition: player.position, spatialHash: collisionManager.spatialHash)
        enemySpawner.update(deltaTime: deltaTime)
        pickupManager.update(deltaTime: deltaTime)

        // Collisions
        collisionManager.checkCollisions(player: player, activeEnemies: activeEnemies, pickups: [])

        // HUD - Optimized: only update when values change significantly
        updateHUDOptimized(deltaTime: deltaTime, player: player, levelUpSystem: levelUpSystem)

        if !player.stats.isAlive {
            stateController.triggerGameOver()
        }

        // Debug overlay (runtime toggleable via Settings > Developer Mode)
        updateDebugOverlay(deltaTime: deltaTime, activeEnemies: activeEnemies)
    }

    // MARK: - HUD Optimization

    private func updateHUDOptimized(deltaTime: TimeInterval, player: Player, levelUpSystem: LevelUpSystem) {
        guard let hud = hud, let stateController = stateController else { return }

        // Update timer only once per second (not every frame)
        hudTimerAccumulator += deltaTime
        if hudTimerAccumulator >= 1.0 {
            let currentTimerSeconds = Int(stateController.gameTime)
            if currentTimerSeconds != cachedTimerSeconds {
                hud.updateTimer(stateController.gameTime)
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
        if stateController.killCount != cachedKillCount {
            hud.updateKillCount(stateController.killCount)
            cachedKillCount = stateController.killCount
        }

        // Update gold only when it changes
        if stateController.gold != cachedGold {
            hud.updateGold(stateController.gold)
            cachedGold = stateController.gold
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

    // MARK: - Input Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler?.handleTouchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler?.handleTouchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler?.handleTouchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputHandler?.handleTouchesCancelled(touches, with: event)
    }

    // MARK: - Public Accessors

    func getCollisionManager() -> CollisionManager? {
        return collisionManager
    }

    // MARK: - Cleanup

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // Collision handling done via CollisionManager.checkCollisions()
    }
}

// MARK: - GameInputHandlerDelegate

extension GameScene: GameInputHandlerDelegate {
    func inputHandlerDidRequestPause() {
        stateController?.togglePause()
        inputHandler?.setGamePaused(stateController?.isGamePaused ?? false)
    }

    func inputHandlerDidSelectLevelUpChoice(at location: CGPoint) -> Bool {
        // This is handled via levelUpUI callbacks, not needed here
        return false
    }
}

// MARK: - GameStateControllerDelegate

extension GameScene: GameStateControllerDelegate {
    var physicsWorldSpeed: CGFloat {
        get { physicsWorld.speed }
        set { physicsWorld.speed = newValue }
    }

    func getPlayer() -> Player? { player }
    func getWeaponManager() -> WeaponManager? { weaponManager }
    func getPassiveItemManager() -> PassiveItemManager? { passiveItemManager }
    func getLevelUpChoiceGenerator() -> LevelUpChoiceGenerator? { levelUpChoiceGenerator }
    func getLevelUpSystem() -> LevelUpSystem? { levelUpSystem }
    func getLevelUpUI() -> LevelUpUI? { levelUpUI }
    func getJoystick() -> VirtualJoystick? { joystick }
    func getCamera() -> SKCameraNode? { gameCamera }
    func getScene() -> SKScene? { self }
}
