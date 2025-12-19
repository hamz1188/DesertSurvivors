//
//  WhirlwindOfBlades.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit

class WhirlwindOfBlades: BaseWeapon {
    private var projectileNode: SKNode?
    private var rotationSpeed: CGFloat = 5.0
    private var blades: [SKShapeNode] = []
    private var radius: CGFloat = 100
    private var expandSpeed: CGFloat = 50
    private var isExpanding: Bool = true
    private var minRadius: CGFloat = 80
    private var maxRadius: CGFloat = 180
    
    init() {
        // High damage, extremely fast cooldown (continuous damage)
        super.init(name: "Whirlwind of Blades", baseDamage: 15, cooldown: 0.05)
        self.isAwakened = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Initialize if needed
        if projectileNode == nil {
            createWhirlwind()
        }
    }
    
    private func createWhirlwind() {
        guard let scene = scene else { return }
        
        let container = SKNode()
        container.zPosition = Constants.ZPosition.weapon
        scene.addChild(container)
        projectileNode = container
        
        // Create 12 blades
        let bladeCount = 12
        for _ in 0..<bladeCount {
            let blade = createBlade()
            blades.append(blade)
            container.addChild(blade)
        }
    }
    
    private func createBlade() -> SKShapeNode {
        // Evolved look: Red/Crimson blades
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 20, y: -5))
        path.addLine(to: CGPoint(x: 0, y: -25)) // Longer blade
        path.addLine(to: CGPoint(x: -8, y: -5))
        path.closeSubpath()
        
        let blade = SKShapeNode(path: path)
        blade.fillColor = .red
        blade.strokeColor = .white
        blade.lineWidth = 1.0
        blade.glowWidth = 2.0 // Glow effect
        return blade
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // Continuous update
        guard let container = projectileNode else { return }
        container.position = playerPosition
        
        // Rotate container
        container.zRotation += rotationSpeed * CGFloat(deltaTime)
        
        // Pulse radius
        if isExpanding {
            radius += expandSpeed * CGFloat(deltaTime)
            if radius >= maxRadius { isExpanding = false }
        } else {
            radius -= expandSpeed * CGFloat(deltaTime)
            if radius <= minRadius { isExpanding = true }
        }
        
        // Update blade positions
        for (i, blade) in blades.enumerated() {
            let angle = (CGFloat(i) / CGFloat(blades.count)) * 2 * .pi
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            
            blade.position = CGPoint(x: x, y: y)
            blade.zRotation = angle - .pi / 2 // Point outward
        }
        
        // Dealing damage (Optimized: check collisions manually since it's an area effect)
        checkCollisions(playerPosition: playerPosition, enemies: enemies)
    }
    
    private func checkCollisions(playerPosition: CGPoint, enemies: [BaseEnemy]) {
        // Optimization: Use squared distance locally
        let hitRadiusSq = (radius + 20) * (radius + 20)
        let innerRadiusSq = (radius - 20) * (radius - 20)
        
        for enemy in enemies where enemy.isAlive {
            let dx = enemy.position.x - playerPosition.x
            let dy = enemy.position.y - playerPosition.y
            let distSq = dx*dx + dy*dy
            
            // Check if enemy is in the ring of death
            if distSq <= hitRadiusSq && distSq >= innerRadiusSq {
                // Apply damage!
                // Since this runs every frame, we need a cooldown PER ENEMY to avoid 60 hits/sec
                // However, BaseWeapon cooldown logic handles the "attack" trigger.
                // But specifically for this continuous area weapon, we need internal throttling.
                // We'll trust the GameScene/WeaponManager loop calls update(), but we really strictly want 
                // to damage based on our internal cooldown or just damage very slightly every frame.
                // Let's go with "damage every X seconds" per enemy.
                // For simplicity in this iteration: direct damage but low amount? No, that kills too fast.
                // Let's rely on standard "projectile" logic or add a hit tracker.
                
                // Let's add a dynamic property to enemies for hit tracking? No, can't modify BaseEnemy easily dynamically.
                // Best approach: Use a local dictionary for hit timestamps.
                if canHit(enemy) {
                    enemy.takeDamage(getDamage())
                    recordHit(enemy)
                }
            }
        }
    }
    
    // Simple hit tracking integration
    private var enemyHitTimes: [ObjectIdentifier: TimeInterval] = [:]
    private let hitInterval: TimeInterval = 0.2
    
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
    
    // Cleanup dead enemies from tracker occasionally
    func cleanupHitTracker() {
        // Implementation detail: could clean up old keys if map gets too big
    }
    
    override func upgrade() {
        // Awakened weapons might have levels later, but usually they are maxed.
        // For now, no upgrades.
    }
}
