# Tariq Character Integration Guide

## ✅ Character Successfully Generated!

Tariq, your main character for Desert Survivors, has been generated using PixelLab AI and integrated into your Xcode project.

## 📦 What Was Generated

- **Character Name**: Tariq
- **Description**: Young Arabian warrior with curved dagger, wearing flowing desert robes and turban, tan skin, determined expression, gold trim on robes
- **Canvas Size**: 64×64 pixels
- **Character Size**: ~38px tall, ~28px wide
- **Directional Views**: 8 directions (full 360° movement)
- **Style**: Medium shading, single color black outline, high detail
- **View**: Low top-down perspective

## 📍 Asset Locations

### Xcode Assets (Ready to use)
```
DesertSurvivors/Assets.xcassets/Characters/
├── Tariq.imageset/               # Default (south-facing)
├── Tariq-south.imageset/         # South (↓)
├── Tariq-north.imageset/         # North (↑)
├── Tariq-east.imageset/          # East (→)
├── Tariq-west.imageset/          # West (←)
├── Tariq-south-east.imageset/    # South-East (↘)
├── Tariq-south-west.imageset/    # South-West (↙)
├── Tariq-north-east.imageset/    # North-East (↗)
└── Tariq-north-west.imageset/    # North-West (↖)
```

### Original Files
```
GeneratedAssets/characters/Tariq/
├── south.png
├── north.png
├── east.png
├── west.png
├── south-east.png
├── south-west.png
├── north-east.png
└── north-west.png
```

## 🎮 Using in Swift/SpriteKit

### Option 1: Simple Single Sprite (Current Implementation)

Replace the placeholder in `Player.swift`:

```swift
// In Player.swift init method
class Player: SKNode {
    let sprite: SKSpriteNode

    init() {
        // OLD (Placeholder):
        // sprite = SKSpriteNode(color: .orange, size: CGSize(width: 32, height: 32))

        // NEW (Tariq sprite):
        let tariqTexture = SKTexture(imageNamed: "Tariq")
        sprite = SKSpriteNode(texture: tariqTexture)
        sprite.size = CGSize(width: 64, height: 64)  // Match canvas size

        super.init()
        addChild(sprite)
        setupPhysics()
    }
}
```

### Option 2: Directional Sprites (Recommended for Better Movement)

Add directional sprite switching based on movement:

```swift
// In Player.swift
class Player: SKNode {
    let sprite: SKSpriteNode
    private var directionalTextures: [Direction: SKTexture] = [:]

    enum Direction {
        case south, north, east, west
        case southEast, southWest, northEast, northWest
    }

    override init() {
        // Load all directional textures
        directionalTextures = [
            .south: SKTexture(imageNamed: "Tariq-south"),
            .north: SKTexture(imageNamed: "Tariq-north"),
            .east: SKTexture(imageNamed: "Tariq-east"),
            .west: SKTexture(imageNamed: "Tariq-west"),
            .southEast: SKTexture(imageNamed: "Tariq-south-east"),
            .southWest: SKTexture(imageNamed: "Tariq-south-west"),
            .northEast: SKTexture(imageNamed: "Tariq-north-east"),
            .northWest: SKTexture(imageNamed: "Tariq-north-west")
        ]

        // Start with south-facing sprite
        sprite = SKSpriteNode(texture: directionalTextures[.south])
        sprite.size = CGSize(width: 64, height: 64)

        super.init()
        addChild(sprite)
        setupPhysics()
    }

    // Call this in your update method when player moves
    func updateDirection(velocity: CGVector) {
        let direction = getDirectionFromVelocity(velocity)
        sprite.texture = directionalTextures[direction]
    }

    private func getDirectionFromVelocity(_ velocity: CGVector) -> Direction {
        let angle = atan2(velocity.dy, velocity.dx)
        let degrees = angle * 180 / .pi

        // Map angle to 8 directions
        switch degrees {
        case -22.5..<22.5: return .east
        case 22.5..<67.5: return .northEast
        case 67.5..<112.5: return .north
        case 112.5..<157.5: return .northWest
        case 157.5...180, -180..<(-157.5): return .west
        case -157.5..<(-112.5): return .southWest
        case -112.5..<(-67.5): return .south
        case -67.5..<(-22.5): return .southEast
        default: return .south
        }
    }
}
```

