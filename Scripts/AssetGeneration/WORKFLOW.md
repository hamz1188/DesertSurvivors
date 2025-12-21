# PixelLab Asset Generation Workflow

Complete programmatic workflow for generating Desert Survivors game assets using the PixelLab MCP API.

## Quick Start

The fastest way to generate all assets:

```bash
cd Scripts/AssetGeneration
./quick_start.sh
```

This interactive script will:
1. Install Python dependencies
2. Test PixelLab MCP connection
3. Generate all game assets
4. Integrate assets into Xcode project

## Manual Workflow

### Step 1: Setup

```bash
cd Scripts/AssetGeneration
pip3 install -r requirements.txt
```

### Step 2: Verify Connection

```bash
python3 test_connection.py
```

**Expected output:**
```
TESTING PIXELLAB MCP CONNECTION
================================

1. Initializing PixelLab client...
   ✓ Client initialized

2. Fetching available tools...
   ✓ Connection successful!
   Found X available tools

AVAILABLE PIXELLAB TOOLS
========================
[List of tools and their parameters]
```

### Step 3: Generate Assets

Generate all Desert Survivors assets:

```bash
python3 generate_desert_survivors_assets.py
```

**What gets generated:**

| Category | Count | Examples |
|----------|-------|----------|
| Characters | 8 | Tariq, Amara, Zahra, Khalid, Yasmin, Omar, Layla, Hassan |
| Enemies | 8 | Sand Scarab, Scorpion, Mummified Wanderer, Sand Cobra |
| Animations | 8 | Character spritesheets with idle/walk/attack/hurt/death |
| Tilesets | 3 | DesertGround, DesertFeatures, Oasis |
| Map Objects | 20+ | Cacti, rocks, ruins, bones, chests, tents |
| UI Elements | 6 | XP gems, coins, potions, hearts |

**Output structure:**
```
GeneratedAssets/
├── characters/
│   ├── Tariq.png
│   ├── Amara.png
│   └── ...
├── enemies/
│   ├── SandScarab.png
│   ├── Scorpion.png
│   └── ...
├── animations/
│   ├── Tariq_spritesheet.png
│   └── ...
├── tilesets/
│   ├── DesertGround_top-down.png
│   └── ...
├── objects/
│   ├── Cactus_Large.png
│   └── ...
└── asset_manifest.json
```

### Step 4: Integrate into Xcode

```bash
python3 integrate_assets.py
```

This will:
- Copy all assets to `Assets.xcassets`
- Create proper folder structure (Characters/, Enemies/, etc.)
- Generate `.imageset` folders with `Contents.json`
- Create Swift reference guide

**Result:**
```
DesertSurvivors/Assets.xcassets/
├── Characters/
│   ├── Tariq.imageset/
│   │   ├── Tariq.png
│   │   └── Contents.json
│   └── ...
├── Enemies/
├── Animations/
├── Tilesets/
├── MapObjects/
└── UI/
```

### Step 5: Use in Swift Code

Reference the guide:

```bash
cat GeneratedAssets/ASSET_REFERENCE.md
```

Example usage:

```swift
// In your Player.swift or GameScene.swift
let tariqTexture = SKTexture(imageNamed: "Tariq")
let playerSprite = SKSpriteNode(texture: tariqTexture)

// Load enemy
let scarabTexture = SKTexture(imageNamed: "SandScarab")
let enemySprite = SKSpriteNode(texture: scarabTexture)

// Load map object
let cactusTexture = SKTexture(imageNamed: "Cactus_Large")
let cactusNode = SKSpriteNode(texture: cactusTexture)
```

## Custom Asset Generation

### Generate a Single Character

```python
from pixellab_client import PixelLabClient

client = PixelLabClient(
    api_url="https://api.pixellab.ai/mcp",
    api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
)

# Create custom character
client.create_character(
    name="CustomHero",
    description="Heroic knight with golden armor and red cape",
    style="16-bit",
    view="top-down",
    size=64,
    color_palette=["#FFD700", "#DC143C", "#C0C0C0"]
)
```

