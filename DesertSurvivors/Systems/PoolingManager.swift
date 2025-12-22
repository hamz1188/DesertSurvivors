//
//  PoolingManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class ObjectPool<T: SKNode> {
    private var available: [T] = []
    private var active: Set<T> = []
    private let factory: () -> T
    
    init(initialSize: Int, factory: @escaping () -> T) {
        self.factory = factory
        for _ in 0..<initialSize {
            let obj = factory()
            obj.isHidden = true
            available.append(obj)
        }
    }
    
    func spawn() -> T {
        let obj: T
        if let existing = available.popLast() {
            obj = existing
        } else {
            obj = factory()
        }
        obj.isHidden = false
        active.insert(obj)
        return obj
    }
    
    func despawn(_ obj: T) {
        obj.isHidden = true
        obj.removeAllActions()
        active.remove(obj)
        available.append(obj)
    }
    
    func getActive() -> [T] {
        return Array(active)
    }
    
    func clear() {
        for obj in active {
            despawn(obj)
        }
    }
}

class PoolingManager {
    static let shared = PoolingManager()

    private var projectilePools: [String: ObjectPool<Projectile>] = [:]
    private var enemyPools: [String: ObjectPool<BaseEnemy>] = [:]

    private init() {}
    
    func spawnProjectile(weaponName: String, factory: @escaping () -> Projectile) -> Projectile {
        if projectilePools[weaponName] == nil {
            projectilePools[weaponName] = ObjectPool<Projectile>(initialSize: 20, factory: factory)
        }
        
        let projectile = projectilePools[weaponName]!.spawn()
        projectile.isHidden = false
        projectile.isPaused = false
        return projectile
    }
    
    func despawnProjectile(_ projectile: Projectile, weaponName: String) {
        projectile.removeFromParent()
        projectilePools[weaponName]?.despawn(projectile)
    }

    // MARK: - Enemy Pooling

    func spawnEnemy(enemyType: String, factory: @escaping () -> BaseEnemy) -> BaseEnemy {
        if enemyPools[enemyType] == nil {
            enemyPools[enemyType] = ObjectPool<BaseEnemy>(initialSize: 10, factory: factory)
        }

        let enemy = enemyPools[enemyType]!.spawn()
        enemy.poolType = enemyType
        enemy.reset()
        return enemy
    }

    func despawnEnemy(_ enemy: BaseEnemy, enemyType: String) {
        enemy.prepareForPool()
        enemyPools[enemyType]?.despawn(enemy)
    }

    func getActiveEnemies(enemyType: String) -> [BaseEnemy] {
        return enemyPools[enemyType]?.getActive() ?? []
    }

    // MARK: - Cleanup

    func clearAll() {
        for pool in projectilePools.values {
            pool.clear()
        }
        projectilePools.removeAll()

        for pool in enemyPools.values {
            pool.clear()
        }
        enemyPools.removeAll()
    }

    func clearEnemies() {
        for pool in enemyPools.values {
            pool.clear()
        }
        enemyPools.removeAll()
    }
}

