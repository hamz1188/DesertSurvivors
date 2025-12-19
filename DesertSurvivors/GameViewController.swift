//
//  GameViewController.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 18/12/2025.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize SceneManager
        SceneManager.shared.setGameViewController(self)
        
        // Present Main Menu
        SceneManager.shared.presentMainMenu()
        
        if let skView = self.view as? SKView {
            skView.ignoresSiblingOrder = true
            skView.showsFPS = false
            skView.showsNodeCount = false
        }
    }
    
    // Suppress UIKit focus warnings for SpriteKit views
    // Focus system is primarily for tvOS/accessibility, not needed for iOS touch games
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return []
    }
    
    override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