### Generate Specific Tileset

```python
client.create_tileset(
    name="CaveTiles",
    tileset_type="top-down",
    tiles=["stone_floor", "wall", "stalagmite", "crystal"],
    tile_size=64,
    variations=3
)
```

### Generate Props

```python
client.create_map_object(
    name="TreasureChest",
    description="Ornate golden chest with jewels and lock",
    object_type="prop",
    size=64,
    has_shadow=True
)
```

## Asset Specifications

### Character Specifications
- **Size**: 64x64 pixels
- **Style**: 16-bit pixel art
- **View**: Top-down perspective
- **Format**: PNG with transparency
- **Color Palette**: 4-8 colors per character

### Enemy Specifications
- **Size**: 48x48 pixels (smaller than player)
- **Style**: 16-bit pixel art
- **View**: Top-down perspective
- **Format**: PNG with transparency

### Animation Specifications
- **Spritesheet Layout**: Horizontal strips per animation
- **Frames**: 4 per animation type
- **Animations**: idle, walk_up, walk_down, walk_left, walk_right, attack, hurt, death
- **Frame Duration**: 0.15 seconds
- **Total Frames**: 32 per character (8 animations × 4 frames)

### Tileset Specifications
- **Tile Size**: 64x64 pixels
- **Variations**: 3-4 per tile type
- **Format**: Single PNG with grid layout
- **Seamless**: Tiles designed to connect seamlessly

### Map Object Specifications
- **Sizes**: 32px (small), 48px (medium), 64px (large), 96-128px (very large)
- **Shadow**: Automatic drop shadow generation
- **Format**: PNG with transparency
- **Orientation**: Top-down appropriate

## Advanced Usage

### Batch Generation with Custom Parameters

```python
from pixellab_client import PixelLabClient

client = PixelLabClient(
    api_url="https://api.pixellab.ai/mcp",
    api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
)

# Generate weapon icons
weapons = [
    {"name": "Scimitar", "desc": "Curved Arabian sword with gold handle"},
    {"name": "MagicStaff", "desc": "Ornate staff with glowing crystal"},
    {"name": "Bow", "desc": "Recurve bow with decorative patterns"}
]

for weapon in weapons:
    client.create_map_object(
        name=weapon["name"],
        description=weapon["desc"],
        object_type="prop",
        size=32,
        has_shadow=False  # UI icons don't need shadows
    )
```

### Modify Existing Workflow

Edit `generate_desert_survivors_assets.py` to:
- Add new characters to the `characters` list
- Add new enemy types to `enemies` list
- Add custom map objects to `objects` list
- Adjust sizes, colors, or descriptions

Example - Adding a new character:

```python
# In generate_desert_survivors_assets.py, add to characters list:
{
    "name": "Fatima",
    "description": "Young mage apprentice with spell book and wand",
    "palette": ["#E6C9A8", "#6A0DAD", "#00FFFF", "#2F4F4F"]
}
```

Then re-run the generation script.

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     PixelLab MCP API                        │
│                  (api.pixellab.ai/mcp)                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ MCP Protocol (HTTPS)
                           │
┌──────────────────────────▼──────────────────────────────────┐
│              pixellab_client.py                             │
│  • create_character()                                       │
│  • animate_character()                                      │
│  • create_tileset()                                         │
│  • create_map_object()                                      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Python API
                           │
┌──────────────────────────▼──────────────────────────────────┐
│      generate_desert_survivors_assets.py                    │
│  • Generate 8 characters                                    │
│  • Generate 8 enemies                                       │
│  • Generate animations                                      │
│  • Generate tilesets                                        │
│  • Generate 20+ map objects                                 │
│  • Generate UI elements                                     │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ Save to disk
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  GeneratedAssets/                           │
│  ├── characters/                                            │
│  ├── enemies/                                               │
│  ├── animations/                                            │
│  ├── tilesets/                                              │
│  ├── objects/                                               │
│  └── asset_manifest.json                                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ integrate_assets.py
                           │
