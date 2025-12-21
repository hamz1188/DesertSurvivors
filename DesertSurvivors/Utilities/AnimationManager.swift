//
//  AnimationManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 21/12/2025.
//

import SpriteKit

/// Centralized animation manager for loading and caching sprite animations.
/// Supports frame-based animations for characters and enemies.
class AnimationManager {
    static let shared = AnimationManager()
    
    private var cachedAnimations: [String: [SKTexture]] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Load an animation by name with a specified frame count.
    /// Follows naming convention: {name}-{NNN}.png (e.g., "Tariq-walking-south-000")
    /// - Parameters:
    ///   - name: Base name of the animation (e.g., "Tariq-walking-south")
    ///   - frameCount: Number of frames to load
    /// - Returns: Array of textures for the animation
    func loadAnimation(name: String, frameCount: Int) -> [SKTexture] {
        let cacheKey = "\(name)_\(frameCount)"
        
        lock.lock()
        if let cached = cachedAnimations[cacheKey] {
            lock.unlock()
            return cached
        }
        lock.unlock()
        
        var frames: [SKTexture] = []
        for i in 0..<frameCount {
            let frameName = "\(name)-\(String(format: "%03d", i))"
            let texture = SKTexture(imageNamed: frameName)
            
            // Check if texture loaded (has valid size)
            if texture.size().width > 0 && texture.size().height > 0 {
                texture.filteringMode = .nearest // Pixel art crisp scaling
                frames.append(texture)
            }
        }
        
        // Only cache if we got frames
        if !frames.isEmpty {
            lock.lock()
            cachedAnimations[cacheKey] = frames
            lock.unlock()
        }
        
        return frames
    }
    
    /// Load all 8-directional walking animations for a character.
    /// - Parameters:
    ///   - characterName: Name of the character (e.g., "Tariq", "Amara", "Zahra")
    ///   - frameCount: Number of frames per direction (default 6)
    /// - Returns: Dictionary mapping direction to animation frames
    func loadWalkAnimations(characterName: String, frameCount: Int = 6) -> [Player.Direction: [SKTexture]] {
        var animations: [Player.Direction: [SKTexture]] = [:]
        
        for direction in Player.Direction.allCases {
            let animName = "\(characterName)-walking-\(direction.rawValue)"
            let frames = loadAnimation(name: animName, frameCount: frameCount)
            
            if !frames.isEmpty {
                animations[direction] = frames
            }
        }
        
        return animations
    }
    
    /// Create an animation action from textures.
    /// - Parameters:
    ///   - textures: Animation frames
    ///   - timePerFrame: Duration for each frame (default 0.1s)
    ///   - repeating: Whether to loop the animation
    /// - Returns: SKAction for the animation
    func createAnimateAction(textures: [SKTexture], timePerFrame: TimeInterval = 0.1, repeating: Bool = true) -> SKAction {
        let animate = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        return repeating ? SKAction.repeatForever(animate) : animate
    }
    
    /// Preload animations for a character (call during loading screen).
    /// - Parameter characterName: Character name to preload
    func preloadCharacter(_ characterName: String) {
        // Preload idle directions
        for direction in Player.Direction.allCases {
            let textureName = direction == .south ? characterName : "\(characterName)-\(direction.rawValue)"
            let texture = SKTexture(imageNamed: textureName)
            texture.filteringMode = .nearest
            // Force load by accessing size
            _ = texture.size()
        }
        
        // Preload walk animations
        _ = loadWalkAnimations(characterName: characterName)
    }
    
    /// Clear all cached animations (call on memory warning).
    func clearCache() {
        lock.lock()
        cachedAnimations.removeAll()
        lock.unlock()
    }
    
    /// Get cache count for debugging.
    var cacheCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return cachedAnimations.count
    }
}
