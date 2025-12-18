# Desert Survivors - Complete Game Development Prompt

## Game Overview

Build a top-down roguelike survival game called "Desert Survivors" inspired by Vampire Survivors. The player controls a lone survivor in an endless desert, fighting waves of mythical Arabian creatures and supernatural desert threats. The game should be built using **Swift with SpriteKit** for iOS, targeting iPhone and iPad.

---

## Core Gameplay Loop

The player automatically attacks nearby enemies while moving to survive. Enemies spawn in waves with increasing difficulty. Defeating enemies drops experience gems. Leveling up offers a choice of weapon upgrades or new abilities. Survive as long as possible while becoming increasingly powerful.

---

## Technical Architecture

### Project Structure

```
DesertSurvivors/
├── App/
│   ├── DesertSurvivorsApp.swift
│   └── AppDelegate.swift
├── Scenes/
│   ├── GameScene.swift
│   ├── MainMenuScene.swift
│   ├── PauseMenuScene.swift
│   ├── GameOverScene.swift
│   └── CharacterSelectScene.swift
├── Entities/
│   ├── Player/
│   │   ├── Player.swift
│   │   ├── PlayerStats.swift
│   │   └── Characters/ (individual character classes)
│   ├── Enemies/
│   │   ├── BaseEnemy.swift
│   │   ├── EnemySpawner.swift
│   │   └── EnemyTypes/ (individual enemy classes)
│   └── Pickups/
│       ├── ExperienceGem.swift
│       ├── HealthPickup.swift
│       ├── Chest.swift
│       └── GoldCoin.swift
├── Weapons/
│   ├── BaseWeapon.swift
│   ├── WeaponManager.swift
│   └── WeaponTypes/ (individual weapon classes)
├── Systems/
│   ├── WaveManager.swift
│   ├── DifficultyManager.swift
│   ├── LevelUpSystem.swift
│   ├── CollisionManager.swift
│   └── PoolingManager.swift
├── UI/
│   ├── HUD.swift
│   ├── LevelUpUI.swift
│   ├── StatsDisplay.swift
│   └── MinimapView.swift
├── Data/
│   ├── GameData.swift
│   ├── SaveManager.swift
│   ├── UnlockManager.swift
│   └── AchievementManager.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── AudioManager.swift
└── Resources/
    ├── Assets.xcassets
    ├── Sounds/
    └── Particles/
```

### Performance Requirements

- Maintain 60 FPS with 500+ enemies on screen
- Use object pooling for all frequently spawned objects (enemies, projectiles, gems, damage numbers)
- Implement spatial hashing or quadtree for efficient collision detection
- Use texture atlases for all sprites
- Batch render similar sprites
- Implement culling for off-screen entities

---

## Player System

### Base Player Stats

```swift
struct PlayerStats {
    var maxHealth: Float = 100
    var currentHealth: Float = 100
    var moveSpeed: Float = 200 // points per second
    var armor: Float = 0 // damage reduction
    var luck: Float = 1.0 // affects drop rates
    var pickupRadius: Float = 50
    var experienceMultiplier: Float = 1.0
    var cooldownReduction: Float = 0 // percentage
    var damageMultiplier: Float = 1.0
    var projectileSpeed: Float = 1.0
    var projectileCount: Int = 0 // bonus projectiles
    var areaMultiplier: Float = 1.0
    var duration: Float = 1.0 // effect duration multiplier
    var revival: Int = 0 // extra lives
    var reroll: Int = 0 // reroll level-up choices
    var skip: Int = 0 // skip level-up choices
    var banish: Int = 0 // remove options permanently
}
```

### Playable Characters (8 total, 4 unlocked by default)

#### 1. Tariq the Wanderer (Starting character)
- **Starting weapon:** Curved Dagger (close-range spinning blades)
- **Bonus:** +10% move speed
- **Special:** Starts with +1 revival

#### 2. Layla the Sandmage
- **Starting weapon:** Sand Bolt (magic projectile)
- **Bonus:** +15% area of effect
- **Special:** Enemies within range take gradual damage from sandstorm aura

#### 3. Hassan the Trader (Unlockable)
- **Starting weapon:** Coin Toss (bouncing projectiles)
- **Bonus:** +30% luck, +20% gold pickup
- **Special:** Can buy items during level-up

