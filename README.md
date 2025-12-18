# Desert Survivors

A top-down roguelike survival game for iOS, inspired by Vampire Survivors. Fight waves of mythical Arabian creatures in an endless desert, automatically attacking enemies while moving to survive. Built with **Swift and SpriteKit**.

![iOS](https://img.shields.io/badge/iOS-26.2+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SpriteKit](https://img.shields.io/badge/SpriteKit-Enabled-green.svg)

## 🎮 Game Overview

**Desert Survivors** is an auto-attack survival game where players control a lone survivor fighting waves of enemies in an endless desert. The game features:

- **Auto-attack gameplay** - Weapons automatically target and attack nearby enemies
- **Progressive difficulty** - Enemy waves increase in intensity over time
- **Roguelike progression** - Level up and choose from random upgrades
- **Weapon evolution** - Upgrade weapons through 8 levels plus awakened forms
- **Passive items** - Collect and upgrade 16 different passive items
- **Multiple characters** - 8 unique playable characters with special abilities

## 📱 Platform

- **Target Platform:** iOS (iPhone & iPad)
- **Minimum iOS Version:** 26.2+
- **Framework:** SpriteKit
- **Language:** Swift 5.0

## 🏗️ Project Structure

```
DesertSurvivors/
├── Entities/
│   ├── Player/
│   │   ├── Player.swift
│   │   └── PlayerStats.swift
│   ├── Enemies/
│   │   ├── BaseEnemy.swift
│   │   ├── EnemySpawner.swift
│   │   └── EnemyTypes/ (4 Tier 1 enemies implemented)
│   └── Pickups/
│       └── ExperienceGem.swift
├── Weapons/
│   ├── BaseWeapon.swift
│   ├── WeaponManager.swift
│   ├── Projectile.swift
│   └── WeaponTypes/
│       ├── CurvedDagger.swift ✅
│       ├── SandBolt.swift ✅
│       ├── SunRay.swift ✅
│       └── DustDevil.swift ✅
├── Systems/
│   ├── CollisionManager.swift
│   ├── LevelUpSystem.swift
│   ├── LevelUpChoiceGenerator.swift
│   ├── PassiveItem.swift
│   ├── PassiveItemManager.swift
│   ├── PickupManager.swift
│   └── PoolingManager.swift
├── UI/
│   ├── HUD.swift
│   ├── LevelUpUI.swift
│   └── VirtualJoystick.swift
├── Utilities/
│   ├── Constants.swift
│   └── Extensions.swift
└── GameScene.swift
```

## 🎯 Development Phases

### ✅ Phase 1: Core Gameplay (COMPLETED)

**Status:** 100% Complete

All core gameplay systems have been implemented and are functional:

#### Completed Features:
- ✅ **Project Structure** - Organized folder structure with Entities, Weapons, Systems, UI, Utilities
- ✅ **Constants & Extensions** - Game configuration values and helpful Swift/SpriteKit extensions
- ✅ **Player System**
  - Player movement with physics
  - PlayerStats with all stat properties (health, speed, damage multipliers, etc.)
  - Health and damage system
- ✅ **Input Controls** - Virtual joystick for touch-based movement
- ✅ **Weapon System**
  - BaseWeapon class and WeaponManager
  - First weapon: Curved Dagger (orbiting blades)
- ✅ **Enemy System**
  - BaseEnemy class with AI (moves toward player)
  - EnemySpawner with wave spawning logic
  - 4 Tier 1 enemies: Sand Scarab, Desert Rat, Scorpion, Dust Sprite
- ✅ **Collision System** - Spatial hashing for efficient collision detection
- ✅ **Object Pooling** - Framework for pooling frequently spawned objects
- ✅ **Experience System** - ExperienceGem pickups with magnetic collection
- ✅ **Leveling System** - XP calculation and level-up logic
- ✅ **HUD** - Health bar, XP bar, level indicator, timer, kill counter

**Game Loop:** Fully functional 60 FPS game loop with player movement, enemy spawning, weapon attacks, and XP collection.

---

### 🚧 Phase 2: Content (IN PROGRESS)

**Status:** ~40% Complete

#### ✅ Completed:
- ✅ **LevelUpUI System** - Full UI with 3-4 choice selection, game pause/resume
- ✅ **Passive Items System** - All 16 passive items implemented with 5 levels each
  - Offensive: Sharpened Steel, Swift Hands, Eagle Eye, Expansive Force, Lasting Effect
  - Defensive: Desert Armor, Oasis Heart, Second Wind, Mirage Step
  - Utility: Magnetic Charm, Fortune's Favor, Scholar's Mind, Merchant's Eye
  - Evolution Items: Sandstorm Cloak, Djinn Lamp, Scarab Amulet, Venom Vial, Mirror of Truth, Eagle Feather, Desert Rose, Canopic Jar, Hourglass
- ✅ **PassiveItemManager** - Tracks and applies passive effects to player stats
- ✅ **LevelUpChoiceGenerator** - Generates random level-up choices (weapons, passives, gold, health)
- ✅ **4 Weapons Implemented** (4/12):
  - ✅ Curved Dagger (Orbit) - Spinning blades orbit player
  - ✅ Sand Bolt (Projectile) - Fires projectiles at nearest enemy
  - ✅ Sun Ray (Beam) - Fires beam toward nearest enemy
  - ✅ Dust Devil (Area) - Creates damaging whirlwinds

#### 🚧 In Progress:
- 🚧 **More Weapons** (4/12 complete, 8 remaining):
  - ⏳ Scorpion Tail (Whip)
  - ⏳ Mirage Clone (Summon)
  - ⏳ Oil Flask (Thrown)
  - ⏳ Desert Eagle/Falcon (Homing)
  - ⏳ Sandstorm Shield (Defensive)
  - ⏳ Ancient Curse (Debuff)
  - ⏳ Quicksand (Trap)
  - ⏳ Djinn's Flame (Magic)

#### ⏳ Pending:
- ⏳ **Weapon Evolution System** - 8 levels per weapon with stat improvements
- ⏳ **Weapon Awakening System** - Final forms requiring specific passive items
- ⏳ **Additional Enemy Tiers**:
  - ⏳ Tier 2 (4 enemies): Mummified Wanderer, Sand Cobra, Desert Bandit, Cursed Jackal
  - ⏳ Tier 3 (4 enemies): Animated Statue, Sand Elemental, Tomb Guardian, Ghoul
  - ⏳ Tier 4 (4 enemies): Mummy Lord, Lamia, Bone Colossus, Sandstorm Djinn
  - ⏳ Tier 5 Mini-Bosses (4): The Defiler, Pharaoh's Shadow, The Simoom, Brass Automaton
  - ⏳ Final Boss: Apophis the Devourer
- ⏳ **Enhanced Enemy AI** - Unique behaviors per enemy type
- ⏳ **WaveManager** - Advanced spawn patterns (directional waves, encirclement, swarms)
- ⏳ **DifficultyManager** - Progressive difficulty scaling
- ⏳ **Additional Pickups**:
  - ⏳ HealthPickup
  - ⏳ GoldCoin
  - ⏳ Chest
- ⏳ **Character System** (0/8):
  - ⏳ Tariq the Wanderer (Starting)
  - ⏳ Layla the Sandmage
  - ⏳ Hassan the Trader
  - ⏳ Fatima the Healer
  - ⏳ Rashid the Warrior
  - ⏳ Nadia the Assassin
  - ⏳ Khalid the Djinn-Touched
  - ⏳ Mariam the Outcast (Secret)
- ⏳ **UI Scenes**:
  - ⏳ MainMenuScene
  - ⏳ CharacterSelectScene
  - ⏳ PauseMenuScene
  - ⏳ GameOverScene

---

### ⏳ Phase 3: Polish (PENDING)

**Status:** 0% Complete

#### Planned Features:
- ⏳ **Meta Progression** - Gold spending, permanent stat upgrades
- ⏳ **Save System** - Persistent data storage (gold, unlocks, achievements)
- ⏳ **UnlockManager** - Character, weapon, and stage unlocks
- ⏳ **Achievement System** - Achievement tracking and rewards
- ⏳ **Audio Manager** - Music and sound effects
- ⏳ **Visual Effects** - Particle effects, screen shake, visual feedback
- ⏳ **Damage Numbers** - Floating damage numbers with pooling
- ⏳ **Minimap** - Optional minimap view
- ⏳ **Stats Display** - Detailed player stats screen

---

### ⏳ Phase 4: Expansion (PENDING)

**Status:** 0% Complete

#### Planned Features:
- ⏳ **Arcana System** - 10+ modifier cards that change gameplay rules
- ⏳ **Additional Stages**:
  - ⏳ Tomb of the Pharaohs
  - ⏳ The Burning Wastes
  - ⏳ The Lost Oasis
  - ⏳ The Void Between
- ⏳ **Environmental Events** - Sandstorms, solar eclipses, mirages
- ⏳ **Map Features** - Oases, ruins, quicksand patches, obstacles
- ⏳ **Performance Optimization** - Profiling and optimization for 500+ enemies at 60 FPS
- ⏳ **Game Balancing** - Weapon, enemy, and progression curve balancing
- ⏳ **Gamepad Support** - GCController support (optional)
- ⏳ **Settings Menu** - Audio, controls, visual options

---

## 🎮 Current Gameplay Features

### Working Systems:
1. **Player Movement** - Virtual joystick controls, smooth movement
2. **Enemy Spawning** - Progressive difficulty, spawns off-screen
3. **Weapon Attacks** - 4 different weapon types with unique behaviors
4. **Experience Collection** - Gems drop from enemies and magnetically collect
5. **Leveling System** - Gain XP, level up, choose from 3-4 random upgrades
6. **Passive Items** - 16 passive items with stacking effects
7. **HUD Display** - Health, XP, level, timer, kill count
8. **Game Pause** - Automatically pauses during level-up selection

### Weapon Types Available:
- **Curved Dagger** - Orbits player, damages enemies on contact
- **Sand Bolt** - Projectile weapon targeting nearest enemy
- **Sun Ray** - Beam weapon with area damage
- **Dust Devil** - Area effect creating damaging whirlwinds

### Enemy Types Available:
- **Sand Scarab** - Basic swarmer (20 HP, 120 speed)
- **Desert Rat** - Fast, low HP (10 HP, 180 speed)
- **Scorpion** - Slow, tanky (30 HP, 80 speed)
- **Dust Sprite** - Floating, ranged (15 HP, 100 speed)

---

## 🛠️ Technical Details

### Performance Targets:
- **Target FPS:** 60 FPS
- **Max Enemies:** 500+ on screen simultaneously
- **Optimization Techniques:**
  - Object pooling for frequently spawned objects
  - Spatial hashing for collision detection
  - Texture atlases (planned)
  - Batch rendering (planned)
  - Off-screen culling (planned)

### Architecture:
- **Pattern:** Component-based with managers
- **Collision:** Spatial hashing for O(1) lookups
- **State Management:** NotificationCenter for events
- **Memory:** Object pooling to reduce allocations

---

## 📊 Progress Summary

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Core Gameplay | ✅ Complete | 100% |
| Phase 2: Content | 🚧 In Progress | ~40% |
| Phase 3: Polish | ⏳ Pending | 0% |
| Phase 4: Expansion | ⏳ Pending | 0% |

**Overall Project Completion:** ~35%

---

## 🚀 Getting Started

### Prerequisites:
- Xcode 26.2 or later
- iOS 26.2+ SDK
- Swift 5.0+

### Building:
1. Clone the repository
2. Open `DesertSurvivors.xcodeproj` in Xcode
3. Select a simulator or device
4. Build and run (⌘R)

### Controls:
- **Left side of screen** - Virtual joystick for movement
- **Tap level-up choices** - Select upgrades when leveling up

---

## 🐛 Known Issues

- Placeholder sprites (colored shapes) - Need actual artwork
- No sound effects or music yet
- Weapon evolution not fully implemented (upgrades work but visual feedback limited)
- Some passive item effects need implementation (dodge, lifesteal, critical hits)

---

## 📝 Design Document

Full game design specifications are available in `desert-survivors-game-prompt.md`.

---

## 👥 Credits

**Developer:** Ahmed AlHameli  
**Game Design:** Based on Vampire Survivors gameplay loop  
**Framework:** Apple SpriteKit

---

## 📄 License

[Add your license here]

---

## 🔮 Roadmap

### Short Term (Next Steps):
1. Complete remaining 8 weapons
2. Implement weapon evolution system
3. Add more enemy tiers
4. Create UI scenes (main menu, pause, game over)

### Medium Term:
1. Character system with 8 playable characters
2. Meta progression and save system
3. Audio implementation
4. Visual effects and polish

### Long Term:
1. Additional stages
2. Arcana system
3. Performance optimization
4. Full game balancing

---

**Last Updated:** December 18, 2025  
**Current Version:** Phase 2 (In Progress)

