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
│   │   └── EnemyTypes/
│   │       ├── Tier 1 (Common): Sand Scarab, Desert Rat, Scorpion, Dust Sprite
│   │       └── Tier 2 (Uncommon): Mummified Wanderer, Sand Cobra, Desert Bandit, Cursed Jackal
│   └── Pickups/
│       └── ExperienceGem.swift
├── Weapons/
│   ├── BaseWeapon.swift
│   ├── WeaponManager.swift
│   ├── Projectile.swift ✅ (Base class for projectile weapons)
│   └── WeaponTypes/
│       ├── CurvedDagger.swift ✅
│       ├── SandBolt.swift ✅
│       ├── SunRay.swift ✅
│       ├── DustDevil.swift ✅
│       ├── ScorpionTail.swift ✅
│       └── SandstormShield.swift ✅
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
│   ├── PauseMenuUI.swift ✅
│   └── VirtualJoystick.swift
├── Utilities/
│   ├── Constants.swift
│   ├── SceneManager.swift ✅ (Handles transitions)
│   └── Extensions.swift
├── Scenes/
│   ├── MainMenuScene.swift ✅
│   ├── CharacterSelectionScene.swift ✅
│   └── GameOverScene.swift ✅
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
- ✅ **Input Controls** - Virtual joystick for touch-based movement (with robust touch tracking)
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
- ✅ **HUD** - Health bar, XP bar, level indicator, timer, kill counter (Dynamic Island compatible)

**Game Loop:** Fully functional 60 FPS game loop with player movement, enemy spawning, weapon attacks, and XP collection.

### ✅ Phase 2: Content Expansion (COMPLETED)

**Status:** 100% Complete

Expanding the game content with more enemies, weapons, and systems.

#### Completed Features:
- ✅ **Tier 2 Enemies**
  - **Mummified Wanderer**: Slow, high HP tank
  - **Sand Cobra**: Fast, lunging attacker
  - **Desert Bandit**: Ranged/retreating behavior
  - **Cursed Jackal**: Pack buffer
- ✅ **UI Scenes**
  - **Character Selection**: Scene flow allowing character choice (currently Tariq)
  - **Pause Menu**: In-game overlay with Resume/Quit functionality
  - **Scene Management**: Robust transition system (MainMenu -> CharSelect -> Game -> GameOver)
  - **HUD Polish**: Dynamic Island support, Pause button, improved layout
- ✅ **Weapon Awakening**
  - **System**: AwakeningManager handling evolution recipes (Level 8 Weapon + Max Passive)
  - **Implemented Evolutions (12/12)**:
    - **Whirlwind of Blades** (Curved Dagger + Sandstorm Cloak)
    - **Desert Storm** (Sand Bolt + Djinn Lamp)
    - **Emperor Scorpion** (Scorpion Tail + Venom Vial)
    - **Wrath of the Sun** (Sun Ray + Scarab Amulet)
    - **Haboob** (Dust Devil + Sandstorm Cloak)
    - **Army of Mirages** (Mirage Clone + Mirror of Truth)
    - **Greek Fire** (Oil Flask + Djinn Lamp)
    - **Roc's Descendant** (Desert Eagle + Eagle Feather)
    - **Eye of the Storm** (Sandstorm Shield + Desert Rose)
    - **Pharaoh's Wrath** (Ancient Curse + Canopic Jar)
    - **Devouring Sands** (Quicksand + Hourglass)
    - **Ifrit's Embrace** (Djinn's Flame + Djinn Lamp)

### 🔮 Phase 3: Visual & Audio Polish (PLANNED)

**Status:** 0% Complete

Refining the visuals and adding audio to create a premium feel.

#### Planned Features:
- [ ] **Visual Overhaul**: Replace placeholder geometry with pixel art or enhanced shader-based assets
- [ ] **Sound Effects**: Attack, hit, level up, and UI sounds
- [ ] **Background Music**: Dynamic desert-themed tracks
- [ ] **VFX**: Particle systems for attacks, weather effects (sandstorms), and destruction

### 🚀 Phase 4: Meta-Progression (PLANNED)

**Status:** 0% Complete

Adding persistent progression and polish.

#### Planned Features:
- [ ] **Save Data System** - Persist gold, unlocked achievements, and characters
- [ ] **Shop / Upgrades** - Spend gold to buy permanent stat boosts
- [ ] **Achievements** - Unlock new weapons/characters by completing tasks
- [ ] **Character Selection** - Choose from different characters with unique stats
- [ ] **Sound & Music** - Sound effects for actions and background music
- [ ] **Settings Menu** - Toggle sound, music, and vibration