┌──────────────────────────▼──────────────────────────────────┐
│            DesertSurvivors/Assets.xcassets/                 │
│  ├── Characters/*.imageset                                  │
│  ├── Enemies/*.imageset                                     │
│  ├── Animations/*.imageset                                  │
│  ├── Tilesets/*.imageset                                    │
│  ├── MapObjects/*.imageset                                  │
│  └── UI/*.imageset                                          │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ SKTexture(imageNamed:)
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    Swift/SpriteKit Code                     │
│  • Player.swift                                             │
│  • BaseEnemy.swift                                          │
│  • GameScene.swift                                          │
│  • WorldManager.swift                                       │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Connection Issues

**Problem**: `Connection test failed`

**Solutions**:
1. Verify MCP server configuration:
   ```bash
   claude mcp list
   ```
2. Re-add if needed:
   ```bash
   claude mcp remove pixellab -s local
   claude mcp add pixellab https://api.pixellab.ai/mcp \
     --transport http \
     --header "Authorization: Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867"
   ```

### Rate Limiting

**Problem**: `429 Too Many Requests`

**Solution**: Add delays in generation script:

```python
import time

# In generation loops
for char in characters:
    # ... generate asset ...
    time.sleep(2)  # Wait 2 seconds between requests
```

### Asset Quality

**Problem**: Generated assets don't match expectations

**Solutions**:
1. Refine descriptions with more detail
2. Adjust color palettes
3. Try different size parameters
4. Specify style more precisely ("pixel art", "retro", "detailed")

### Integration Errors

**Problem**: `Assets.xcassets not found`

**Solution**: Ensure you're in the project root:
```bash
cd /Users/hameli/.claude-worktrees/DesertSurvivors/busy-proskuriakova
python3 Scripts/AssetGeneration/integrate_assets.py
```

## Performance Tips

1. **Parallel Generation**: Modify script to use `concurrent.futures` for faster generation
2. **Cache Results**: Don't regenerate existing assets
3. **Batch Processing**: Group similar requests together
4. **Selective Generation**: Comment out sections you don't need

## Asset Maintenance

### Updating Assets

To regenerate specific assets:

```python
from pixellab_client import PixelLabClient

client = PixelLabClient(
    api_url="https://api.pixellab.ai/mcp",
    api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
)

# Regenerate just one character with updated description
client.create_character(
    name="Tariq",
    description="Updated: Young Arabian warrior with NEW ornate armor",
    style="16-bit",
    view="top-down",
    size=64
)
```

### Version Control

Add to `.gitignore`:
```
GeneratedAssets/
*.pyc
__pycache__/
```

Keep in version control:
```
Scripts/AssetGeneration/*.py
Scripts/AssetGeneration/*.sh
Scripts/AssetGeneration/*.md
Scripts/AssetGeneration/requirements.txt
```

## Next Steps

1. ✓ Run `./quick_start.sh` to generate all assets
2. ✓ Verify assets in `GeneratedAssets/` directory
3. ✓ Check Xcode integration in `Assets.xcassets`
4. Update Swift code to use new assets:
   - Replace placeholder sprites in `Player.swift`
   - Update enemy sprites in `BaseEnemy.swift`
   - Implement tilemap system in `WorldManager.swift`
5. Create animation controller for character spritesheets
6. Test in simulator
7. Refine and regenerate as needed

## Resources

- **PixelLab API**: https://api.pixellab.ai
- **MCP Protocol**: https://modelcontextprotocol.io
- **Claude MCP Docs**: `claude mcp --help`
- **SpriteKit Docs**: https://developer.apple.com/spritekit/
