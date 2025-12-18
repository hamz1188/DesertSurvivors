//
//  VirtualJoystick.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class VirtualJoystick: SKNode {
    private var baseCircle: SKShapeNode!
    private var stickCircle: SKShapeNode!
    private var isActive: Bool = false
    private var baseRadius: CGFloat = 50
    private var stickRadius: CGFloat = 25
    private var maxDistance: CGFloat = 35
    
    var direction: CGPoint = .zero
    
    override init() {
        super.init()
        setupJoystick()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupJoystick() {
        // Base circle
        baseCircle = SKShapeNode(circleOfRadius: baseRadius)
        baseCircle.fillColor = SKColor(white: 0.3, alpha: 0.5)
        baseCircle.strokeColor = SKColor(white: 0.5, alpha: 0.8)
        baseCircle.lineWidth = 2
        addChild(baseCircle)
        
        // Stick circle
        stickCircle = SKShapeNode(circleOfRadius: stickRadius)
        stickCircle.fillColor = SKColor(white: 0.6, alpha: 0.7)
        stickCircle.strokeColor = SKColor(white: 0.8, alpha: 1.0)
        stickCircle.lineWidth = 2
        addChild(stickCircle)
        
        isHidden = true
    }
    
    func activate(at position: CGPoint) {
        self.position = position
        isActive = true
        isHidden = false
        updateStickPosition(position)
    }
    
    func updateStickPosition(_ touchPosition: CGPoint) {
        guard isActive else { return }
        
        let localTouch = touchPosition - position
        let distance = localTouch.length()
        
        if distance > maxDistance {
            let normalized = localTouch.normalized()
            stickCircle.position = normalized * maxDistance
            direction = normalized
        } else {
            stickCircle.position = localTouch
            direction = localTouch.normalized()
        }
    }
    
    func deactivate() {
        isActive = false
        isHidden = true
        stickCircle.position = .zero
        direction = .zero
    }
}

