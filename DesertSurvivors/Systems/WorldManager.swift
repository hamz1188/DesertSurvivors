//
//  WorldManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class WorldManager {
    private weak var scene: SKScene?
    private let player: SKNode
    private let tileSize: CGFloat = 1024 // Size of one background chunk
    private let backgroundTexture: SKTexture
    private var sandstorm: SKEmitterNode?
    
    private var tiles: [CGPoint: SKSpriteNode] = [:]
    private var props: [CGPoint: [SKNode]] = [:] // Props per tile coordinate
    
    // Grid management
    private var currentTileCoord: CGPoint = .zero
    
    // Prop textures
    private var propTextures: [SKTexture] = []
    
    init(scene: SKScene, player: SKNode) {
        self.scene = scene
        self.player = player
        
        // Use fallbacks if textures aren't loaded in Assets.xcassets yet
        // For now, assume background_desert exists and props are in Art/Environment
        self.backgroundTexture = SKTexture(imageNamed: "background_desert")
        self.backgroundTexture.filteringMode = .nearest
        
        loadPropTextures()
        setupSandstorm()
        update(playerPos: player.position)
    }
    
    private func setupSandstorm() {
        guard let scene = scene else { return }
        
        let storm = SKEmitterNode()
        storm.particleBirthRate = 40
        storm.particleLifetime = 4.0
        storm.particlePositionRange = CGVector(dx: 2000, dy: 2000)
        storm.particleSpeed = 150
        storm.particleSpeedRange = 50
        storm.emissionAngle = .pi * 0.1 // Blowing generally East
        storm.emissionAngleRange = 0.2
        storm.particleAlpha = 0.0
        storm.particleAlphaSpeed = 0.4
        storm.particleScale = 0.5
        storm.particleScaleSpeed = 0.5
        storm.particleColor = SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 1.0)
        storm.particleColorBlendFactor = 1.0
        storm.zPosition = Constants.ZPosition.ui - 1 // Just below HUD
        
        // Use a camera-relative position or a very large area
        scene.camera?.addChild(storm)
        self.sandstorm = storm
    }
    
    private func loadPropTextures() {
        // Attempt to load from Art/Environment (assuming they'll be added to project)
        // For testing, we can use fallbacks if needed.
        let names = ["cactus", "rock", "bones"]
        for name in names {
            let texture = SKTexture(imageNamed: name)
            if texture.size() != .zero {
                texture.filteringMode = .nearest
                propTextures.append(texture)
            }
        }
    }
    
    func update(playerPos: CGPoint) {
        let coordX = floor((playerPos.x + tileSize / 2) / tileSize)
        let coordY = floor((playerPos.y + tileSize / 2) / tileSize)
        let newCoord = CGPoint(x: coordX, y: coordY)
        
        if newCoord != currentTileCoord {
            currentTileCoord = newCoord
            refreshTiles()
        }
    }
    
    private func refreshTiles() {
        guard let scene = scene else { return }
        
        // We want a 3x3 or 5x5 grid around the player
        let buffer: CGFloat = 2
        let minX = Int(currentTileCoord.x - buffer)
        let maxX = Int(currentTileCoord.x + buffer)
        let minY = Int(currentTileCoord.y - buffer)
        let maxY = Int(currentTileCoord.y + buffer)
        
        var activeCoords = Set<CGPoint>()
        
        for x in minX...maxX {
            for y in minY...maxY {
                let coord = CGPoint(x: CGFloat(x), y: CGFloat(y))
                activeCoords.insert(coord)
                
                if tiles[coord] == nil {
                    createTile(at: coord)
                }
            }
        }
        
        // Remove far tiles
        for (coord, tile) in tiles {
            if !activeCoords.contains(coord) {
                tile.removeFromParent()
                tiles.removeValue(forKey: coord)
                
                // Also remove props
                if let tileProps = props[coord] {
                    for prop in tileProps {
                        prop.removeFromParent()
                    }
                    props.removeValue(forKey: coord)
                }
            }
        }
    }
    
    private func createTile(at coord: CGPoint) {
        guard let scene = scene else { return }
        
        let tile = SKSpriteNode(texture: backgroundTexture)
        tile.size = CGSize(width: tileSize, height: tileSize)
        tile.position = CGPoint(x: coord.x * tileSize, y: coord.y * tileSize)
        tile.zPosition = Constants.ZPosition.background
        scene.addChild(tile)
        tiles[coord] = tile
        
        spawnProps(for: coord)
    }
    
    private func spawnProps(for coord: CGPoint) {
        guard let scene = scene, !propTextures.isEmpty else { return }
        
        let numProps = Int.random(in: 3...6)
        var tileProps: [SKNode] = []
        
        // Define base size matching player scale (approx 40-50 pts)
        let baseSize: CGFloat = 40.0
        
        for _ in 0..<numProps {
            let texture = propTextures.randomElement()!
            let prop = SKSpriteNode(texture: texture)
            
            // Standardize size while keeping aspect ratio
            let ratio = texture.size().width / texture.size().height
            prop.size = CGSize(width: baseSize * ratio, height: baseSize)
            
            // Random position
            let offsetX = CGFloat.random(in: -tileSize/2...tileSize/2)
            let offsetY = CGFloat.random(in: -tileSize/2...tileSize/2)
            prop.position = CGPoint(
                x: coord.x * tileSize + offsetX,
                y: coord.y * tileSize + offsetY
            )
            
            // Type-specific logic based on texture name (simple heuristic via index/lookup would be better, but assuming textures are loaded)
            // Since we just have a list of textures, we can try to guess or just apply general rules.
            // Ideally we'd map naming to logic. Since we loaded them in order: "cactus", "rock", "bones", we can assume some behavior or check description.
            // Let's rely on a check if possible, or simple random variation without full rotation for upright objects.
            
            // FIX: Enforce upright orientation for everything except rocks
            // Assuming most sprites are generated "upright"
            prop.zRotation = 0
            
            // Randomize scale slightly
            let scaleVar = CGFloat.random(in: 0.8...1.2)
            prop.setScale(scaleVar)
            
            // Only rocks should rotate fully. Cacti and bones usually sit upright.
            // Since we can't easily check name from SKTexture instance without custom struct,
            // we will add a slight random "wobble" to everything to break uniformity, but NOT 360 spin.
            // If it's a "round" object (rock), 360 is fine.
            // For now, restrictive rotation:
            prop.zRotation = CGFloat.random(in: -0.1...0.1) 
            
            prop.zPosition = Constants.ZPosition.map
            
            // Add Shadow
            let shadowWidth = prop.size.width * 0.8
            let shadowHeight = prop.size.height * 0.4
            let shadow = SKShapeNode(ellipseOf: CGSize(width: shadowWidth, height: shadowHeight))
            shadow.fillColor = .black
            shadow.strokeColor = .clear
            shadow.alpha = 0.4
            shadow.position = CGPoint(x: 0, y: -prop.size.height * 0.45)
            shadow.zPosition = -1
            prop.addChild(shadow)
            
            // Depth sorting
            prop.zPosition = Constants.ZPosition.map - (offsetY / tileSize)
            
            scene.addChild(prop)
            tileProps.append(prop)
        }
        
        props[coord] = tileProps
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
