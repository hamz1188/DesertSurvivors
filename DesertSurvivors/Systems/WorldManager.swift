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
    private let tileSize: CGFloat = 512 // Smaller tiles for more detail
    private var sandstorm: SKEmitterNode?

    private var tiles: [CGPoint: SKNode] = [:]
    private var obstacles: [CGPoint: [SKNode]] = [:] // Collidable obstacles per tile
    private var decorations: [CGPoint: [SKNode]] = [:] // Non-collidable decorations

    // Grid management
    private var currentTileCoord: CGPoint = .zero

    // Obstacle tracking for collision
    private(set) var allObstacles: [SKNode] = []

    // Seeded random for consistent world generation
    private func seededRandom(x: Int, y: Int, seed: Int) -> Double {
        var hash = x * 374761393 + y * 668265263 + seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        hash = hash ^ (hash >> 16)
        return Double(abs(hash) % 10000) / 10000.0
    }

    init(scene: SKScene, player: SKNode) {
        self.scene = scene
        self.player = player

        setupSandstorm()
        update(playerPos: player.position)
    }

    private func setupSandstorm() {
        guard let scene = scene else { return }

        let storm = SKEmitterNode()
        storm.particleBirthRate = 30
        storm.particleLifetime = 5.0
        storm.particlePositionRange = CGVector(dx: 2000, dy: 2000)
        storm.particleSpeed = 120
        storm.particleSpeedRange = 40
        storm.emissionAngle = .pi * 0.15
        storm.emissionAngleRange = 0.3
        storm.particleAlpha = 0.0
        storm.particleAlphaSpeed = 0.3
        storm.particleScale = 0.3
        storm.particleScaleSpeed = 0.2
        storm.particleColor = SKColor(red: 0.92, green: 0.85, blue: 0.7, alpha: 1.0)
        storm.particleColorBlendFactor = 1.0
        storm.zPosition = Constants.ZPosition.ui - 1

        scene.camera?.addChild(storm)
        self.sandstorm = storm
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

        // Remove far tiles and their content
        for (coord, tile) in tiles {
            if !activeCoords.contains(coord) {
                tile.removeFromParent()
                tiles.removeValue(forKey: coord)

                if let tileObstacles = obstacles[coord] {
                    for obs in tileObstacles {
                        obs.removeFromParent()
                        if let idx = allObstacles.firstIndex(of: obs) {
                            allObstacles.remove(at: idx)
                        }
                    }
                    obstacles.removeValue(forKey: coord)
                }

                if let tileDecorations = decorations[coord] {
                    for dec in tileDecorations {
                        dec.removeFromParent()
                    }
                    decorations.removeValue(forKey: coord)
                }
            }
        }
    }

    private func createTile(at coord: CGPoint) {
        guard let scene = scene else { return }

        let tileContainer = SKNode()
        tileContainer.position = CGPoint(x: coord.x * tileSize, y: coord.y * tileSize)
        tileContainer.zPosition = Constants.ZPosition.background

        // Create procedural desert background
        let background = createDesertBackground(for: coord)
        tileContainer.addChild(background)

        scene.addChild(tileContainer)
        tiles[coord] = tileContainer

        // Spawn obstacles and decorations
        spawnObstacles(for: coord)
        spawnDecorations(for: coord)
    }

    private func createDesertBackground(for coord: CGPoint) -> SKNode {
        let container = SKNode()

        // Base sand color with subtle variation
        let baseColor = SKColor(red: 0.93, green: 0.85, blue: 0.68, alpha: 1.0)
        let base = SKShapeNode(rectOf: CGSize(width: tileSize, height: tileSize))
        base.fillColor = baseColor
        base.strokeColor = .clear
        base.zPosition = 0
        container.addChild(base)

        // Add sand dune patterns using seeded randomness for consistency
        let x = Int(coord.x)
        let y = Int(coord.y)

        // Sand ripples/dunes (subtle darker lines)
        let numRipples = 4 + Int(seededRandom(x: x, y: y, seed: 1) * 4)
        for i in 0..<numRipples {
            let ripple = createSandRipple(
                seed: x * 100 + y * 10 + i,
                tileSize: tileSize
            )
            container.addChild(ripple)
        }

        // Add some lighter sand patches
        let numPatches = 2 + Int(seededRandom(x: x, y: y, seed: 2) * 3)
        for i in 0..<numPatches {
            let patch = createSandPatch(
                seed: x * 50 + y * 20 + i,
                tileSize: tileSize
            )
            container.addChild(patch)
        }

        // Add subtle dark spots (shadows from unseen dunes)
        let numSpots = 1 + Int(seededRandom(x: x, y: y, seed: 3) * 2)
        for i in 0..<numSpots {
            let spot = createDarkSpot(
                seed: x * 30 + y * 40 + i,
                tileSize: tileSize
            )
            container.addChild(spot)
        }

        return container
    }

    private func createSandRipple(seed: Int, tileSize: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()

        // Seeded position
        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let startX = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 16)) &* 668265263
        let startY = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 11)) &* 374761393
        let width = CGFloat(80 + abs(hash) % 150)
        hash = (hash ^ (hash >> 14)) &* 1274126177
        let curve = CGFloat(abs(hash) % 30) - 15

        path.move(to: CGPoint(x: startX, y: startY))
        path.addQuadCurve(
            to: CGPoint(x: startX + width, y: startY + curve),
            control: CGPoint(x: startX + width / 2, y: startY + curve * 2)
        )

        let ripple = SKShapeNode(path: path)
        ripple.strokeColor = SKColor(red: 0.88, green: 0.78, blue: 0.58, alpha: 0.4)
        ripple.lineWidth = 2
        ripple.zPosition = 1
        return ripple
    }

    private func createSandPatch(seed: Int, tileSize: CGFloat) -> SKShapeNode {
        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let x = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 16)) &* 668265263
        let y = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 11)) &* 374761393
        let radius = CGFloat(30 + abs(hash) % 60)

        let patch = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius * 1.3))
        patch.position = CGPoint(x: x, y: y)
        patch.fillColor = SKColor(red: 0.96, green: 0.9, blue: 0.75, alpha: 0.5)
        patch.strokeColor = .clear
        patch.zPosition = 1
        return patch
    }

    private func createDarkSpot(seed: Int, tileSize: CGFloat) -> SKShapeNode {
        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let x = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 16)) &* 668265263
        let y = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
        hash = (hash ^ (hash >> 11)) &* 374761393
        let radius = CGFloat(40 + abs(hash) % 80)

        let spot = SKShapeNode(ellipseOf: CGSize(width: radius * 2.5, height: radius))
        spot.position = CGPoint(x: x, y: y)
        spot.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.3)
        spot.strokeColor = .clear
        spot.zPosition = 1
        return spot
    }

    private func spawnObstacles(for coord: CGPoint) {
        guard let scene = scene else { return }

        let x = Int(coord.x)
        let y = Int(coord.y)

        // Use seeded random for consistent obstacle placement
        let numObstacles = 2 + Int(seededRandom(x: x, y: y, seed: 100) * 3)
        var tileObstacles: [SKNode] = []

        for i in 0..<numObstacles {
            let seed = x * 1000 + y * 100 + i * 10

            // Position within tile (avoid edges)
            var hash = seed
            hash = (hash ^ (hash >> 13)) &* 1274126177
            let offsetX = CGFloat(abs(hash) % Int(tileSize * 0.8)) - tileSize * 0.4
            hash = (hash ^ (hash >> 16)) &* 668265263
            let offsetY = CGFloat(abs(hash) % Int(tileSize * 0.8)) - tileSize * 0.4

            let position = CGPoint(
                x: coord.x * tileSize + offsetX,
                y: coord.y * tileSize + offsetY
            )

            // Decide obstacle type
            hash = (hash ^ (hash >> 11)) &* 374761393
            let obstacleType = abs(hash) % 3

            let obstacle: SKNode
            switch obstacleType {
            case 0:
                obstacle = createCactus(seed: seed)
            case 1:
                obstacle = createRock(seed: seed)
            default:
                obstacle = createBonesPile(seed: seed)
            }

            obstacle.position = position
            obstacle.zPosition = Constants.ZPosition.map - (offsetY / tileSize) * 0.1
            obstacle.name = "obstacle"

            scene.addChild(obstacle)
            tileObstacles.append(obstacle)
            allObstacles.append(obstacle)
        }

        obstacles[coord] = tileObstacles
    }

    private func spawnDecorations(for coord: CGPoint) {
        guard let scene = scene else { return }

        let x = Int(coord.x)
        let y = Int(coord.y)

        // Small decorative elements (non-collidable)
        let numDecorations = 3 + Int(seededRandom(x: x, y: y, seed: 200) * 5)
        var tileDecorations: [SKNode] = []

        for i in 0..<numDecorations {
            let seed = x * 2000 + y * 200 + i * 20

            var hash = seed
            hash = (hash ^ (hash >> 13)) &* 1274126177
            let offsetX = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2
            hash = (hash ^ (hash >> 16)) &* 668265263
            let offsetY = CGFloat(abs(hash) % Int(tileSize)) - tileSize / 2

            let position = CGPoint(
                x: coord.x * tileSize + offsetX,
                y: coord.y * tileSize + offsetY
            )

            hash = (hash ^ (hash >> 11)) &* 374761393
            let decorType = abs(hash) % 4

            let decoration: SKNode
            switch decorType {
            case 0:
                decoration = createSmallRock(seed: seed)
            case 1:
                decoration = createDesertGrass(seed: seed)
            case 2:
                decoration = createSkull(seed: seed)
            default:
                decoration = createTumbleweed(seed: seed)
            }

            decoration.position = position
            decoration.zPosition = Constants.ZPosition.map - (offsetY / tileSize) * 0.1
            decoration.name = "decoration"

            scene.addChild(decoration)
            tileDecorations.append(decoration)
        }

        decorations[coord] = tileDecorations
    }

    // MARK: - Procedural Obstacle Creation

    private func createCactus(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let scale = 0.8 + Double(abs(hash) % 40) / 100.0

        // Main body
        let bodyHeight: CGFloat = CGFloat(50 * scale)
        let bodyWidth: CGFloat = CGFloat(18 * scale)

        let body = SKShapeNode(rectOf: CGSize(width: bodyWidth, height: bodyHeight), cornerRadius: bodyWidth / 2)
        body.fillColor = SKColor(red: 0.3, green: 0.55, blue: 0.25, alpha: 1.0)
        body.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.18, alpha: 1.0)
        body.lineWidth = 1.5
        body.position = CGPoint(x: 0, y: bodyHeight / 2)
        container.addChild(body)

        // Vertical lines on cactus
        for i in -1...1 {
            let line = SKShapeNode(rectOf: CGSize(width: 1, height: bodyHeight - 10))
            line.fillColor = SKColor(red: 0.25, green: 0.45, blue: 0.2, alpha: 0.5)
            line.strokeColor = .clear
            line.position = CGPoint(x: CGFloat(i) * 4, y: bodyHeight / 2)
            container.addChild(line)
        }

        // Arms (0-2 arms)
        hash = (hash ^ (hash >> 16)) &* 668265263
        let numArms = abs(hash) % 3

        if numArms >= 1 {
            let leftArm = createCactusArm(height: CGFloat(25 * scale), width: CGFloat(10 * scale), facingRight: false)
            leftArm.position = CGPoint(x: -bodyWidth / 2, y: bodyHeight * 0.6)
            container.addChild(leftArm)
        }

        if numArms >= 2 {
            let rightArm = createCactusArm(height: CGFloat(20 * scale), width: CGFloat(10 * scale), facingRight: true)
            rightArm.position = CGPoint(x: bodyWidth / 2, y: bodyHeight * 0.4)
            container.addChild(rightArm)
        }

        // Shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: bodyWidth * 2, height: bodyWidth * 0.8))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -5)
        shadow.zPosition = -1
        container.addChild(shadow)

        // Collision radius stored in userData
        container.userData = ["collisionRadius": bodyWidth * 0.8]

        return container
    }

    private func createCactusArm(height: CGFloat, width: CGFloat, facingRight: Bool) -> SKNode {
        let arm = SKNode()

        // Horizontal part
        let horizontal = SKShapeNode(rectOf: CGSize(width: height * 0.6, height: width), cornerRadius: width / 2)
        horizontal.fillColor = SKColor(red: 0.3, green: 0.55, blue: 0.25, alpha: 1.0)
        horizontal.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.18, alpha: 1.0)
        horizontal.lineWidth = 1
        horizontal.position = CGPoint(x: facingRight ? height * 0.3 : -height * 0.3, y: 0)
        arm.addChild(horizontal)

        // Vertical part
        let vertical = SKShapeNode(rectOf: CGSize(width: width, height: height * 0.5), cornerRadius: width / 2)
        vertical.fillColor = SKColor(red: 0.3, green: 0.55, blue: 0.25, alpha: 1.0)
        vertical.strokeColor = SKColor(red: 0.2, green: 0.4, blue: 0.18, alpha: 1.0)
        vertical.lineWidth = 1
        vertical.position = CGPoint(x: facingRight ? height * 0.5 : -height * 0.5, y: height * 0.25)
        arm.addChild(vertical)

        return arm
    }

    private func createRock(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let scale = 0.7 + Double(abs(hash) % 50) / 100.0

        // Create irregular rock shape
        let baseSize = CGFloat(35 * scale)
        let path = CGMutablePath()

        // Generate irregular polygon
        let points = 6 + abs(hash >> 5) % 3
        var rockPoints: [CGPoint] = []

        for i in 0..<points {
            let angle = (CGFloat(i) / CGFloat(points)) * .pi * 2
            hash = (hash ^ (hash >> 11)) &* 374761393
            let radiusVariation = 0.7 + Double(abs(hash) % 30) / 100.0
            let radius = baseSize * CGFloat(radiusVariation)

            rockPoints.append(CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius * 0.7 // Flatten slightly
            ))
        }

        path.move(to: rockPoints[0])
        for i in 1..<rockPoints.count {
            path.addLine(to: rockPoints[i])
        }
        path.closeSubpath()

        let rock = SKShapeNode(path: path)
        rock.fillColor = SKColor(red: 0.5, green: 0.45, blue: 0.4, alpha: 1.0)
        rock.strokeColor = SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
        rock.lineWidth = 2
        container.addChild(rock)

        // Highlight on top
        let highlight = SKShapeNode(ellipseOf: CGSize(width: baseSize * 0.5, height: baseSize * 0.25))
        highlight.fillColor = SKColor(red: 0.6, green: 0.55, blue: 0.5, alpha: 0.5)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -baseSize * 0.1, y: baseSize * 0.2)
        container.addChild(highlight)

        // Shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: baseSize * 1.5, height: baseSize * 0.5))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.3)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: baseSize * 0.2, y: -baseSize * 0.4)
        shadow.zPosition = -1
        container.addChild(shadow)

        container.userData = ["collisionRadius": baseSize * 0.7]

        return container
    }

    private func createBonesPile(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let scale = 0.8 + Double(abs(hash) % 30) / 100.0

        let boneColor = SKColor(red: 0.95, green: 0.92, blue: 0.85, alpha: 1.0)
        let boneStroke = SKColor(red: 0.8, green: 0.75, blue: 0.65, alpha: 1.0)

        // Create 3-4 bones in a pile
        let numBones = 3 + abs(hash >> 8) % 2

        for i in 0..<numBones {
            hash = (hash ^ (hash >> 11)) &* 374761393
            let boneLength = CGFloat((15 + abs(hash) % 15)) * CGFloat(scale)
            let boneWidth = boneLength * 0.2

            // Bone shape (two circles connected by rectangle)
            let bone = SKNode()

            let shaft = SKShapeNode(rectOf: CGSize(width: boneLength, height: boneWidth))
            shaft.fillColor = boneColor
            shaft.strokeColor = boneStroke
            shaft.lineWidth = 0.5
            bone.addChild(shaft)

            let end1 = SKShapeNode(circleOfRadius: boneWidth * 0.7)
            end1.fillColor = boneColor
            end1.strokeColor = boneStroke
            end1.lineWidth = 0.5
            end1.position = CGPoint(x: -boneLength / 2, y: 0)
            bone.addChild(end1)

            let end2 = SKShapeNode(circleOfRadius: boneWidth * 0.7)
            end2.fillColor = boneColor
            end2.strokeColor = boneStroke
            end2.lineWidth = 0.5
            end2.position = CGPoint(x: boneLength / 2, y: 0)
            bone.addChild(end2)

            // Random position and rotation
            hash = (hash ^ (hash >> 14)) &* 1274126177
            bone.position = CGPoint(
                x: CGFloat(abs(hash) % 20) - 10,
                y: CGFloat(abs(hash >> 8) % 15) - 7
            )
            bone.zRotation = CGFloat(abs(hash >> 4) % 100) / 100.0 * .pi
            bone.zPosition = CGFloat(i)

            container.addChild(bone)
        }

        // Shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 40 * CGFloat(scale), height: 20 * CGFloat(scale)))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.25)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -12)
        shadow.zPosition = -1
        container.addChild(shadow)

        container.userData = ["collisionRadius": CGFloat(20 * scale)]

        return container
    }

    // MARK: - Procedural Decoration Creation

    private func createSmallRock(seed: Int) -> SKNode {
        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let size = CGFloat(8 + abs(hash) % 10)

        let rock = SKShapeNode(ellipseOf: CGSize(width: size, height: size * 0.7))
        rock.fillColor = SKColor(red: 0.55, green: 0.5, blue: 0.45, alpha: 1.0)
        rock.strokeColor = SKColor(red: 0.4, green: 0.35, blue: 0.3, alpha: 1.0)
        rock.lineWidth = 1
        return rock
    }

    private func createDesertGrass(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let numBlades = 3 + abs(hash) % 4

        for i in 0..<numBlades {
            hash = (hash ^ (hash >> 11)) &* 374761393
            let height = CGFloat(10 + abs(hash) % 10)
            let xOffset = CGFloat(abs(hash >> 4) % 8) - 4

            let path = CGMutablePath()
            path.move(to: CGPoint(x: xOffset, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: xOffset + CGFloat(abs(hash >> 8) % 6) - 3, y: height),
                control: CGPoint(x: xOffset + 3, y: height * 0.6)
            )

            let blade = SKShapeNode(path: path)
            blade.strokeColor = SKColor(red: 0.6, green: 0.55, blue: 0.35, alpha: 0.8)
            blade.lineWidth = 1.5
            blade.zPosition = CGFloat(i) * 0.1
            container.addChild(blade)
        }

        return container
    }

    private func createSkull(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let scale = 0.6 + Double(abs(hash) % 40) / 100.0

        let skullColor = SKColor(red: 0.95, green: 0.9, blue: 0.82, alpha: 1.0)
        let skullStroke = SKColor(red: 0.75, green: 0.7, blue: 0.6, alpha: 1.0)

        // Skull shape
        let skull = SKShapeNode(ellipseOf: CGSize(width: CGFloat(16 * scale), height: CGFloat(14 * scale)))
        skull.fillColor = skullColor
        skull.strokeColor = skullStroke
        skull.lineWidth = 1
        container.addChild(skull)

        // Eye sockets
        let eyeSize = CGFloat(4 * scale)
        let leftEye = SKShapeNode(ellipseOf: CGSize(width: eyeSize, height: eyeSize * 1.2))
        leftEye.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: CGFloat(-4 * scale), y: CGFloat(2 * scale))
        container.addChild(leftEye)

        let rightEye = SKShapeNode(ellipseOf: CGSize(width: eyeSize, height: eyeSize * 1.2))
        rightEye.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: CGFloat(4 * scale), y: CGFloat(2 * scale))
        container.addChild(rightEye)

        // Nose hole
        let nose = SKShapeNode(path: {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: CGFloat(-1 * scale)))
            path.addLine(to: CGPoint(x: CGFloat(-2 * scale), y: CGFloat(-4 * scale)))
            path.addLine(to: CGPoint(x: CGFloat(2 * scale), y: CGFloat(-4 * scale)))
            path.closeSubpath()
            return path
        }())
        nose.fillColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        nose.strokeColor = .clear
        container.addChild(nose)

        // Shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: CGFloat(20 * scale), height: CGFloat(8 * scale)))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: CGFloat(-10 * scale))
        shadow.zPosition = -1
        container.addChild(shadow)

        return container
    }

    private func createTumbleweed(seed: Int) -> SKNode {
        let container = SKNode()

        var hash = seed
        hash = (hash ^ (hash >> 13)) &* 1274126177
        let size = CGFloat(12 + abs(hash) % 8)

        // Main ball
        let ball = SKShapeNode(circleOfRadius: size)
        ball.fillColor = SKColor(red: 0.55, green: 0.45, blue: 0.3, alpha: 0.8)
        ball.strokeColor = SKColor(red: 0.45, green: 0.35, blue: 0.2, alpha: 1.0)
        ball.lineWidth = 1.5
        container.addChild(ball)

        // Add some twigs
        for i in 0..<6 {
            let angle = CGFloat(i) / 6.0 * .pi * 2
            hash = (hash ^ (hash >> 11)) &* 374761393
            let length = size * (0.8 + CGFloat(abs(hash) % 40) / 100.0)

            let twig = SKShapeNode(rectOf: CGSize(width: 1.5, height: length))
            twig.fillColor = SKColor(red: 0.45, green: 0.35, blue: 0.2, alpha: 1.0)
            twig.strokeColor = .clear
            twig.position = CGPoint(x: cos(angle) * size * 0.5, y: sin(angle) * size * 0.5)
            twig.zRotation = angle
            container.addChild(twig)
        }

        // Shadow
        let shadow = SKShapeNode(ellipseOf: CGSize(width: size * 1.5, height: size * 0.5))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 0, y: -size * 0.8)
        shadow.zPosition = -1
        container.addChild(shadow)

        return container
    }

    // MARK: - Collision Checking

    func getObstacleCollision(at position: CGPoint, radius: CGFloat) -> CGPoint? {
        for obstacle in allObstacles {
            guard let userData = obstacle.userData,
                  let obstacleRadius = userData["collisionRadius"] as? CGFloat else {
                continue
            }

            let distance = position.distance(to: obstacle.position)
            let minDistance = radius + obstacleRadius

            if distance < minDistance {
                // Return push-out direction
                let pushDirection = (position - obstacle.position).normalized()
                let overlap = minDistance - distance
                return pushDirection * overlap
            }
        }
        return nil
    }
}

// CGPoint conforms to Hashable in iOS 16+, only add extension for older versions
#if !os(iOS) || swift(<5.9)
extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
#endif
