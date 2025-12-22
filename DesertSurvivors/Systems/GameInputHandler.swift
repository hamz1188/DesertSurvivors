//
//  GameInputHandler.swift
//  DesertSurvivors
//
//  Handles touch input for the game scene, delegating to appropriate UI components.
//

import SpriteKit

protocol GameInputHandlerDelegate: AnyObject {
    func inputHandlerDidRequestPause()
    func inputHandlerDidSelectLevelUpChoice(at location: CGPoint) -> Bool
}

class GameInputHandler {
    weak var delegate: GameInputHandlerDelegate?
    weak var joystick: VirtualJoystick?
    weak var levelUpUI: LevelUpUI?
    weak var camera: SKCameraNode?

    private var isGamePaused: Bool = false

    init(joystick: VirtualJoystick?, levelUpUI: LevelUpUI?, camera: SKCameraNode?) {
        self.joystick = joystick
        self.levelUpUI = levelUpUI
        self.camera = camera
    }

    func setGamePaused(_ paused: Bool) {
        isGamePaused = paused
    }

    func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let camera = camera else { return }

        for touch in touches {
            let location = touch.location(in: camera)

            // Check level-up UI first
            if let levelUpUI = levelUpUI, levelUpUI.isVisible {
                if levelUpUI.handleTouch(at: location) { return }
            }

            // Check pause button
            let nodes = camera.nodes(at: location)
            for node in nodes {
                if node.name == "pauseButton" || node.parent?.name == "pauseButton" {
                    delegate?.inputHandlerDidRequestPause()
                    return
                }
            }
        }

        // Forward to joystick if not paused
        guard !isGamePaused else { return }
        joystick?.touchesBegan(touches, with: event)
    }

    func handleTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGamePaused else { return }
        joystick?.touchesMoved(touches, with: event)
    }

    func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.touchesEnded(touches, with: event)
    }

    func handleTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick?.touchesCancelled(touches, with: event)
    }
}
