# PixelLab MCP Asset Generation - Complete Setup Summary

## What Was Created

A complete programmatic workflow for generating all Desert Survivors game assets using the PixelLab MCP API.

### Files Created

```
Scripts/AssetGeneration/
├── README.md                              # Complete documentation
├── WORKFLOW.md                            # Detailed workflow guide
├── SUMMARY.md                             # This file
├── requirements.txt                       # Python dependencies
│
├── pixellab_client.py                     # PixelLab API client library
├── generate_desert_survivors_assets.py    # Main asset generation script
├── integrate_assets.py                    # Xcode integration script
├── test_connection.py                     # Connection test utility
└── quick_start.sh                         # Interactive setup script
```

## Capabilities

### 1. Character Generation
Generate 8 playable characters with custom:
- Descriptions and appearance
- Color palettes
- 64x64 pixel resolution
- Top-down perspective

**Characters**: Tariq, Amara, Zahra, Khalid, Yasmin, Omar, Layla, Hassan

### 2. Character Animation
Generate sprite sheets with multiple animations:
- idle, walk (4 directions), attack, hurt, death
- 4 frames per animation
- 32 total frames per character
- Configurable frame duration

### 3. Enemy Generation
Generate 8 enemy types:
- **Tier 1**: Sand Scarab, Desert Rat, Scorpion, Dust Sprite
- **Tier 2**: Mummified Wanderer, Sand Cobra, Desert Bandit, Cursed Jackal
- 48x48 pixel resolution
- Top-down perspective

### 4. Tileset Creation
Generate desert environment tilesets:
- **DesertGround**: Sand variations, dunes, rocky terrain (6 tiles × 4 variations)
- **DesertFeatures**: Rocks, boulders, sand piles (6 tiles × 3 variations)
- **Oasis**: Water, grass, palm bases (5 tiles × 2 variations)
- 64x64 tile size
- Seamless tiling

### 5. Map Objects
Generate 20+ props and decorations:
- **Vegetation**: Cacti (small/large), dead bushes, palm trees
- **Geology**: Rocks (small/medium/large), sand dunes
- **Ruins**: Broken columns, walls, obelisks, tomb entrances
- **Bones**: Animal skulls, ribcages, skeletons
- **Props**: Wooden chests, gold chests, campfires, tents
- **Atmospheric**: Sand swirls, footprints

### 6. UI Elements
Generate interface icons:
- XP Gems (Blue, Green, Red) - 16x16
- Gold Coin - 16x16
- Health Potion - 32x32
- Heart Icon - 16x16

## How It Works

### Architecture

```
PixelLab API (MCP Protocol)
    ↓
pixellab_client.py (Python wrapper)
    ↓
generate_desert_survivors_assets.py (Game-specific generator)
    ↓
GeneratedAssets/ (PNG files + manifest)
    ↓
integrate_assets.py (Xcode integration)
    ↓
Assets.xcassets (Xcode-ready assets)
    ↓
Swift/SpriteKit (SKTexture usage)
```

### API Methods

#### `create_character(name, description, style, view, size, color_palette)`
Generates individual character sprites with specified visual properties.

#### `animate_character(character_name, animations, frames_per_animation, frame_duration)`
Generates animation spritesheets with multiple animation states.

#### `create_tileset(name, tileset_type, tiles, tile_size, variations)`
Generates tilesets with multiple tile types and variations.

#### `create_map_object(name, description, object_type, size, has_shadow)`
Generates props, decorations, and obstacles.

## Usage

### Quick Start (Recommended)

```bash
cd Scripts/AssetGeneration
./quick_start.sh
```

This runs all steps automatically with user prompts.

### Manual Step-by-Step

```bash
# 1. Install dependencies
pip3 install -r requirements.txt

# 2. Test connection
python3 test_connection.py

# 3. Generate all assets (5-10 minutes)
python3 generate_desert_survivors_assets.py

# 4. Integrate into Xcode
python3 integrate_assets.py
```

### Custom Generation

```python
from pixellab_client import PixelLabClient

client = PixelLabClient(
    api_url="https://api.pixellab.ai/mcp",
    api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
)

# Generate custom character
client.create_character(
    name="MyHero",
    description="Brave knight with shining armor",
    style="16-bit",
    view="top-down",
    size=64,
    color_palette=["#FFD700", "#C0C0C0", "#8B4513"]
)
```

