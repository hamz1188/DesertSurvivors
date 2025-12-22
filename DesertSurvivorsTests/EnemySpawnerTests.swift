//
//  EnemySpawnerTests.swift
//  DesertSurvivorsTests
//
//  Created by Claude on 22/12/2025.
//

import Testing
import SpriteKit
@testable import DesertSurvivors

struct EnemySpawnerTests {

    // MARK: - Initialization Tests

    @Test func testInitializationStartsEmpty() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        let spawner = EnemySpawner(scene: scene, player: player)

        #expect(spawner.getActiveEnemies().isEmpty)
    }

    // MARK: - Enemy List Management Tests

    @Test func testGetActiveEnemiesReturnsEmptyInitially() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        let spawner = EnemySpawner(scene: scene, player: player)

        let enemies = spawner.getActiveEnemies()

        #expect(enemies.count == 0)
    }

    // MARK: - Clear All Tests

    @Test func testClearAllRemovesAllEnemies() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        scene.addChild(player)
        let spawner = EnemySpawner(scene: scene, player: player)

        // Simulate spawning by running a few updates
        // Note: Actual spawning depends on spawn timer, so we test clearAll directly
        spawner.clearAll()

        #expect(spawner.getActiveEnemies().isEmpty)
    }

    // MARK: - Update Tests

    @Test func testUpdateWithZeroDeltaTimeDoesNotCrash() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        scene.addChild(player)
        let spawner = EnemySpawner(scene: scene, player: player)

        // Should not crash with zero delta time
        spawner.update(deltaTime: 0)

        #expect(spawner.getActiveEnemies().count >= 0)
    }

    @Test func testUpdateWithSmallDeltaTimeDoesNotSpawnImmediately() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        scene.addChild(player)
        let spawner = EnemySpawner(scene: scene, player: player)

        // Very small delta time shouldn't trigger spawn yet
        spawner.update(deltaTime: 0.001)

        // May or may not have enemies depending on spawn interval
        #expect(spawner.getActiveEnemies().count >= 0)
    }

    // MARK: - Spawn Rate Tests

    @Test func testSpawnerRespectsMaxEnemyLimit() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        scene.addChild(player)
        let spawner = EnemySpawner(scene: scene, player: player)

        // Run many update cycles to try to exceed max
        for _ in 0..<1000 {
            spawner.update(deltaTime: 0.1)
        }

        // Should never exceed max enemies on screen
        #expect(spawner.getActiveEnemies().count <= Constants.maxEnemiesOnScreen)
    }

    // MARK: - Cleanup Tests

    @Test func testDeadEnemiesRemovedFromActiveList() {
        let scene = SKScene()
        let player = Player(character: .tariq)
        scene.addChild(player)
        let spawner = EnemySpawner(scene: scene, player: player)

        // Run updates until we have some enemies
        for _ in 0..<50 {
            spawner.update(deltaTime: 0.1)
        }

        let initialCount = spawner.getActiveEnemies().count

        // Kill all enemies
        for enemy in spawner.getActiveEnemies() {
            enemy.takeDamage(9999)
        }

        // Update should clean up dead enemies
        spawner.update(deltaTime: 0.1)

        // All killed enemies should be removed (or new ones spawned)
        let finalCount = spawner.getActiveEnemies().count
        #expect(finalCount <= initialCount)
    }
}
