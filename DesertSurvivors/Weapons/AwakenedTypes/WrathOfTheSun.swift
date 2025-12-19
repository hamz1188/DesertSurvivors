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
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
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
        // Using a path to define the shape so it rotates around the origin (player) properly
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: beamLength, y: -beamWidth/2)) // Slight cone? or Rect?
        path.addLine(to: CGPoint(x: beamLength, y: beamWidth/2))
        path.closeSubpath()
        
        let node = SKShapeNode(path: path)
        node.fillColor = .yellow
        node.strokeColor = .orange
        node.lineWidth = 4
        node.glowWidth = 10
        node.alpha = 0.8
        
        // Add core (white hot center)
        let corePath = CGMutablePath()
        corePath.move(to: .zero)
        corePath.addLine(to: CGPoint(x: beamLength, y: 0))
        let core = SKShapeNode(path: corePath)
        core.strokeColor = .white
        core.lineWidth = 10
        node.addChild(core)
        
        return node
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // Ensure container follows player
        guard let container = beamContainer else { 
            // If not created yet, do nothing (attack() will trigger creation)
            return 
        }
        
        container.position = playerPosition
        container.zRotation += rotationSpeed * CGFloat(deltaTime)
        
        // Check collisions manually since it's a "sweeping" area hazard
        checkCollisions(playerPosition: playerPosition, enemies: enemies)
    }
    
    private func checkCollisions(playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // We know the container rotation and the individual beam offsets.
        // Actually, container rotates. Beams are fixed at 0, 120, 240 degrees inside container.
        
        let containerRotation = beamContainer!.zRotation
        
        for enemy in enemies where enemy.isAlive {
            // Check if enemy is hit by any beam
            let toEnemy = enemy.position - playerPosition
            let dist = toEnemy.length()
            
            if dist > beamLength { continue } // Too far
            
            _ = atan2(toEnemy.y, toEnemy.x) // Kept for reference but unused, actually just delete logic
            // Unused logic removed
            
            // Normalize enemy angle relative to container rotation
            // Beam 1 is at 0 relative to container.
            // Beam 2 is at 2pi/3.
            // Beam 3 is at 4pi/3.
            
            // The world angle of Beam 0 is containerRotation.
            // World angle of enemy is enemyAngle.
            // Difference needs to be small (within beam width angularly).
            
            // Angular width approx: width / dist (small angle approximation)
            // But close to player, angle is large.
            // Let's use distance to line segment check for accuracy?
            // "Distance from point to line" is better.
            
            // Rotate enemy point into container's local space
            let localPoint = toEnemy.rotated(by: -containerRotation)
            
            for beam in beams {
                 // Each beam is at a fixed rotation in local space
                // Beam 0: 0 deg. Line is along +X axis.
                // Beam 1: 120 deg.
                // Beam 2: 240 deg.
                 
                let beamRotation = beam.zRotation
                // Rotate local point to be relative to THIS beam (so beam is +X)
                let beamLocalPoint = localPoint.rotated(by: -beamRotation)
                
                // Now check if beamLocalPoint is inside the beam rect (which extends along +X)
                // X: [0, beamLength]
                // Y: [-beamWidth/2, beamWidth/2]
                
                if beamLocalPoint.x >= 0 && beamLocalPoint.x <= beamLength &&
                   abs(beamLocalPoint.y) <= beamWidth/2 + 20 { // +20 for enemy radius checks roughly
                    
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
