//
//  MapGenerator.swift
//  DesertSurvivors
//
//  Created by AI Agent on 21/12/2025.
//

import SpriteKit
import GameplayKit

class MapGenerator {
    static let shared = MapGenerator()
    
    // World Configuration
    let worldSize = CGSize(width: 4000, height: 4000)
    let tileSize: CGFloat = 32.0
    
    // Prop Configuration
    struct PropType {
        let name: String
        let size: CGSize
        let probability: Double // Chance to spawn per 100x100 area
        let isObstacle: Bool // If true, adds physics body
    }
    
    private let props: [PropType] = [
        PropType(name: "giant_cactus", size: CGSize(width: 64, height: 64), probability: 0.05, isObstacle: true),
        PropType(name: "sandstone_rock", size: CGSize(width: 64, height: 64), probability: 0.04, isObstacle: true),
        PropType(name: "giant_bones", size: CGSize(width: 64, height: 64), probability: 0.02, isObstacle: true),
        PropType(name: "ancient_ruin", size: CGSize(width: 64, height: 64), probability: 0.01, isObstacle: true),
        PropType(name: "dead_bush", size: CGSize(width: 32, height: 32), probability: 0.15, isObstacle: false), // Decoration only
        PropType(name: "palm_tree", size: CGSize(width: 64, height: 64), probability: 0.03, isObstacle: true)
    ]
    
    private init() {}
    
    func generateMap(in scene: SKScene) {
        let mapNode = SKNode()
        mapNode.name = "WorldMap"
        mapNode.zPosition = Constants.ZPosition.background
        scene.addChild(mapNode)
        
        generateGround(into: mapNode)
        generateProps(into: mapNode)
        
        // Add World Borders
        addBorders(to: mapNode)
    }
    
    private func generateGround(into container: SKNode) {
        // Tiling the background texture manually or using a large shader node
        // For performance with 4000x4000 (125x125 tiles = ~15k nodes), individual sprites is too heavy.
        // Better approach: Use a single large sprite with a tiled shader, OR SKTileMapNode.
        // Let's use SKTileMapNode as it batches draws.
        
        let texture = SKTexture(imageNamed: "background_desert")
        texture.filteringMode = .nearest
        
        let tileDefinition = SKTileDefinition(texture: texture, size: CGSize(width: tileSize, height: tileSize))
        let tileGroup = SKTileGroup(tileDefinition: tileDefinition)
        let tileSet = SKTileSet(tileGroups: [tileGroup], tileSetType: .grid)
        
        let cols = Int(worldSize.width / tileSize) + 2
        let rows = Int(worldSize.height / tileSize) + 2
        
        let existingMap = SKTileMapNode(tileSet: tileSet, columns: cols, rows: rows, tileSize: CGSize(width: tileSize, height: tileSize))
        existingMap.fill(with: tileGroup)
        existingMap.position = .zero
        existingMap.zPosition = Constants.ZPosition.background
        
        container.addChild(existingMap)
    }
    
    private func generateProps(into container: SKNode) {
        // Simple scatter based on density
        // We'll divide the world into chunks or just random scatter
        
        let numberOfProps = Int((worldSize.width * worldSize.height) / 10000.0) // Area based count
        
        for _ in 0..<numberOfProps {
            // Pick random prop based on weights? Or just simple iteration
            // Let's pick a random point
            
            let randX = CGFloat.random(in: -worldSize.width/2 ... worldSize.width/2)
            let randY = CGFloat.random(in: -worldSize.height/2 ... worldSize.height/2)
            let position = CGPoint(x: randX, y: randY)
            
            // Safe zone check (don't spawn on top of player at 0,0)
            if position.length() < 300 { continue }
            
            // Pick a prop type
            if let randomProp = props.randomElement() {
                // Roll probability check? 
                // We're iterating abstract "slots" vs explicit count. 
                // Let's just spawn it if random check passes relative to its rarity?
                // Actually, let's just pick one uniform random prop type per iteration effectively
                
                // Better logic: Iterate counts for each prop type
                // But simple random selection from weighted array is easier.
                // Re-implementation:
            }
        }
        
        // Better scatter logic:
        props.forEach { prop in
            let countIndex = Int((worldSize.width * worldSize.height) / 10000.0 * prop.probability)
            
            for _ in 0..<countIndex {
                let randX = CGFloat.random(in: -worldSize.width/2 ... worldSize.width/2)
                let randY = CGFloat.random(in: -worldSize.height/2 ... worldSize.height/2)
                let position = CGPoint(x: randX, y: randY)
                
                if position.length() < 300 { continue }
                
                createProp(type: prop, position: position, into: container)
            }
        }
    }
    
