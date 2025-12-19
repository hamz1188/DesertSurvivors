//
//  WrathOfTheSun.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class WrathOfTheSun: BaseWeapon {
    // Evolved Sun Ray (Sun Ray + Scarab Amulet)
    // Behavior: 3 massive beams continuously rotating around the player
    
    private var beamContainer: SKNode?
    private var beams: [SKShapeNode] = []
    private let rotationSpeed: CGFloat = 2.0 // Radians per second
    private let beamLength: CGFloat = 800
    private let beamWidth: CGFloat = 60
    
    init() {
        super.init(name: "Wrath of the Sun", baseDamage: 12, cooldown: 0.1) // Low cooldown for continuous hit check
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, spatialHash: SpatialHash, deltaTime: TimeInterval) {
        // Initialize beams if not present
        if beamContainer == nil {
            createBeams()
        }
    }
    
    private func createBeams() {
        guard let scene = scene else { return }
        
        let container = SKNode()
        container.zPosition = Constants.ZPosition.projectile
        scene.addChild(container)
        beamContainer = container
        
        for i in 0..<3 {
            let angle = (CGFloat(i) / 3.0) * 2 * .pi
            let beam = createBeam()
            beam.zRotation = angle
            container.addChild(beam)
            beams.append(beam)
        }
    }
    
    private func createBeam() -> SKShapeNode {
        // Beam originating from center, extending outwards
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: beamLength, y: -beamWidth/2)) 
        path.addLine(to: CGPoint(x: beamLength, y: beamWidth/2))
        path.closeSubpath()
        
        let node = SKShapeNode(path: path)
        node.fillColor = .yellow
        node.strokeColor = .orange
        node.lineWidth = 4
        node.glowWidth = 10
        node.alpha = 0.8
        
        let corePath = CGMutablePath()
        corePath.move(to: .zero)
        corePath.addLine(to: CGPoint(x: beamLength, y: 0))
        let core = SKShapeNode(path: corePath)
        core.strokeColor = .white
        core.lineWidth = 10
        node.addChild(core)
        
        return node
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, spatialHash: SpatialHash) {
        // Ensure container follows player
        guard let container = beamContainer else { return }
        
        container.position = playerPosition
        container.zRotation += rotationSpeed * CGFloat(deltaTime)
        
        // Check collisions using spatial hash
        checkCollisions(playerPosition: playerPosition, spatialHash: spatialHash)
    }
    
    private func checkCollisions(playerPosition: CGPoint, spatialHash: SpatialHash) {
        let containerRotation = beamContainer!.zRotation
        
        // Use a conservative radius for query (beam length)
        let nearbyNodes = spatialHash.query(near: playerPosition, radius: beamLength)
        
        for node in nearbyNodes {
            guard let enemy = node as? BaseEnemy, enemy.isAlive else { continue }
            
            let toEnemy = enemy.position - playerPosition
            let dist = toEnemy.length()
            
            if dist > beamLength { continue }
            
            // Rotate enemy point into container's local space
            let localPoint = toEnemy.rotated(by: -containerRotation)
            
            for beam in beams {
                let beamRotation = beam.zRotation
                let beamLocalPoint = localPoint.rotated(by: -beamRotation)
                
                // Now check if beamLocalPoint is inside the beam rect (which extends along +X)
                if beamLocalPoint.x >= 0 && beamLocalPoint.x <= beamLength &&
                   abs(beamLocalPoint.y) <= beamWidth/2 + 20 { 
                    
                    if canHit(enemy) {
                        enemy.takeDamage(getDamage())
                        recordHit(enemy)
                    }
                    break // Hit by one beam is enough per frame
                }
            }
        }
    }
    
    // Hit throttling (copied from WhirlwindOfBlades roughly)
    private var enemyHitTimes: [ObjectIdentifier: TimeInterval] = [:]
    private let hitInterval: TimeInterval = 0.3
    
    private func canHit(_ enemy: BaseEnemy) -> Bool {
        let id = ObjectIdentifier(enemy)
        if let lastHit = enemyHitTimes[id] {
            return CACurrentMediaTime() - lastHit > hitInterval
        }
        return true
    }
    
    private func recordHit(_ enemy: BaseEnemy) {
        enemyHitTimes[ObjectIdentifier(enemy)] = CACurrentMediaTime()
    }
}

extension CGPoint {
    func rotated(by angle: CGFloat) -> CGPoint {
        let c = cos(angle)
        let s = sin(angle)
        return CGPoint(x: x * c - y * s, y: x * s + y * c)
    }
}