### Option 3: Integration with Existing Animation System

If you want to keep your current procedural animation (bobbing, walk cycles), combine it with the sprite:

```swift
// In Player.swift
override init() {
    let tariqTexture = SKTexture(imageNamed: "Tariq")
    sprite = SKSpriteNode(texture: tariqTexture)
    sprite.size = CGSize(width: 64, height: 64)

    super.init()
    addChild(sprite)
    setupPhysics()

    // Keep your existing animations
    startIdleAnimation()
}

// Your existing animations will work on top of the Tariq sprite
func startIdleAnimation() {
    let bobUp = SKAction.moveBy(x: 0, y: 3, duration: 0.6)
    let bobDown = SKAction.moveBy(x: 0, y: -3, duration: 0.6)
    let bob = SKAction.sequence([bobUp, bobDown])
    sprite.run(SKAction.repeatForever(bob), withKey: "idle")
}
```

## 🔄 Update Your Game Scene

In `GameScene.swift`, no changes needed if you updated `Player.swift`. The player will automatically use the new sprite.

## 🎨 Sprite Specifications

| Property | Value |
|----------|-------|
| Canvas Size | 64×64 pixels |
| Character Height | ~38 pixels |
| Character Width | ~28 pixels |
| Outline | Single color black outline |
| Shading | Medium shading |
| Detail Level | High detail |
| Transparency | Yes (PNG alpha channel) |
| Directions | 8-way movement support |

## 🚀 Next Steps

1. **Update Player.swift** - Replace the placeholder sprite with Tariq
2. **Test in Simulator** - Run the game and see Tariq in action
3. **Add Directional Sprites** - Implement option 2 for better movement visuals
4. **Generate Animations** - Use PixelLab to add walk/attack animations
5. **Create Other Characters** - Generate Amara, Zahra, and other characters

## 🎬 Adding Animations (Future)

You can generate walk, attack, and death animations for Tariq using:

```python
# Run this from Scripts/AssetGeneration/
python3 -c "
from pixellab_client import PixelLabClient
client = PixelLabClient(
    api_url='https://api.pixellab.ai/mcp',
    api_key='88e2b87c-1255-4754-835b-ab5ea1f6c867'
)

# Request walk animation
payload = {
    'jsonrpc': '2.0',
    'id': 1,
    'method': 'tools/call',
    'params': {
        'name': 'animate_character',
        'arguments': {
            'character_id': '1b6c1bbc-06e8-4fb6-aa9a-54cca2782d3d',
            'template_animation_id': 'walk'
        }
    }
}
# Make request...
"
```

## 📝 Character ID

**Tariq's PixelLab Character ID**: `1b6c1bbc-06e8-4fb6-aa9a-54cca2782d3d`

Save this ID - you'll need it to generate animations or variations.

## ✨ Preview

Tariq appears as a young Arabian warrior with:
- Flowing desert robes with gold trim
- Traditional turban
- Curved dagger weapon
- Tan skin tone
- Determined facial expression
- High-quality pixel art detail
- 8 directional views for smooth 360° movement

## 🔗 Resources

- **PixelLab Character Link**: Check status at https://api.pixellab.ai/mcp/characters/1b6c1bbc-06e8-4fb6-aa9a-54cca2782d3d
- **Original Files**: `GeneratedAssets/characters/Tariq/`
- **Xcode Assets**: `DesertSurvivors/Assets.xcassets/Characters/`

---

**Status**: ✅ Ready to use in your game!

**Next Command**: Open Xcode and update `Player.swift` to use the new Tariq sprite.
