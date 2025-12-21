//
//  CollisionManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SpatialHash {
    private var cells: [Int: [SKNode]] = [:]
    private let cellSize: CGFloat = Constants.spatialHashCellSize
    
    func hash(_ position: CGPoint) -> Int {
        let x = Int(position.x / cellSize)
        let y = Int(position.y / cellSize)
        return x * 73856093 ^ y * 19349663
    }
    
    func insert(_ node: SKNode) {
        let key = hash(node.position)
        if cells[key] == nil {
            cells[key] = []
        }
        cells[key]?.append(node)
    }
    
    func query(near position: CGPoint, radius: CGFloat) -> [SKNode] {
        var result: [SKNode] = []
        let cellsToCheck = Int(ceil(radius / cellSize))
        let radiusSquared = radius * radius
        
        for dx in -cellsToCheck...cellsToCheck {
            for dy in -cellsToCheck...cellsToCheck {
                // Skip corner cells outside circular radius
                let cellDistSquared = CGFloat(dx * dx + dy * dy) * cellSize * cellSize
                if cellDistSquared > radiusSquared * 2.0 { continue } // *2.0 offers a safe buffer
                
                let checkPos = CGPoint(
                    x: position.x + CGFloat(dx) * cellSize,
                    y: position.y + CGFloat(dy) * cellSize
                )
                if let nodes = cells[hash(checkPos)] {
                    result.append(contentsOf: nodes)
                }
            }
        }
        return result
    }
    
    func clear() {
        cells.removeAll(keepingCapacity: true)
    }

    // Incremental update methods for optimization
    func remove(_ node: SKNode, from position: CGPoint) {
        let key = hash(position)
        if let index = cells[key]?.firstIndex(where: { $0 === node }) {
            cells[key]?.remove(at: index)
            if cells[key]?.isEmpty == true {
                cells[key] = nil
            }
        }
    }

    func move(_ node: SKNode, from oldPosition: CGPoint, to newPosition: CGPoint) {
        let oldKey = hash(oldPosition)
        let newKey = hash(newPosition)

        // If keys are the same, no need to update
        guard oldKey != newKey else { return }

        // Remove from old cell
        if let index = cells[oldKey]?.firstIndex(where: { $0 === node }) {
            cells[oldKey]?.remove(at: index)
            if cells[oldKey]?.isEmpty == true {
                cells[oldKey] = nil
            }
        }

        // Insert into new cell
        if cells[newKey] == nil {
            cells[newKey] = []
        }
        cells[newKey]?.append(node)
    }
}

class CollisionManager {
    private(set) var spatialHash: SpatialHash
    private var framesSinceFullRebuild: Int = 0
    private let fullRebuildInterval: Int = 120 // Full rebuild every 2 seconds at 60fps

    init() {
        spatialHash = SpatialHash()
    }

    func update(nodes: [SKNode]) {
        framesSinceFullRebuild += 1

        // Periodically do a full rebuild to clean up dead enemies
        if framesSinceFullRebuild >= fullRebuildInterval {
            spatialHash.clear()
            for node in nodes {
                spatialHash.insert(node)
                if let enemy = node as? BaseEnemy {
                    enemy.lastHashedPosition = enemy.position
                    enemy.needsRehash = false
                }
            }
            framesSinceFullRebuild = 0
            return
        }

        // Optimized: incremental updates for active enemies
        for node in nodes {
            if let enemy = node as? BaseEnemy {
                if enemy.needsRehash {
                    // Move to new cell (or insert if first time)
                    if enemy.lastHashedPosition == .zero {
                        // First insertion
                        spatialHash.insert(enemy)
                    } else {
                        // Move from old position to new position
                        spatialHash.move(enemy, from: enemy.lastHashedPosition, to: enemy.position)
                    }
                    enemy.lastHashedPosition = enemy.position
                    enemy.needsRehash = false
                }
            } else {
                // Non-enemy nodes: always insert (for compatibility)
                spatialHash.insert(node)
            }
        }
    }
    
    func checkCollisions(player: Player, activeEnemies: [BaseEnemy], pickups: [SKNode]) {
        // Player-enemy collision using spatial hash
        let nearbyNodes = spatialHash.query(near: player.position, radius: 40)
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            if player.position.distance(to: enemy.position) < 30 {
                player.takeDamage(Float(enemy.damage))
            }
        }
        
        // Player-pickup collision (handled by pickup radius)
        // This will be expanded when pickups are implemented
    }
    
    func getNearbyNodes(near position: CGPoint, radius: CGFloat) -> [SKNode] {
        return spatialHash.query(near: position, radius: radius)
    }
}