#### 4. Fatima the Healer
- **Starting weapon:** Purifying Light (area heal + damage to undead)
- **Bonus:** +20% pickup radius
- **Special:** Regenerates 1 HP every 10 seconds

#### 5. Rashid the Warrior (Unlockable)
- **Starting weapon:** Scimitar Slash (wide arc attack)
- **Bonus:** +20% damage, +10 armor
- **Special:** Damage increases as health decreases

#### 6. Nadia the Assassin (Unlockable)
- **Starting weapon:** Throwing Knives (fast, piercing)
- **Bonus:** +25% cooldown reduction
- **Special:** Critical hits deal 3x damage instead of 2x

#### 7. Khalid the Djinn-Touched (Unlockable)
- **Starting weapon:** Flame Wisp (orbiting fire spirit)
- **Bonus:** +15% experience gain
- **Special:** Immune to fire damage, burns enemies on contact

#### 8. Mariam the Outcast (Secret character)
- **Starting weapon:** Cursed Eye (random weapon effects)
- **Bonus:** All stats +5%
- **Special:** Level-up offers 5 choices instead of 3

---

## Weapon System

### Weapon Structure

Each weapon has 8 evolution levels plus a final "awakened" form requiring a specific passive item combination.

### Base Weapons (12 total)

#### 1. Curved Dagger
- **Type:** Melee/Orbit
- **Behavior:** Spinning blades orbit the player
- **Base damage:** 10 | **Cooldown:** 1.5s
- **Evolution:** More daggers, larger orbit, faster spin
- **Awakened form:** "Whirlwind of Blades" (requires Sandstorm Cloak) - daggers create damaging wind trails

#### 2. Sand Bolt
- **Type:** Projectile
- **Behavior:** Fires at nearest enemy
- **Base damage:** 15 | **Cooldown:** 1.0s
- **Evolution:** More projectiles, piercing, larger
- **Awakened form:** "Desert Storm" (requires Djinn Lamp) - bolts explode into sandstorms

#### 3. Scorpion Tail
- **Type:** Whip
- **Behavior:** Strikes in direction of movement
- **Base damage:** 20 | **Cooldown:** 1.8s
- **Evolution:** Longer range, multiple strikes, poison
- **Awakened form:** "Emperor Scorpion" (requires Venom Vial) - summons spectral scorpion companions

#### 4. Sun Ray
- **Type:** Beam
- **Behavior:** Fires a beam toward cursor/nearest enemy
- **Base damage:** 8 per tick | **Duration:** 0.5s | **Cooldown:** 2.0s
- **Evolution:** Wider beam, longer duration, bounces
- **Awakened form:** "Wrath of the Sun" (requires Scarab Amulet) - beam leaves burning ground

#### 5. Dust Devil
- **Type:** Area
- **Behavior:** Creates damaging whirlwinds at random locations
- **Base damage:** 5 per tick | **Duration:** 3s | **Cooldown:** 4.0s
- **Evolution:** More devils, larger area, pulls enemies
- **Awakened form:** "Haboob" (requires Sandstorm Cloak) - one massive storm follows player

#### 6. Mirage Clone
- **Type:** Summon
- **Behavior:** Creates a copy that attacks enemies
- **Base damage:** 50% of player damage | **Duration:** 5s | **Cooldown:** 8.0s
- **Evolution:** More clones, longer duration, clones can use weapons
- **Awakened form:** "Army of Mirages" (requires Mirror of Truth) - permanent clone army

#### 7. Oil Flask
- **Type:** Thrown
- **Behavior:** Throws flask that creates burning pool
- **Base damage:** 25 impact + 5/tick burn | **Cooldown:** 3.0s
- **Evolution:** More flasks, larger pools, longer burn
- **Awakened form:** "Greek Fire" (requires Djinn Lamp) - pools explode when enemies die in them

#### 8. Desert Eagle (Falcon)
- **Type:** Homing
- **Behavior:** Summons falcon that attacks enemies
- **Base damage:** 30 | **Cooldown:** 2.5s
- **Evolution:** More falcons, faster, chains to nearby enemies
- **Awakened form:** "Roc's Descendant" (requires Eagle Feather) - giant falcon does bombing runs

