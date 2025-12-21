# Desert Survivors - PixelLab Asset Generation

Automated asset generation workflow using PixelLab MCP API.

## Overview

This workflow generates all game assets for Desert Survivors:
- **8 Playable Characters** with animations
- **8 Enemy Types** (Tier 1 & 2)
- **Character Animation Spritesheets** (idle, walk, attack, hurt, death)
- **Desert Tilesets** (ground, features, oasis)
- **Map Objects** (cacti, rocks, ruins, bones, props)
- **UI Elements** (gems, coins, icons)

## Setup

### 1. Install Python Dependencies

```bash
cd Scripts/AssetGeneration
pip install -r requirements.txt
```

### 2. Verify PixelLab MCP Connection

The MCP server is already configured. Verify connection:

```bash
claude mcp list
```

You should see:
```
pixellab: https://api.pixellab.ai/mcp (HTTP) - ✓ Connected
```

## Usage

### Generate All Assets

Run the complete asset generation workflow:

```bash
cd Scripts/AssetGeneration
python3 generate_desert_survivors_assets.py
```

This will:
1. Generate all characters, enemies, animations, tilesets, and objects
2. Save assets to `GeneratedAssets/` directory
3. Create `asset_manifest.json` with metadata

**Estimated time:** 5-10 minutes (depending on API speed)

### Integrate Assets into Xcode

After generation completes, integrate assets into your Xcode project:

```bash
python3 integrate_assets.py
```

This will:
1. Copy assets to `Assets.xcassets` with proper folder structure
2. Create `.imageset` folders with required `Contents.json`
3. Generate asset reference guide in Swift

### Custom Asset Generation

You can also generate specific asset types individually:

```python
from pixellab_client import PixelLabClient

client = PixelLabClient(
    api_url="https://api.pixellab.ai/mcp",
    api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
)

# Generate a custom character
client.create_character(
    name="MyCharacter",
    description="A warrior with sword and shield",
    style="16-bit",
    view="top-down",
    size=64,
    color_palette=["#D4A574", "#8B4513", "#FFD700"]
)

# Generate a custom map object
client.create_map_object(
    name="MagicLamp",
    description="Golden lamp with mystical glow",
    object_type="prop",
    size=48,
    has_shadow=True
)
```

## File Structure

```
Scripts/AssetGeneration/
├── README.md                              # This file
├── requirements.txt                        # Python dependencies
├── pixellab_client.py                      # PixelLab API client
├── generate_desert_survivors_assets.py     # Main generation script
└── integrate_assets.py                     # Xcode integration script

GeneratedAssets/                            # Output directory
├── characters/                             # Character sprites
├── enemies/                                # Enemy sprites
├── animations/                             # Animation spritesheets
├── tilesets/                               # Tileset images
├── objects/                                # Map objects/props
├── asset_manifest.json                     # Asset metadata
└── ASSET_REFERENCE.md                      # Swift code reference

DesertSurvivors/Assets.xcassets/            # Xcode assets
├── Characters/                             # Integrated characters
├── Enemies/                                # Integrated enemies
├── Animations/                             # Integrated animations
├── Tilesets/                               # Integrated tilesets
├── MapObjects/                             # Integrated objects
└── UI/                                     # Integrated UI elements
```

## Generated Assets

### Characters (8 Total)
- Tariq - Desert warrior with dagger
- Amara - Nomad with staff
- Zahra - Mystical sorceress
- Khalid - Merchant guard
- Yasmin - Assassin
- Omar - Scholar
- Layla - Archer
- Hassan - Berber warrior

### Enemies (8 Total)
**Tier 1:**
- Sand Scarab
- Desert Rat
- Scorpion
- Dust Sprite

**Tier 2:**
- Mummified Wanderer
- Sand Cobra
- Desert Bandit
- Cursed Jackal

### Animations
Each character includes:
- Idle (4 frames)
- Walk (Up/Down/Left/Right, 4 frames each)
- Attack (4 frames)
- Hurt (4 frames)
- Death (4 frames)

### Tilesets
- **DesertGround**: Sand variations, dunes, rocky terrain
- **DesertFeatures**: Rocks, boulders, sand piles
- **Oasis**: Water, grass, palm bases