## Output Structure

### Generated Files

```
GeneratedAssets/
├── characters/
│   ├── Tariq.png
│   ├── Amara.png
│   ├── Zahra.png
│   ├── Khalid.png
│   ├── Yasmin.png
│   ├── Omar.png
│   ├── Layla.png
│   └── Hassan.png
│
├── enemies/
│   ├── SandScarab.png
│   ├── DesertRat.png
│   ├── Scorpion.png
│   ├── DustSprite.png
│   ├── MummifiedWanderer.png
│   ├── SandCobra.png
│   ├── DesertBandit.png
│   └── CursedJackal.png
│
├── animations/
│   ├── Tariq_spritesheet.png
│   ├── Amara_spritesheet.png
│   └── ... (8 total)
│
├── tilesets/
│   ├── DesertGround_top-down.png
│   ├── DesertFeatures_top-down.png
│   └── Oasis_top-down.png
│
├── objects/
│   ├── Cactus_Small.png
│   ├── Cactus_Large.png
│   ├── Rock_Small.png
│   ├── Rock_Medium.png
│   ├── Rock_Large.png
│   ├── BrokenColumn.png
│   ├── Skull_Animal.png
│   ├── Chest_Wooden.png
│   └── ... (20+ total)
│
├── UI/
│   ├── XP_Gem_Blue.png
│   ├── XP_Gem_Green.png
│   ├── XP_Gem_Red.png
│   ├── Gold_Coin.png
│   ├── Health_Potion.png
│   └── Heart_Icon.png
│
├── asset_manifest.json          # Metadata for all assets
└── ASSET_REFERENCE.md           # Swift usage guide
```

### Xcode Integration

After running `integrate_assets.py`:

```
DesertSurvivors/Assets.xcassets/
├── Characters/
│   ├── Tariq.imageset/
│   │   ├── Tariq.png
│   │   └── Contents.json
│   ├── Amara.imageset/
│   └── ... (8 total)
│
├── Enemies/
│   ├── SandScarab.imageset/
│   └── ... (8 total)
│
├── Animations/
│   └── ... (8 spritesheets)
│
├── Tilesets/
│   └── ... (3 tilesets)
│
├── MapObjects/
│   └── ... (20+ objects)
│
└── UI/
    └── ... (6 elements)
```

## Swift Integration

### Using Characters

```swift
// Load character texture
let tariqTexture = SKTexture(imageNamed: "Tariq")
let playerSprite = SKSpriteNode(texture: tariqTexture)
playerSprite.size = CGSize(width: 64, height: 64)
```

### Using Enemies

```swift
// Load enemy texture
let scarabTexture = SKTexture(imageNamed: "SandScarab")
let enemySprite = SKSpriteNode(texture: scarabTexture)
enemySprite.size = CGSize(width: 48, height: 48)
```

### Using Animations

```swift
// Load spritesheet
let spritesheetTexture = SKTexture(imageNamed: "Tariq_animations")

// Extract individual frames (assuming 64x64 frames)
func extractFrame(row: Int, col: Int) -> SKTexture {
    let frameSize = CGSize(width: 64, height: 64)
    let x = CGFloat(col) * frameSize.width / spritesheetTexture.size().width
    let y = CGFloat(row) * frameSize.height / spritesheetTexture.size().height
    let width = frameSize.width / spritesheetTexture.size().width
    let height = frameSize.height / spritesheetTexture.size().height

    return SKTexture(rect: CGRect(x: x, y: y, width: width, height: height),
                    in: spritesheetTexture)
}

// Create walk animation
let walkFrames = (0..<4).map { extractFrame(row: 1, col: $0) }
let walkAnimation = SKAction.animate(with: walkFrames, timePerFrame: 0.15)
playerSprite.run(SKAction.repeatForever(walkAnimation))
```

### Using Map Objects

```swift
// Load and place map objects
let cactusTexture = SKTexture(imageNamed: "Cactus_Large")
let cactus = SKSpriteNode(texture: cactusTexture)
cactus.position = CGPoint(x: 200, y: 300)
cactus.zPosition = 10
scene.addChild(cactus)
```

