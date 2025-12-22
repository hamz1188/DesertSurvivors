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

    /// Delegate for enemy events (set on all spawned enemies)
    weak var enemyEventDelegate: EnemyEventDelegate?

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
        
        // Update all enemies and return dead ones to the pool
        activeEnemies.removeAll { enemy in
            // If enemy is dead, return to pool
            if !enemy.isAlive {
                if let poolType = enemy.poolType {
                    PoolingManager.shared.despawnEnemy(enemy, enemyType: poolType)
                } else {
                    enemy.removeFromParent()
                }
                return true
            }
            // If enemy was removed from parent unexpectedly, clean up
            if enemy.parent == nil {
                return true
            }
            // Update alive enemies
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
        
        // Determine allowable tiers based on time
        // Tier 1: 0+ seconds
        // Tier 2: After tier2UnlockTime seconds

        var allowedTiers: [Int] = [1]
        if gameTime >= Constants.tier2UnlockTime {
            allowedTiers.append(2)
        }
        
        let selectedTier = allowedTiers.randomElement() ?? 1
        
        let enemy: BaseEnemy
        if selectedTier == 2 {
            enemy = createTier2Enemy()
        } else {
            enemy = createTier1Enemy()
        }

        // Set delegate for enemy events
        enemy.eventDelegate = enemyEventDelegate

        enemy.position = CGPoint(x: spawnX, y: spawnY)
        scene.addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    private func createTier1Enemy() -> BaseEnemy {
        // Randomly select a Tier 1 enemy type
        let types = ["SandScarab", "DesertRat", "Scorpion", "DustSprite"]
        let type = types.randomElement() ?? "SandScarab"

        // Use object pooling for better performance
        return PoolingManager.shared.spawnEnemy(enemyType: type) {
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
    }

    private func createTier2Enemy() -> BaseEnemy {
        let types = ["MummifiedWanderer", "SandCobra", "DesertBandit", "CursedJackal"]
        let type = types.randomElement() ?? "MummifiedWanderer"

        // Use object pooling for better performance
        return PoolingManager.shared.spawnEnemy(enemyType: type) {
            switch type {
            case "MummifiedWanderer":
                return MummifiedWanderer()
            case "SandCobra":
                return SandCobra()
            case "DesertBandit":
                return DesertBandit()
            case "CursedJackal":
                return CursedJackal()
            default:
                return MummifiedWanderer()
            }
        }
    }
    
    func getActiveEnemies() -> [BaseEnemy] {
        return activeEnemies
    }
    
    func clearAll() {
        for enemy in activeEnemies {
            if let poolType = enemy.poolType {
                PoolingManager.shared.despawnEnemy(enemy, enemyType: poolType)
            } else {
                enemy.removeFromParent()
            }
        }
        activeEnemies.removeAll()
        PoolingManager.shared.clearEnemies()
    }
}

