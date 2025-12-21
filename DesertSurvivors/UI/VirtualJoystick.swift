//
//  VirtualJoystick.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class VirtualJoystick: SKNode {
    private var baseCircle: SKShapeNode?
    private var stickCircle: SKShapeNode?
    private var isActive: Bool = false
    private var baseRadius: CGFloat = 50
    private var stickRadius: CGFloat = 25
    private var maxDistance: CGFloat = 35
    
    var direction: CGPoint = .zero
    
    private var trackingTouch: UITouch?
    
    override init() {
        super.init()
        setupJoystick()
        isUserInteractionEnabled = false // Touches are delegated from GameScene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupJoystick() {
        // Base circle
        let newBaseCircle = SKShapeNode(circleOfRadius: baseRadius)
        newBaseCircle.fillColor = SKColor(white: 0.3, alpha: 0.8) // Increased opacity
        newBaseCircle.strokeColor = SKColor(white: 0.5, alpha: 1.0)
        newBaseCircle.lineWidth = 2
        baseCircle = newBaseCircle
        addChild(newBaseCircle)

        // Stick circle
        let newStickCircle = SKShapeNode(circleOfRadius: stickRadius)
        newStickCircle.fillColor = SKColor(white: 0.6, alpha: 0.9) // Increased opacity
        newStickCircle.strokeColor = SKColor(white: 0.8, alpha: 1.0)
        newStickCircle.lineWidth = 2
        stickCircle = newStickCircle
        addChild(newStickCircle)

        // Secretly hidden by default (Floating Mode)
        isHidden = true
        isActive = false
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If already tracking, ignore new touches
        guard trackingTouch == nil else { return }
        
        for touch in touches {
            // In a floating joystick, we accept the touch if it's anywhere in the permissible area (usually left half of screen)
            // For simplicity, we'll accept any touch on the camera node/screen that isn't a button.
            // Since GameScene delegates touches, we can assume valid touches are passed.
            
            // Move joystick base to touch position!
            // Note: Touch is in parent's coordinate system (Camera).
            // We need to set OUR position to that location.
            // BUT touchesBegan passes the touch object. getting location(in: parent) is safest?
            // "self" is the joystick node.
            
            guard let parent = parent else { return }
            let locationInParent = touch.location(in: parent)
            
            // Restrict to left half of screen if feasible? For now, anywhere is fine as requested.
            
            self.position = locationInParent
            self.isHidden = false
            self.alpha = 1.0 // Ensure full visibility
            
            trackingTouch = touch
            isActive = true
            stickCircle?.position = .zero // Reset stick to center of base
            return
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        
        let location = touch.location(in: self)
        updateStickPosition(location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        reset()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackingTouch, touches.contains(touch) else { return }
        reset()
    }
    
    private func updateStickPosition(_ location: CGPoint) {
        // Limit stick movement to maxDistance
        let distance = location.length()

        if distance > maxDistance {
            let normalized = location.normalized()
            stickCircle?.position = normalized * maxDistance
            direction = normalized
        } else {
            stickCircle?.position = location
            // If distance is very small (deadzone), zero out direction
            if distance < 5 {
                direction = .zero
            } else {
                direction = location.normalized()
            }
        }
    }
    
    private func reset() {
        trackingTouch = nil
        isActive = false
        isHidden = true // Hide when released
        stickCircle?.position = .zero
        direction = .zero
    }

}
