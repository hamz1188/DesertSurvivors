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
    private var hud: HUD!
    private var joystick: VirtualJoystick!
    
    // Game state
    private var lastUpdateTime: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private var killCount: Int = 0
    private var isGamePaused: Bool = false
    
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupSystems()
        setupHUD()
        setupJoystick()
        setupNotifications()
    }
    
    private func setupScene() {
        backgroundColor = Constants.Colors.desertSand
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Set camera to follow player (will be set up after player is created)
        camera = SKCameraNode()
        addChild(camera!)
    }
    
    private func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: 0, y: 0)
        addChild(player)
        
        // Give player starting weapon
        let startingWeapon = CurvedDagger()
        player.addChild(startingWeapon) // Add weapon as child of player so it follows
        weaponManager.addWeapon(startingWeapon)
    }
    
    private func setupSystems() {
        weaponManager = WeaponManager(scene: self)
        weaponManager.updatePlayerStats(player.stats)
        
        enemySpawner = EnemySpawner(scene: self, player: player)
        pickupManager = PickupManager(scene: self, player: player)
        collisionManager = CollisionManager()
        levelUpSystem = LevelUpSystem()
    }
    
    private func setupHUD() {
        hud = HUD()
        camera?.addChild(hud)
        hud.positionHUD(in: self)
    }
    
    private func setupJoystick() {
        joystick = VirtualJoystick()
        camera?.addChild(joystick)
        joystick.position = CGPoint(x: -size.width/2 + 80, y: -size.height/2 + 80)
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
            // TODO: Show level up UI with choices
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is on left side (joystick area)
        if location.x < size.width / 3 {
            let cameraLocation = touch.location(in: camera!)
            joystick.activate(at: cameraLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let cameraLocation = touch.location(in: camera!)
        joystick.updateStickPosition(cameraLocation)
        
        // Update player movement
        player.setMovementDirection(joystick.direction)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.deactivate()
        player.setMovementDirection(.zero)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.deactivate()
        player.setMovementDirection(.zero)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Initialize lastUpdateTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        guard !isGamePaused else { return }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Update game time
        gameTime += deltaTime
        hud.updateTimer(gameTime)
        
        // Update player
        player.update(deltaTime: deltaTime)
        
        // Update camera to follow player
        camera?.position = player.position
        
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