    private func createProp(type: PropType, position: CGPoint, into container: SKNode) {
        let node = SKSpriteNode(imageNamed: type.name)
        node.position = position
        node.size = type.size
        node.zPosition = Constants.ZPosition.map // Props sit on map layer (above background)
        
        // Sorting: Y-sorting is crucial for top-down perspective
        // SpriteKit does not strictly auto-sort inside a node unless we update zPos every frame which is heavy.
        // Simple fix: We use a fixed Z but relies on player moving. 
        // Actually, for depth, we usually map -Y to Z.
        // But for static props, we can set just ZPosition.map.
        // However, player needs to go behind/in-front.
        // We should add these to the specific object layer where Player also lives, OR use Z = -position.y logic globally.
        // For this task, let's keep it simple: props are obstacles the player collides with.
        
        if type.isObstacle {
            // Physics Body
            // Make physics body smaller than sprite for better feel (base of the object)
            let bodySize = CGSize(width: type.size.width * 0.6, height: type.size.height * 0.4)
            let centerOffset = CGPoint(x: 0, y: -type.size.height * 0.3) // Lower part
            
            let body = SKPhysicsBody(rectangleOf: bodySize, center: centerOffset)
            body.isDynamic = false // Static obstacle
            body.categoryBitMask = Constants.PhysicsCategory.none // Wall? We need a Wall category?
            // Existing categories: player, enemy, projectile, pickup, weapon.
            // Let's assign it to something or leave it as default with collision masks.
            // Constants doesn't have 'wall'. Let's reuse 'none' or update Constants.
            // Actually, player/enemy collision masks need to include this.
            // For now, let's make it '0b100000' (32) and update Constants later or locally.
            body.categoryBitMask = Constants.PhysicsCategory.wall 
            body.collisionBitMask = Constants.PhysicsCategory.player | Constants.PhysicsCategory.enemy
            body.contactTestBitMask = 0
            
            node.physicsBody = body
        }
        
        container.addChild(node)
    }
    
    private func addBorders(to container: SKNode) {
        let borderThickness: CGFloat = 200
        let halfWidth = worldSize.width / 2
        let halfHeight = worldSize.height / 2
        
        let borders = [
            CGRect(x: -halfWidth - borderThickness, y: -halfHeight - borderThickness, width: worldSize.width + 2*borderThickness, height: borderThickness), // Bottom
            CGRect(x: -halfWidth - borderThickness, y: halfHeight, width: worldSize.width + 2*borderThickness, height: borderThickness), // Top
            CGRect(x: -halfWidth - borderThickness, y: -halfHeight, width: borderThickness, height: worldSize.height), // Left
            CGRect(x: halfWidth, y: -halfHeight, width: borderThickness, height: worldSize.height) // Right
        ]
        
        for rect in borders {
            let node = SKShapeNode(rect: rect)
            node.fillColor = .black
            node.strokeColor = .clear
            node.zPosition = Constants.ZPosition.map + 1
            
            let body = SKPhysicsBody(edgeLoopFrom: rect)
            body.categoryBitMask = Constants.PhysicsCategory.wall // Wall
            body.collisionBitMask = Constants.PhysicsCategory.player | Constants.PhysicsCategory.enemy
            
            node.physicsBody = body
            container.addChild(node)
        }
    }
}
