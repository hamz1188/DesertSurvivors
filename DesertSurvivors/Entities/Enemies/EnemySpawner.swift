//
//  EnemySpawner.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class EnemySpawner {
    weak var scene: SKScene?
    weak var player: Player?
    private var activeEnemies: [BaseEnemy] = []
    private var spawnTimer: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private let spawnInterval: TimeInterval = 2.0 // spawn every 2 seconds initially
    
    init(scene: SKScene, player: Player) {
        self.scene = scene
        self.player = player
    }
    
    func update(deltaTime: TimeInterval) {
        gameTime += deltaTime
        spawnTimer += deltaTime
        
        // Calculate spawn rate based on game time
        let enemiesPerMinute = Float(Constants.baseEnemiesPerMinute) * pow(Constants.enemiesPerMinuteGrowth, Float(gameTime / 60.0))
        let currentSpawnInterval = 60.0 / Double(enemiesPerMinute)
        
        if spawnTimer >= currentSpawnInterval {
            spawnEnemy()
            spawnTimer = 0
        }
        
        // Update all enemies
        activeEnemies.removeAll { enemy in
            if !enemy.isAlive {
                enemy.removeFromParent()
                return true
            }
            if let playerPos = player?.position {
                enemy.update(deltaTime: deltaTime, playerPosition: playerPos)
            }
            return false
        }
    }
    
    private func spawnEnemy() {
        guard let scene = scene, let player = player else { return }
        
        // Don't spawn if we're at max capacity
        if activeEnemies.count >= Constants.maxEnemiesOnScreen {
            return
        }
        
        // Spawn at random position outside visible area
        let spawnDistance = Constants.spawnDistanceFromPlayer
        let angle = Double.random(in: 0..<2 * .pi)
        let spawnX = player.position.x + cos(angle) * spawnDistance
        let spawnY = player.position.y + sin(angle) * spawnDistance
        
        // Create a basic enemy (will be replaced with tier-based spawning)
        let enemy = createTier1Enemy()
        enemy.position = CGPoint(x: spawnX, y: spawnY)
        scene.addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    private func createTier1Enemy() -> BaseEnemy {
        // Randomly select a Tier 1 enemy type
        let types = ["SandScarab", "DesertRat", "Scorpion", "DustSprite"]
        let type = types.randomElement() ?? "SandScarab"
        
        switch type {
        case "SandScarab":
            return SandScarab()
        case "DesertRat":
            return DesertRat()
        case "Scorpion":
            return Scorpion()
        case "DustSprite":
            return DustSprite()
        default:
            return SandScarab()
        }
    }
    
    func getActiveEnemies() -> [BaseEnemy] {
        return activeEnemies
    }
    
    func clearAll() {
        for enemy in activeEnemies {
            enemy.removeFromParent()
        }
        activeEnemies.removeAll()
    }
}

