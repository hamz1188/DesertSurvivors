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
        
        for dx in -cellsToCheck...cellsToCheck {
            for dy in -cellsToCheck...cellsToCheck {
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
}

class CollisionManager {
    private(set) var spatialHash: SpatialHash
    
    init() {
        spatialHash = SpatialHash()
    }
    
    func update(nodes: [SKNode]) {
        spatialHash.clear()
        for node in nodes {
            spatialHash.insert(node)
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