#### 9. Sandstorm Shield
- **Type:** Defensive/Damage
- **Behavior:** Barrier that damages enemies on contact
- **Base damage:** 5/tick to touching enemies | **Cooldown:** passive
- **Evolution:** Larger barrier, reflects projectiles, knockback
- **Awakened form:** "Eye of the Storm" (requires Desert Rose) - immunity bubble with massive damage

#### 10. Ancient Curse
- **Type:** Debuff
- **Behavior:** Marks random enemies to take increased damage
- **Base effect:** +50% damage taken | **Duration:** 5s | **Cooldown:** 6.0s
- **Evolution:** More targets, longer duration, spreads on death
- **Awakened form:** "Pharaoh's Wrath" (requires Canopic Jar) - cursed enemies explode

#### 11. Quicksand
- **Type:** Trap
- **Behavior:** Creates patches that slow and damage enemies
- **Base damage:** 3/tick, slow 50% | **Duration:** 4s | **Cooldown:** 5.0s
- **Evolution:** More patches, stronger slow, larger area
- **Awakened form:** "Devouring Sands" (requires Hourglass) - enemies sink and die after 3 seconds

#### 12. Djinn's Flame
- **Type:** Magic
- **Behavior:** Blue flames seek out enemies
- **Base damage:** 18 | **Cooldown:** 1.2s
- **Evolution:** More flames, faster, chain between enemies
- **Awakened form:** "Ifrit's Embrace" (requires Djinn Lamp + Venom Vial) - transforms player into fire form temporarily

---

## Passive Items (16 total)

Each passive has 5 levels and provides stacking bonuses.

### Offensive

| Item | Effect per Level |
|------|------------------|
| Sharpened Steel | +10% damage |
| Swift Hands | +8% cooldown reduction |
| Eagle Eye | +10% projectile speed |
| Expansive Force | +10% area |
| Lasting Effect | +10% duration |

### Defensive

| Item | Effect per Level |
|------|------------------|
| Desert Armor | +5 armor |
| Oasis Heart | +20 max HP |
| Second Wind | +0.5 HP/s regeneration |
| Mirage Step | +10% move speed |

### Utility

| Item | Effect per Level |
|------|------------------|
| Magnetic Charm | +20% pickup radius |
| Fortune's Favor | +10% luck |
| Scholar's Mind | +10% experience |
| Merchant's Eye | +15% gold |

### Evolution Items (required for weapon awakenings)

| Item | Effect per Level |
|------|------------------|
| Sandstorm Cloak | +5% dodge chance |
| Djinn Lamp | +5% damage, chance to burn |
| Scarab Amulet | +3% lifesteal |
| Venom Vial | attacks have chance to poison |
| Mirror of Truth | +5% critical chance |
| Eagle Feather | +5% attack speed |
| Desert Rose | +10 HP, +5% damage reduction |
| Canopic Jar | enemies drop +10% more XP |
| Hourglass | +8% to all time-based effects |

---

## Enemy System

### Enemy Categories and Types

#### Tier 1 - Common (spawn from start)

| Enemy | Description |
|-------|-------------|
| Sand Scarab | Basic swarmer, low HP, medium speed |
| Desert Rat | Fast, very low HP, comes in groups |
| Scorpion | Slow, low HP, poison attack |
| Dust Sprite | Floats, low HP, ranged sand attack |

#### Tier 2 - Uncommon (spawn after minute 2)

| Enemy | Description |
|-------|-------------|
| Mummified Wanderer | Medium HP, slow but tanky |
| Sand Cobra | Fast, lunging attack, medium HP |
| Desert Bandit | Medium speed/HP, throws daggers |
| Cursed Jackal | Fast, howls to buff nearby enemies |

#### Tier 3 - Rare (spawn after minute 5)

| Enemy | Description |
|-------|-------------|
| Animated Statue | Very slow, high HP, heavy damage |
| Sand Elemental | Splits into smaller elementals on death |
| Tomb Guardian | Tanky, shield blocks frontal attacks |
| Ghoul | Medium stats, heals from dealing damage |

#### Tier 4 - Elite (spawn after minute 10)

| Enemy | Description |
|-------|-------------|
| Mummy Lord | Summons scarabs, curse aura |
| Lamia | Fast, charm ability (confuses player movement) |
| Bone Colossus | Huge, area attacks, very high HP |
| Sandstorm Djinn | Teleports, ranged attacks, medium-high HP |