### Using UI Elements

```swift
// XP gem pickup
let xpGemTexture = SKTexture(imageNamed: "XP_Gem_Blue")
let xpGem = SKSpriteNode(texture: xpGemTexture)
xpGem.size = CGSize(width: 16, height: 16)

// Health display
let heartTexture = SKTexture(imageNamed: "Heart_Icon")
let heartIcon = SKSpriteNode(texture: heartTexture)
```

## Asset Statistics

| Category | Count | Total Size (est.) | Resolution Range |
|----------|-------|-------------------|------------------|
| Characters | 8 | ~2 MB | 64x64 |
| Enemies | 8 | ~1.5 MB | 48x48 |
| Animations | 8 | ~8 MB | 256x2048 (32 frames) |
| Tilesets | 3 | ~3 MB | Variable grid |
| Map Objects | 20+ | ~4 MB | 32-128px |
| UI Elements | 6 | ~0.5 MB | 16-32px |
| **Total** | **~50+** | **~19 MB** | **Multiple** |

## Configuration

### MCP Server

Already configured in your project:

```json
{
  "pixellab": {
    "url": "https://api.pixellab.ai/mcp",
    "transport": "http",
    "headers": {
      "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867"
    }
  }
}
```

Verify with:
```bash
claude mcp list
```

### Python Environment

Required package:
- `requests>=2.31.0`

Install with:
```bash
pip3 install -r requirements.txt
```

## Customization

### Add New Characters

Edit `generate_desert_survivors_assets.py`:

```python
characters = [
    # ... existing characters ...
    {
        "name": "NewCharacter",
        "description": "Your character description here",
        "palette": ["#COLOR1", "#COLOR2", "#COLOR3", "#COLOR4"]
    }
]
```

### Add New Map Objects

```python
objects = [
    # ... existing objects ...
    {
        "name": "CustomObject",
        "description": "Detailed object description",
        "type": "prop",  # or "decoration", "obstacle"
        "size": 64
    }
]
```

### Modify Asset Parameters

Change defaults in `pixellab_client.py` method calls:
- `style`: "8-bit", "16-bit", "32-bit"
- `view`: "top-down", "side", "isometric"
- `size`: 16, 32, 48, 64, 96, 128, 256
- `color_palette`: List of hex colors

## Troubleshooting

### Connection Failed

```bash
# Re-configure MCP server
claude mcp remove pixellab -s local
claude mcp add pixellab https://api.pixellab.ai/mcp \
  --transport http \
  --header "Authorization: Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867"
```

### Rate Limiting

Add delays in generation script:

```python
import time
time.sleep(1)  # Between requests
```

### Asset Quality Issues

Refine descriptions with more detail:
- Specify colors, materials, poses
- Add lighting and shadow details
- Mention specific features

## Next Steps

1. ✅ **Scripts Created** - All asset generation scripts ready
2. ⏭️ **Run Quick Start** - Execute `./quick_start.sh`
3. ⏭️ **Generate Assets** - Create all game assets (5-10 min)
4. ⏭️ **Verify Output** - Check `GeneratedAssets/` directory
5. ⏭️ **Integrate to Xcode** - Run integration script
6. ⏭️ **Update Swift Code** - Replace placeholder assets
7. ⏭️ **Test in Game** - Run in simulator
8. ⏭️ **Refine & Iterate** - Regenerate improved versions

## Resources

- **This Summary**: `Scripts/AssetGeneration/SUMMARY.md`
- **Detailed Workflow**: `Scripts/AssetGeneration/WORKFLOW.md`
- **Complete Documentation**: `Scripts/AssetGeneration/README.md`
- **Quick Start**: `Scripts/AssetGeneration/quick_start.sh`
- **Test Connection**: `Scripts/AssetGeneration/test_connection.py`

## Support

```bash
# List all scripts
ls -lah Scripts/AssetGeneration/

# Test connection
python3 Scripts/AssetGeneration/test_connection.py

# Check MCP status
claude mcp list

# Get help
cat Scripts/AssetGeneration/README.md
```

---

**Status**: ✅ Complete and ready to use

**Estimated generation time**: 5-10 minutes for all assets

**Next command**: `cd Scripts/AssetGeneration && ./quick_start.sh`
