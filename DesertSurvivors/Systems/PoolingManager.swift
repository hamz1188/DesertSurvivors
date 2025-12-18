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
    // Will be used for projectiles, pickups, damage numbers, etc.
    // For now, enemies are managed by EnemySpawner
}