#### Tier 5 - Mini-Bosses (spawn every 5 minutes)

| Enemy | Description |
|-------|-------------|
| The Defiler | Giant scorpion, poison pools, burrow attack |
| Pharaoh's Shadow | Curse beams, summons servants |
| The Simoom | Living sandstorm, damage aura, fast |
| Brass Automaton | Clockwork guardian, laser beam, repair drones |

#### Final Boss (spawns at 30 minutes)

**Apophis the Devourer** - Giant serpent, multiple phases:
- **Phase 1:** Coils around arena edge, fires projectiles
- **Phase 2:** Summons sand minions while vulnerable
- **Phase 3:** Chases player directly, area denial attacks

### Enemy Spawn Logic

```swift
struct WaveConfig {
    var baseEnemiesPerMinute: Int = 30
    var enemiesPerMinuteGrowth: Float = 1.15 // exponential growth
    var maxEnemiesOnScreen: Int = 500
    var eliteChance: Float = 0.05 // increases over time
    var swarmEventChance: Float = 0.1 // chance of enemy swarm
}
```

**Spawn patterns:**
- Random distribution around player (outside visible area)
- Directional waves from one side
- Encirclement (spawn in ring around player)
- Swarm events (100+ weak enemies at once)

---

## Progression Systems

### Experience and Leveling

XP required per level: `baseXP * (1.1 ^ level)` where baseXP = 10

Level-up presents 3-4 random choices:
- New weapon (if under 6 weapons)
- Weapon upgrade (if weapon not maxed)
- New passive item
- Passive item upgrade
- Gold (scales with level)
- Health restore (25% max HP)

### Meta Progression (Persistent)

**Gold spending:**
- Permanent stat upgrades (small %)
- Unlock new characters
- Unlock new starting weapons
- Unlock "Arcana" modifiers

**Achievements unlock:**
- New characters
- New game modes
- Cosmetic skins
- Arcana cards

### Arcana System

Unlockable cards that modify gameplay rules. Player can equip 1-3 before run:

| Arcana | Effect |
|--------|--------|
| Endless Sands | Game continues past 30 minutes, scaling infinitely |
| Merchant's Blessing | Shop appears every 5 minutes |
| Djinn's Gambit | Double damage taken and dealt |
| Pharaoh's Curse | No healing, but +50% damage |
| Oasis Dream | Start with random evolved weapon |
| Desert Mirage | Enemy projectiles have 20% miss chance |
| Scorching Sun | All enemies take 1 damage/second |
| Sandstorm's Eye | Pickup radius grows over time |
| Ancient Knowledge | Start at level 10 |
| Time Dilation | Game speed 1.5x, rewards 1.5x |

---

## Map System

### Endless Desert (Default Stage)

Procedurally generated terrain with:
- Sand dunes (visual only)
- Rock formations (obstacles)
- Oases (heal when standing in them)
- Ruins (destructible, drop items)
- Quicksand patches (slow player)

**Environmental events:**
- Sandstorm (reduced visibility, enemies slower)
- Solar eclipse (undead enemies stronger)
- Mirage (fake pickups and enemies)

### Additional Stages (Unlockable)

#### Stage 2: Tomb of the Pharaohs
- Indoor environment
- Narrow corridors and large chambers
- Trap tiles (spikes, flame jets)
- Unique enemy set (mummies, animated statues)
- **Boss:** Resurrected Pharaoh

#### Stage 3: The Burning Wastes
- Volcanic desert
- Lava pools (damage zones)
- Fire-based enemies
- Eruption events
- **Boss:** Efreet Lord

#### Stage 4: The Lost Oasis
- Lush hidden paradise
- Water mechanics (slow movement in shallow, drowning in deep)
- Plant and water enemies
- Day/night cycle affecting enemy types
- **Boss:** Guardian Treant

#### Stage 5: The Void Between
- Surreal dimension
- Platforms over void
- Reality-warping effects
- All enemy types combined
- **Final Boss:** The Nameless One

---

## Audio Design

### Music Tracks Needed

| Track | Description |
|-------|-------------|
| Main menu theme | Mysterious, Arabian instruments |
| Gameplay track 1 | Action, building intensity |
| Gameplay track 2 | Alternative action track |
| Boss theme | Intense, dramatic |
| Victory fanfare | Short celebratory jingle |
| Death/game over sting | Somber, brief |
| Level up jingle | Rewarding sound |

