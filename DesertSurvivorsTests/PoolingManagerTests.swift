//
//  PoolingManagerTests.swift
//  DesertSurvivorsTests
//
//  Created by Ahmed AlHameli on 21/12/2025.
//

import Testing
import SpriteKit
@testable import DesertSurvivors

struct ObjectPoolTests {
    
    // MARK: - Basic Pool Operations
    
    @Test func testSpawnFromEmptyPoolCreatesNew() {
        let pool = ObjectPool<SKNode>(initialSize: 0) {
            SKNode()
        }
        
        let node = pool.spawn()
        
        #expect(node != nil, "Should create new node when pool is empty")
        #expect(node.isHidden == false, "Spawned node should be visible")
    }
    
    @Test func testSpawnFromPrefilledPool() {
        let pool = ObjectPool<SKNode>(initialSize: 5) {
            SKNode()
        }
        
        let node = pool.spawn()
        
        #expect(node != nil)
        #expect(node.isHidden == false)
    }
    
    @Test func testDespawnHidesNode() {
        let pool = ObjectPool<SKNode>(initialSize: 1) {
            SKNode()
        }
        
        let node = pool.spawn()
        #expect(node.isHidden == false)
        
        pool.despawn(node)
        #expect(node.isHidden == true, "Despawned node should be hidden")
    }
    
    @Test func testNodeReuse() {
        let pool = ObjectPool<SKNode>(initialSize: 0) {
            SKNode()
        }
        
        // Spawn and despawn a node
        let node1 = pool.spawn()
        pool.despawn(node1)
        
        // Spawn again - should get the same node back
        let node2 = pool.spawn()
        
        #expect(node1 === node2, "Pool should reuse despawned nodes")
    }
    
    @Test func testGetActiveReturnsOnlyActiveNodes() {
        let pool = ObjectPool<SKNode>(initialSize: 0) {
            SKNode()
        }
        
        let node1 = pool.spawn()
        let node2 = pool.spawn()
        let node3 = pool.spawn()
        
        #expect(pool.getActive().count == 3)
        
        pool.despawn(node2)
        
        #expect(pool.getActive().count == 2)
        #expect(!pool.getActive().contains(where: { $0 === node2 }))
    }
    
    @Test func testClearDespawnsAll() {
        let pool = ObjectPool<SKNode>(initialSize: 0) {
            SKNode()
        }
        
        _ = pool.spawn()
        _ = pool.spawn()
        _ = pool.spawn()
        
        #expect(pool.getActive().count == 3)
        
        pool.clear()
        
        #expect(pool.getActive().isEmpty, "Clear should despawn all active nodes")
    }
}

struct PoolingManagerTests {
    
    @Test func testSpawnProjectileCreatesPool() {
        // Note: PoolingManager is a singleton, so this affects global state
        let projectile = PoolingManager.shared.spawnProjectile(weaponName: "TestWeapon") {
            Projectile(damage: 10, speed: 100, direction: CGPoint(x: 1, y: 0))
        }
        
        #expect(projectile != nil)
        #expect(projectile.isHidden == false)
    }
    
    @Test func testProjectilePoolReuse() {
        let weaponName = "TestWeaponReuse"
        
        // Spawn and despawn
        let p1 = PoolingManager.shared.spawnProjectile(weaponName: weaponName) {
            Projectile(damage: 10, speed: 100, direction: CGPoint(x: 1, y: 0))
        }
        PoolingManager.shared.despawnProjectile(p1, weaponName: weaponName)
        
        // Spawn again
        let p2 = PoolingManager.shared.spawnProjectile(weaponName: weaponName) {
            Projectile(damage: 10, speed: 100, direction: CGPoint(x: 1, y: 0))
        }
        
        #expect(p1 === p2, "Should reuse the same projectile from pool")
    }
    
    @Test func testSeparatePoolsPerWeapon() {
        let p1 = PoolingManager.shared.spawnProjectile(weaponName: "Weapon_A") {
            Projectile(damage: 10, speed: 100, direction: .zero)
        }
        
        let p2 = PoolingManager.shared.spawnProjectile(weaponName: "Weapon_B") {
            Projectile(damage: 10, speed: 100, direction: .zero)
        }
        
        #expect(p1 !== p2, "Different weapons should have separate pools")
    }
}
