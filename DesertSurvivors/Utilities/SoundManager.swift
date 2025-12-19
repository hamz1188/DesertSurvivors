//
//  SoundManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var isMusicEnabled: Bool = true
    private var isSFXEnabled: Bool = true
    
    private init() {}
    
    // MARK: - Music
    
    func playBackgroundMusic(filename: String) {
        guard isMusicEnabled else { return }
        
        // Stop current music if any
        if backgroundMusicPlayer != nil && backgroundMusicPlayer!.isPlaying {
            backgroundMusicPlayer?.stop()
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("SoundManager: Music file \(filename) not found.")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.5
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("SoundManager: Could not play music file \(filename). Error: \(error)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func toggleMusic() -> Bool {
        isMusicEnabled.toggle()
        if isMusicEnabled {
            backgroundMusicPlayer?.play()
        } else {
            backgroundMusicPlayer?.pause()
        }
        return isMusicEnabled
    }
    
    // MARK: - Sound Effects
    
    func playSFX(filename: String, scene: SKScene?) {
        guard isSFXEnabled else { return }
        
        // SKAction.playSoundFileNamed is fire-and-forget and handled by SpriteKit.
        // It generally warns if file missing but safely continues.
        // However, we can pre-check strictly if we want to avoid console noise,
        // but `Bundle.main.url` check is sufficient.
        
        // Note: filename should include extension, e.g. "hit.wav"
        
        // We verify existence to avoid log spam
        if Bundle.main.url(forResource: filename, withExtension: nil) == nil {
            // print("SoundManager: SFX file \(filename) not found.") // Commented out to avoid spamming console
            return
        }
        
        if let scene = scene {
            scene.run(SKAction.playSoundFileNamed(filename, waitForCompletion: false))
        }
    }
    
    func toggleSFX() -> Bool {
        isSFXEnabled.toggle()
        return isSFXEnabled
    }
}
