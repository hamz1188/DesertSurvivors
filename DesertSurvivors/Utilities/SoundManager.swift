//
//  SoundManager.swift
//  DesertSurvivors
//
//  Created by Ahmed AlHameli on 19/12/2025.
//

import SpriteKit
import AVFoundation
import os.log

private let logger = Logger(subsystem: "com.desertsurvivors", category: "SoundManager")

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    var isMusicEnabled: Bool {
        get { return UserDefaults.standard.object(forKey: "isMusicEnabled") as? Bool ?? true }
        set {
            UserDefaults.standard.set(newValue, forKey: "isMusicEnabled")
            if !newValue {
                backgroundMusicPlayer?.pause()
            } else {
                backgroundMusicPlayer?.play()
            }
        }
    }
    
    var isSFXEnabled: Bool {
        get { return UserDefaults.standard.object(forKey: "isSFXEnabled") as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "isSFXEnabled") }
    }
    
    private init() {}
    
    // MARK: - Music
    
    func playBackgroundMusic(filename: String) {
        guard isMusicEnabled else { return }
        
        // Stop current music if any
        if backgroundMusicPlayer != nil && backgroundMusicPlayer!.isPlaying {
            backgroundMusicPlayer?.stop()
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            logger.warning("Music file \(filename) not found")
            return
        }
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = 0.5
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            logger.error("Could not play music file \(filename): \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    func cleanup() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
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
        
        if Bundle.main.url(forResource: filename, withExtension: nil) == nil {
            logger.debug("SFX file \(filename) not found")
            return
        }
        
        scene?.run(SKAction.playSoundFileNamed(filename, waitForCompletion: false))
    }
    
    func toggleSFX() -> Bool {
        isSFXEnabled.toggle()
        return isSFXEnabled
    }
}