### Map Objects (20+ Total)
- Vegetation: Cacti, palms, bushes
- Geology: Rocks, boulders, dunes
- Ruins: Columns, walls, obelisks, tombs
- Bones: Skulls, ribcages, skeletons
- Props: Chests, campfires, tents
- Atmospheric: Dust devils, footprints

### UI Elements
- XP Gems (Blue, Green, Red)
- Gold Coin
- Health Potion
- Heart Icon

## Using Assets in Swift

After integration, reference assets in your code:

```swift
// Characters
let tariqSprite = SKTexture(imageNamed: "Tariq")

// Enemies
let scarabSprite = SKTexture(imageNamed: "SandScarab")

// Map Objects
let cactusSprite = SKTexture(imageNamed: "Cactus_Large")

// UI Elements
let xpGemSprite = SKTexture(imageNamed: "XP_Gem_Blue")
```

For animations, you'll need to slice the spritesheet:

```swift
// Load animation spritesheet
let spritesheet = SKTexture(imageNamed: "Tariq_animations")

// Extract individual frames (example for 64x64 sprites)
func extractFrame(row: Int, col: Int, frameSize: CGSize) -> SKTexture {
    let x = CGFloat(col) * frameSize.width / spritesheet.size().width
    let y = CGFloat(row) * frameSize.height / spritesheet.size().height
    let width = frameSize.width / spritesheet.size().width
    let height = frameSize.height / spritesheet.size().height

    return SKTexture(rect: CGRect(x: x, y: y, width: width, height: height),
                    in: spritesheet)
}
```

## Troubleshooting

### MCP Server Not Connected

If `claude mcp list` shows disconnected:

```bash
claude mcp remove pixellab -s local
claude mcp add pixellab https://api.pixellab.ai/mcp \
  --transport http \
  --header "Authorization: Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867"
```

### API Rate Limiting

If you encounter rate limits, add delays between requests:

```python
import time

# In the generation loops
time.sleep(1)  # Wait 1 second between requests
```

### Asset Quality Issues

Adjust generation parameters:
- Increase `size` for higher resolution (32, 64, 128, 256)
- Modify `style` parameter ("8-bit", "16-bit", "32-bit")
- Refine `description` text for better results
- Adjust `color_palette` for different aesthetics

### Integration Errors

Ensure you're running from the project root and `Assets.xcassets` exists:

```bash
# From project root
ls DesertSurvivors/Assets.xcassets
```

## API Reference

### PixelLabClient Methods

#### `create_character(name, description, style, view, size, color_palette)`
Generate a character sprite.

**Parameters:**
- `name` (str): Asset name
- `description` (str): Detailed description of character appearance
- `style` (str): Pixel art style ("8-bit", "16-bit", "32-bit")
- `view` (str): Camera perspective ("top-down", "side", "isometric")
- `size` (int): Sprite dimensions in pixels (32, 64, 128, etc.)
- `color_palette` (list): Hex color values for sprite palette

#### `animate_character(character_name, animations, frames_per_animation, frame_duration)`
Generate animation spritesheet.

**Parameters:**
- `character_name` (str): Name of character to animate
- `animations` (list): Animation types (["idle", "walk", "attack"])
- `frames_per_animation` (int): Frames per animation
- `frame_duration` (float): Duration per frame in seconds

#### `create_tileset(name, tileset_type, tiles, tile_size, variations)`
Generate tileset.

**Parameters:**
- `name` (str): Tileset name
- `tileset_type` (str): Type ("top-down", "sidescroller", "isometric")
- `tiles` (list): Tile types to generate
- `tile_size` (int): Individual tile size in pixels
- `variations` (int): Number of variations per tile

#### `create_map_object(name, description, object_type, size, has_shadow)`
Generate map object/prop.

**Parameters:**
- `name` (str): Object name
- `description` (str): Detailed description
- `object_type` (str): Type ("prop", "decoration", "obstacle")
- `size` (int): Object dimensions in pixels
- `has_shadow` (bool): Include drop shadow

## Next Steps

1. **Run generation script** to create all assets
2. **Run integration script** to add to Xcode
3. **Update sprite references** in Swift code
4. **Create animation systems** to use spritesheets
5. **Implement tilemap rendering** for tilesets
6. **Test assets** in game

## Support

- PixelLab API Docs: https://api.pixellab.ai/docs
- MCP Protocol: https://modelcontextprotocol.io
- Claude Code MCP: `claude mcp --help`