### Sound Effects

- Player footsteps on sand
- Each weapon attack sound (12+ unique)
- Enemy hit/death sounds per type
- Pickup sounds (gem, gold, item)
- UI sounds (menu select, level up choice)
- Environmental (wind, sandstorm)
- Boss attack sounds

---

## Visual Style

### Art Direction

- Top-down perspective with slight angle
- Pixel art style (16x16 or 32x32 base sprites)
- Warm color palette (oranges, yellows, browns)
- Distinct silhouettes for all enemies
- Clear visual feedback for damage, pickups, level-ups
- Screen shake on big hits
- Particle effects for magic, sand, fire

### UI Requirements

- Health bar (top or bottom of screen)
- XP bar with level indicator
- Timer (survival time)
- Kill counter
- Weapon icons showing cooldowns
- Minimap (optional toggle)
- Damage numbers (pooled, floating)
- Boss health bar (when applicable)

---

## Technical Implementation Details

### Game Loop (60 FPS target)

```swift
func update(_ currentTime: TimeInterval) {
    let deltaTime = currentTime - lastUpdateTime
    
    // 1. Process input
    processInput()
    
    // 2. Update player
    player.update(deltaTime)
    
    // 3. Update weapons
    weaponManager.update(deltaTime, playerPosition: player.position)
    
    // 4. Update enemies
    enemyManager.update(deltaTime, playerPosition: player.position)
    
    // 5. Check collisions
    collisionManager.checkCollisions()
    
    // 6. Update pickups
    pickupManager.update(deltaTime, playerPosition: player.position)
    
    // 7. Update UI
    hud.update()
    
    // 8. Spawn new enemies
    waveManager.update(deltaTime)
    
    lastUpdateTime = currentTime
}
```

### Object Pooling Example

```swift
class ObjectPool<T: SKNode> {
    private var available: [T] = []
    private var active: Set<T> = []
    private let factory: () -> T
    
    init(initialSize: Int, factory: @escaping () -> T) {
        self.factory = factory
        for _ in 0..<initialSize {
            let obj = factory()
            obj.isHidden = true
            available.append(obj)
        }
    }
    
    func spawn() -> T {
        let obj: T
        if let existing = available.popLast() {
            obj = existing
        } else {
            obj = factory()
        }
        obj.isHidden = false
        active.insert(obj)
        return obj
    }
    
    func despawn(_ obj: T) {
        obj.isHidden = true
        obj.removeAllActions()
        active.remove(obj)
        available.append(obj)
    }
}
```

### Collision Detection with Spatial Hashing

```swift
class SpatialHash {
    private var cells: [Int: [SKNode]] = [:]
    private let cellSize: CGFloat = 100
    
    func hash(_ position: CGPoint) -> Int {
        let x = Int(position.x / cellSize)
        let y = Int(position.y / cellSize)
        return x * 73856093 ^ y * 19349663
    }
    
    func insert(_ node: SKNode) {
        let key = hash(node.position)
        cells[key, default: []].append(node)
    }
    
    func query(near position: CGPoint, radius: CGFloat) -> [SKNode] {
        var result: [SKNode] = []
        let cellsToCheck = Int(ceil(radius / cellSize))
        
        for dx in -cellsToCheck...cellsToCheck {
            for dy in -cellsToCheck...cellsToCheck {
                let checkPos = CGPoint(
                    x: position.x + CGFloat(dx) * cellSize,
                    y: position.y + CGFloat(dy) * cellSize
                )
                if let nodes = cells[hash(checkPos)] {
                    result.append(contentsOf: nodes)
                }
            }
        }
        return result
    }
    
    func clear() {
        cells.removeAll(keepingCapacity: true)
    }
}
```

---

## Save System

### Data to Persist

```swift
struct SaveData: Codable {
    var totalGold: Int
    var totalKills: Int
    var totalPlayTime: TimeInterval
    var highestSurvivalTime: TimeInterval
    var unlockedCharacters: Set<String>
    var unlockedWeapons: Set<String>
    var unlockedArcana: Set<String>
    var unlockedStages: Set<String>
    var achievements: [String: Bool]
    var permanentUpgrades: [String: Int]
    var settings: GameSettings
}

struct GameSettings: Codable {
    var musicVolume: Float
    var sfxVolume: Float
    var screenShake: Bool
    var damageNumbers: Bool
    var autoAim: Bool
}
```

