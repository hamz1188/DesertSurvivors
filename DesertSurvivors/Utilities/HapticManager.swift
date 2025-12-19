//
//  HapticManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    // Config
    var isHapticsEnabled: Bool {
        get { return UserDefaults.standard.object(forKey: "isHapticsEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "isHapticsEnabled") }
    }
    
    private init() {}
    
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        guard isHapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}
