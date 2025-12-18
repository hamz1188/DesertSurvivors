//
//  CurvedDagger.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class CurvedDagger: BaseWeapon {
    private var daggers: [SKSpriteNode] = []
    private var orbitRadius: CGFloat = 60
    private var orbitSpeed: CGFloat = 3.0 // radians per second
    private var currentAngle: CGFloat = 0
    
    init() {
        super.init(name: "Curved Dagger", baseDamage: 10, cooldown: 1.5)
        setupDaggers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDaggers() {
        // Start with 1 dagger, more will be added on level up
        createDagger()
    }
    
    private func createDagger() {
        let dagger = SKSpriteNode(color: .orange, size: CGSize(width: 20, height: 8))
        dagger.zPosition = Constants.ZPosition.weapon
        daggers.append(dagger)
        addChild(dagger)
    }
    
    override func update(deltaTime: TimeInterval, playerPosition: CGPoint, enemies: [BaseEnemy]) {
        super.update(deltaTime: deltaTime, playerPosition: playerPosition, enemies: enemies)
        
        // Update orbit
        currentAngle += orbitSpeed * CGFloat(deltaTime)
        
        // Update dagger positions
        let daggerCount = daggers.count
        for (index, dagger) in daggers.enumerated() {
            let angle = currentAngle + (CGFloat(index) * 2 * .pi / CGFloat(daggerCount))
            let x = cos(angle) * orbitRadius
            let y = sin(angle) * orbitRadius
            dagger.position = CGPoint(x: x, y: y)
            dagger.zRotation = angle + .pi / 2
            
            // Check collision with enemies
            checkDaggerCollision(dagger: dagger, enemies: enemies)
        }
    }
    
    private func checkDaggerCollision(dagger: SKSpriteNode, enemies: [BaseEnemy]) {
        guard let scene = scene else { return }
        let worldPosition = convert(dagger.position, to: scene)
        
        for enemy in enemies {
            if worldPosition.distance(to: enemy.position) < 30 {
                enemy.takeDamage(getDamage())
                // Could add visual feedback here
            }
        }
    }
    
    override func upgrade() {
        super.upgrade()
        
        // Add more daggers and increase orbit radius
        if level <= 4 {
            createDagger()
        }
        
        orbitRadius = 60 + CGFloat(level - 1) * 10
        orbitSpeed = 3.0 + CGFloat(level - 1) * 0.5
    }
    
    override func attack(playerPosition: CGPoint, enemies: [BaseEnemy], deltaTime: TimeInterval) {
        // Daggers orbit continuously, collision is checked in update
    }
}

