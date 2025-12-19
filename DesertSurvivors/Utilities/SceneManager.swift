//
//  SceneManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import SpriteKit

class SceneManager {
    static let shared = SceneManager()
    
    private var gameViewController: GameViewController?
    
    // Config
    private let transitionDuration: TimeInterval = 0.5
    
    private init() {}
    
    func setGameViewController(_ controller: GameViewController) {
        self.gameViewController = controller
    }
    
    func presentMainMenu() {
        guard let view = gameViewController?.view as? SKView else { return }
        let scene = MainMenuScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.crossFade(withDuration: transitionDuration)
        view.presentScene(scene, transition: transition)
    }
    
    func presentGameScene() {
        guard let view = gameViewController?.view as? SKView else { return }
        
        // Load GameScene from SKS file if possible, or create programmatically
        if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
            scene.scaleMode = .aspectFill
            let transition = SKTransition.doorsOpenHorizontal(withDuration: transitionDuration)
            view.presentScene(scene, transition: transition)
        } else {
             // Fallback
            let scene = GameScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            let transition = SKTransition.doorsOpenHorizontal(withDuration: transitionDuration)
            view.presentScene(scene, transition: transition)
        }
    }
    
    func presentGameOver(finalLevel: Int, kills: Int, timeSurvived: String) {
        guard let view = gameViewController?.view as? SKView else { return }
        let scene = GameOverScene(size: view.bounds.size, level: finalLevel, kills: kills, time: timeSurvived)
        scene.scaleMode = .aspectFill
        let transition = SKTransition.fade(with: .black, duration: 1.0)
        view.presentScene(scene, transition: transition)
    }
}
