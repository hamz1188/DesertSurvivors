#!/usr/bin/env python3
"""
Desert Survivors Asset Generation
Generate all game assets using PixelLab MCP API
"""

from pixellab_client import PixelLabClient
import json
from pathlib import Path

class DesertSurvivorsAssetGenerator:
    """Generate all assets for Desert Survivors game"""

    def __init__(self):
        self.client = PixelLabClient(
            api_url="https://api.pixellab.ai/mcp",
            api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
        )
        self.asset_manifest = []

    def generate_all_characters(self):
        """Generate all playable character sprites"""
        print("=" * 60)
        print("GENERATING PLAYABLE CHARACTERS")
        print("=" * 60)

        characters = [
            {
                "name": "Tariq",
                "description": "Young Arabian warrior with curved dagger, wearing desert robes and turban, tan skin, determined expression",
                "palette": ["#D4A574", "#8B4513", "#FFD700", "#2C1810"]
            },
            {
                "name": "Amara",
                "description": "Fierce desert nomad woman with flowing robes, headscarf, carrying staff, athletic build",
                "palette": ["#C19A6B", "#8B0000", "#FFD700", "#1A1A1A"]
            },
            {
                "name": "Zahra",
                "description": "Mystical sorceress with ornate robes, jeweled headpiece, holding magical orb, elegant stance",
                "palette": ["#DEB887", "#4B0082", "#00CED1", "#2F4F4F"]
            },
            {
                "name": "Khalid",
                "description": "Burly merchant guard with scimitar, chainmail under robes, stocky build, gruff appearance",
                "palette": ["#BC8F8F", "#8B4513", "#C0C0C0", "#2C2C2C"]
            },
            {
                "name": "Yasmin",
                "description": "Agile assassin with dual daggers, dark leather outfit, face veil, crouched stance",
                "palette": ["#A0826D", "#000000", "#DC143C", "#4A4A4A"]
            },
            {
                "name": "Omar",
                "description": "Wise scholar with ancient tome, spectacles, long robes with arcane symbols, elderly",
                "palette": ["#D2B48C", "#191970", "#DAA520", "#696969"]
            },
            {
                "name": "Layla",
                "description": "Swift archer with ornate bow, quiver of arrows, light armor, focused expression",
                "palette": ["#C9A87C", "#228B22", "#8B4513", "#3E2723"]
            },
            {
                "name": "Hassan",
                "description": "Berber warrior with spear and shield, tribal tattoos, muscular build, battle-scarred",
                "palette": ["#8B7355", "#800000", "#FFD700", "#1C1C1C"]
            }
        ]

        for char in characters:
            print(f"\nGenerating {char['name']}...")
            try:
                output_path = self.client.create_character(
                    name=char["name"],
                    description=char["description"],
                    style="16-bit",
                    view="top-down",
                    size=64,
                    color_palette=char["palette"]
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "character",
                    "name": char["name"],
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def generate_all_enemies(self):
        """Generate all enemy sprites"""
        print("\n" + "=" * 60)
        print("GENERATING ENEMIES")
        print("=" * 60)

        enemies = [
            # Tier 1
            {"name": "SandScarab", "description": "Large golden beetle with mandibles, iridescent shell, small legs"},
            {"name": "DesertRat", "description": "Scrappy rodent with matted fur, sharp teeth, scurrying pose"},
            {"name": "Scorpion", "description": "Black scorpion with raised stinger tail, pincers extended, menacing"},
            {"name": "DustSprite", "description": "Wispy sand elemental, swirling particles forming vague humanoid shape"},
            # Tier 2
            {"name": "MummifiedWanderer", "description": "Shambling mummy with tattered bandages, glowing eyes, ancient armor pieces"},
            {"name": "SandCobra", "description": "Hooded cobra with golden scales, raised strike pose, venomous fangs"},
            {"name": "DesertBandit", "description": "Masked raider with scimitar, worn leather armor, threatening stance"},
            {"name": "CursedJackal", "description": "Spectral jackal with ethereal blue glow, torn flesh, supernatural aura"}
        ]

        for enemy in enemies:
            print(f"\nGenerating {enemy['name']}...")
            try:
                output_path = self.client.create_character(
                    name=enemy["name"],
                    description=enemy["description"],
                    style="16-bit",
                    view="top-down",
                    size=48
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "enemy",
                    "name": enemy["name"],
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def generate_all_animations(self):
        """Generate animation spritesheets for characters"""
        print("\n" + "=" * 60)
        print("GENERATING CHARACTER ANIMATIONS")
        print("=" * 60)

        characters = ["Tariq", "Amara", "Zahra", "Khalid", "Yasmin", "Omar", "Layla", "Hassan"]
        animations = ["idle", "walk_up", "walk_down", "walk_left", "walk_right", "attack", "hurt", "death"]

        for char_name in characters:
            print(f"\nGenerating animations for {char_name}...")
            try:
                output_path = self.client.animate_character(
                    character_name=char_name,
                    animations=animations,
                    frames_per_animation=4,
                    frame_duration=0.15
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "animation",
                    "name": f"{char_name}_animations",
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def generate_all_tilesets(self):
        """Generate desert environment tilesets"""
        print("\n" + "=" * 60)
        print("GENERATING TILESETS")
        print("=" * 60)

        tilesets = [
            {
                "name": "DesertGround",
                "type": "top-down",
                "tiles": ["sand_light", "sand_dark", "sand_ripple", "dune_edge", "rocky_sand", "compact_sand"],
                "tile_size": 64,
                "variations": 4
            },
            {
                "name": "DesertFeatures",
                "type": "top-down",
                "tiles": ["rock_small", "rock_medium", "rock_large", "boulder", "sand_pile", "cracked_earth"],
                "tile_size": 64,
                "variations": 3
            },
            {
                "name": "Oasis",
                "type": "top-down",
                "tiles": ["water_edge", "water_center", "grass_patch", "palm_base", "mud"],
                "tile_size": 64,
                "variations": 2
            }
        ]

        for tileset in tilesets:
            print(f"\nGenerating {tileset['name']} tileset...")
            try:
                output_path = self.client.create_tileset(
                    name=tileset["name"],
                    tileset_type=tileset["type"],
                    tiles=tileset["tiles"],
                    tile_size=tileset["tile_size"],
                    variations=tileset["variations"]
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "tileset",
                    "name": tileset["name"],
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def generate_all_map_objects(self):
        """Generate map objects and props"""
        print("\n" + "=" * 60)
        print("GENERATING MAP OBJECTS")
        print("=" * 60)

        objects = [
            # Vegetation
            {"name": "Cactus_Small", "description": "Small saguaro cactus with spines, green with subtle shading", "type": "obstacle", "size": 48},
            {"name": "Cactus_Large", "description": "Tall multi-armed saguaro cactus, desert green, cast shadow", "type": "obstacle", "size": 96},
            {"name": "DeadBush", "description": "Dried thorny tumbleweed, brown and withered", "type": "decoration", "size": 32},
            {"name": "PalmTree", "description": "Date palm with fronds, oasis vegetation", "type": "obstacle", "size": 128},

            # Rocks and Geology
            {"name": "Rock_Small", "description": "Small desert rock, weathered sandstone texture", "type": "decoration", "size": 32},
            {"name": "Rock_Medium", "description": "Medium boulder, tan/brown with cracks", "type": "obstacle", "size": 64},
            {"name": "Rock_Large", "description": "Large rocky outcrop, layered sediment visible", "type": "obstacle", "size": 96},
            {"name": "SandDune", "description": "Curved sand dune with windswept texture", "type": "decoration", "size": 128},

            # Ruins and Structures
            {"name": "BrokenColumn", "description": "Ancient crumbled stone pillar, hieroglyphs visible", "type": "obstacle", "size": 64},
            {"name": "RuinWall", "description": "Partial sandstone wall, weathered bricks", "type": "obstacle", "size": 96},
            {"name": "Obelisk", "description": "Small damaged obelisk with hieroglyphs", "type": "obstacle", "size": 80},
            {"name": "Tomb_Entrance", "description": "Stone doorway half-buried in sand", "type": "obstacle", "size": 128},

            # Bones and Remains
            {"name": "Skull_Animal", "description": "Bleached animal skull, desert weathered", "type": "decoration", "size": 32},
            {"name": "Bones_Ribcage", "description": "Large animal ribcage half-buried", "type": "decoration", "size": 64},
            {"name": "Skeleton", "description": "Complete skeleton laid out on sand", "type": "decoration", "size": 96},

            # Interactive Objects
            {"name": "Chest_Wooden", "description": "Weathered wooden chest with metal bands", "type": "prop", "size": 48},
            {"name": "Chest_Gold", "description": "Ornate golden treasure chest with gems", "type": "prop", "size": 64},
            {"name": "Campfire", "description": "Stone circle with wood pile and ember glow", "type": "prop", "size": 48},
            {"name": "TentBedouin", "description": "Traditional striped nomad tent", "type": "prop", "size": 128},

            # Atmospheric
            {"name": "SandSwirl", "description": "Small dust devil particle effect", "type": "decoration", "size": 64},
            {"name": "Footprints", "description": "Trail of footprints in sand", "type": "decoration", "size": 32}
        ]

        for obj in objects:
            print(f"\nGenerating {obj['name']}...")
            try:
                output_path = self.client.create_map_object(
                    name=obj["name"],
                    description=obj["description"],
                    object_type=obj["type"],
                    size=obj["size"],
                    has_shadow=True
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "map_object",
                    "name": obj["name"],
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def generate_ui_elements(self):
        """Generate UI icons and elements"""
        print("\n" + "=" * 60)
        print("GENERATING UI ELEMENTS")
        print("=" * 60)

        ui_elements = [
            {"name": "XP_Gem_Blue", "description": "Glowing blue crystal gem, faceted", "size": 16},
            {"name": "XP_Gem_Green", "description": "Glowing green crystal gem, faceted", "size": 16},
            {"name": "XP_Gem_Red", "description": "Glowing red crystal gem, faceted", "size": 16},
            {"name": "Gold_Coin", "description": "Golden coin with Arabic script", "size": 16},
            {"name": "Health_Potion", "description": "Red healing potion in ornate bottle", "size": 32},
            {"name": "Heart_Icon", "description": "Pixel art heart for health display", "size": 16},
        ]

        for elem in ui_elements:
            print(f"\nGenerating {elem['name']}...")
            try:
                output_path = self.client.create_map_object(
                    name=elem["name"],
                    description=elem["description"],
                    object_type="prop",
                    size=elem["size"],
                    has_shadow=False
                )
                print(f"  ✓ Saved to: {output_path}")
                self.asset_manifest.append({
                    "type": "ui_element",
                    "name": elem["name"],
                    "path": output_path
                })
            except Exception as e:
                print(f"  ✗ Error: {e}")

    def save_manifest(self):
        """Save asset manifest to JSON"""
        manifest_path = Path("GeneratedAssets/asset_manifest.json")
        with open(manifest_path, "w") as f:
            json.dump(self.asset_manifest, f, indent=2)
        print(f"\n✓ Asset manifest saved to: {manifest_path}")

    def generate_all(self):
        """Generate all assets"""
        print("\n" + "=" * 60)
        print("DESERT SURVIVORS ASSET GENERATION")
        print("=" * 60)
        print("\nThis will generate all game assets using PixelLab API")
        print("Estimated time: 5-10 minutes")
        print("=" * 60 + "\n")

        self.generate_all_characters()
        self.generate_all_enemies()
        self.generate_all_animations()
        self.generate_all_tilesets()
        self.generate_all_map_objects()
        self.generate_ui_elements()
        self.save_manifest()

        print("\n" + "=" * 60)
        print("ASSET GENERATION COMPLETE!")
        print("=" * 60)
        print(f"Total assets generated: {len(self.asset_manifest)}")
        print("\nAssets saved to: GeneratedAssets/")
        print("Manifest: GeneratedAssets/asset_manifest.json")


def main():
    generator = DesertSurvivorsAssetGenerator()
    generator.generate_all()


if __name__ == "__main__":
    main()