---

## Control Scheme

### Touch Controls

- Virtual joystick (left side) for movement
- Player auto-aims at nearest enemy
- Tap anywhere to use active ability (if equipped)
- Pause button (top right)
- Optional: swipe to dash (if dash ability equipped)

### Alternative Control Options

- Floating joystick (appears where touched)
- Fixed joystick position
- Relative touch (drag from any point)
- Gamepad support via GCController

---

## Monetization (Optional Implementation)

If implementing monetization:
- One-time purchase to remove ads
- Cosmetic character skins
- No pay-to-win mechanics
- All gameplay content unlockable through play

---

## Development Milestones

### Phase 1: Core Gameplay (Week 1-2)
- [ ] Basic player movement and controls
- [ ] Single weapon implementation
- [ ] Basic enemy spawning and AI
- [ ] Collision detection
- [ ] XP and leveling system

### Phase 2: Content (Week 3-4)
- [ ] All weapons implemented
- [ ] All enemies implemented
- [ ] All passive items
- [ ] Level-up UI
- [ ] Basic HUD

### Phase 3: Polish (Week 5-6)
- [ ] All characters
- [ ] Meta progression
- [ ] Save system
- [ ] Audio implementation
- [ ] Visual effects and particles

### Phase 4: Expansion (Week 7-8)
- [ ] Additional stages
- [ ] Arcana system
- [ ] Achievements
- [ ] Final balancing
- [ ] Performance optimization

---

## Build Instructions for Cursor

When building this game, follow these priorities:

1. **Start with the core loop** - Get a player moving on screen, one weapon firing, enemies spawning and dying, XP dropping and being collected.

2. **Build systems, not features** - Create the WeaponManager, EnemySpawner, and PoolingManager as flexible systems that can handle any weapon/enemy type.

3. **Performance first** - Always use object pooling. Test with 500 enemies early. Optimize before adding more content.

4. **One weapon at a time** - Fully implement and balance one weapon before moving to the next.

5. **Iterate on feel** - The game should feel good to play before it looks good. Screen shake, audio feedback, and responsive controls matter more than pretty sprites.

> **Important:** Ask me before making significant architectural decisions. Show me the code for core systems before building on top of them.

---

## Quick Reference: Weapon Evolution Chart

| Base Weapon | + Evolution Item | = Awakened Form |
|-------------|------------------|-----------------|
| Curved Dagger | Sandstorm Cloak | Whirlwind of Blades |
| Sand Bolt | Djinn Lamp | Desert Storm |
| Scorpion Tail | Venom Vial | Emperor Scorpion |
| Sun Ray | Scarab Amulet | Wrath of the Sun |
| Dust Devil | Sandstorm Cloak | Haboob |
| Mirage Clone | Mirror of Truth | Army of Mirages |
| Oil Flask | Djinn Lamp | Greek Fire |
| Desert Eagle | Eagle Feather | Roc's Descendant |
| Sandstorm Shield | Desert Rose | Eye of the Storm |
| Ancient Curse | Canopic Jar | Pharaoh's Wrath |
| Quicksand | Hourglass | Devouring Sands |
| Djinn's Flame | Djinn Lamp + Venom Vial | Ifrit's Embrace |

---

## Quick Reference: Enemy Spawn Timeline

| Time | New Enemies Introduced |
|------|------------------------|
| 0:00 | Sand Scarab, Desert Rat, Scorpion, Dust Sprite |
| 2:00 | Mummified Wanderer, Sand Cobra, Desert Bandit, Cursed Jackal |
| 5:00 | Animated Statue, Sand Elemental, Tomb Guardian, Ghoul |
| 5:00 | **Mini-Boss:** The Defiler |
| 10:00 | Mummy Lord, Lamia, Bone Colossus, Sandstorm Djinn |
| 10:00 | **Mini-Boss:** Pharaoh's Shadow |
| 15:00 | **Mini-Boss:** The Simoom |
| 20:00 | **Mini-Boss:** Brass Automaton |
| 25:00 | All mini-bosses can spawn |
| 30:00 | **Final Boss:** Apophis the Devourer |
