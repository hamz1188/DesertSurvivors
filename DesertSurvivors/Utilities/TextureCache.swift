//
//  TextureCache.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 21/12/2025.
//

import SpriteKit
import os.log

private let logger = Logger(subsystem: "com.desertsurvivors", category: "TextureCache")

/// A centralized texture cache for improved loading performance and memory management.
/// Caches textures lazily and applies pixel art filtering mode automatically.
class TextureCache {
    static let shared = TextureCache()
    
    private var textures: [String: SKTexture] = [:]
    private let lock = NSLock()
    
    private init() {}
    
    // MARK: - Public API
    
    /// Get a cached texture by name. Creates and caches if not already loaded.
    /// - Parameter name: The image name (without extension, same as imageNamed:)
    /// - Returns: The cached texture, or nil if image doesn't exist
    func texture(named name: String) -> SKTexture? {
        lock.lock()
        defer { lock.unlock() }
        
        if let cached = textures[name] {
            return cached
        }
        
        let texture = SKTexture(imageNamed: name)
        
        // Check if texture loaded successfully
        if texture.size() == .zero {
            return nil
        }
        
        // Apply pixel art filtering for crisp scaling
        texture.filteringMode = .nearest
        
        textures[name] = texture
        return texture
    }
    
    /// Preload multiple textures at once (e.g., during loading screen)
    /// - Parameters:
    ///   - names: Array of texture names to preload
    ///   - completion: Called when all textures are loaded
    func preload(names: [String], completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for name in names {
            group.enter()
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                _ = self?.texture(named: name)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    /// Preload textures from a texture atlas
    /// - Parameters:
    ///   - atlasName: Name of the texture atlas
    ///   - completion: Called when atlas is preloaded
    func preloadAtlas(named atlasName: String, completion: @escaping () -> Void) {
        let atlas = SKTextureAtlas(named: atlasName)
        
        atlas.preload { [weak self] in
            // Cache all textures from atlas
            for textureName in atlas.textureNames {
                let texture = atlas.textureNamed(textureName)
                texture.filteringMode = .nearest
                
                self?.lock.lock()
                self?.textures[textureName] = texture
                self?.lock.unlock()
            }
            completion()
        }
    }
    
    /// Clear all cached textures (e.g., on memory warning)
    func clearCache() {
        lock.lock()
        textures.removeAll()
        lock.unlock()
    }
    
    /// Get the number of cached textures
    var cacheCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return textures.count
    }
    
    // MARK: - Convenience Methods
    
    /// Create a sprite node using a cached texture
    /// - Parameter name: The texture name
    /// - Returns: SKSpriteNode with the cached texture, or a colored placeholder if texture not found
    func sprite(named name: String, fallbackColor: SKColor = .magenta, fallbackSize: CGSize = CGSize(width: 32, height: 32)) -> SKSpriteNode {
        if let texture = texture(named: name) {
            return SKSpriteNode(texture: texture)
        } else {
            // Return a visible placeholder for debugging
            let placeholder = SKSpriteNode(color: fallbackColor, size: fallbackSize)
            logger.debug("Missing texture '\(name)'")
            return placeholder
        }
    }
}
