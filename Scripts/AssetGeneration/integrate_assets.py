#!/usr/bin/env python3
"""
Asset Integration Script
Automatically import generated assets into Xcode Assets.xcassets
"""

import json
import shutil
from pathlib import Path
import os

class AssetIntegrator:
    """Integrate generated assets into Xcode project"""

    def __init__(self, project_root: str = None):
        if project_root is None:
            self.project_root = Path(__file__).parent.parent.parent
        else:
            self.project_root = Path(project_root)

        self.generated_assets = self.project_root / "GeneratedAssets"
        self.xcassets_path = self.project_root / "DesertSurvivors" / "Assets.xcassets"
        self.manifest_path = self.generated_assets / "asset_manifest.json"

    def load_manifest(self):
        """Load the asset manifest"""
        if not self.manifest_path.exists():
            raise FileNotFoundError(f"Asset manifest not found at {self.manifest_path}")

        with open(self.manifest_path, "r") as f:
            return json.load(f)

    def create_imageset(self, asset_name: str, image_path: Path, category: str):
        """Create an .imageset folder in Assets.xcassets"""
        # Create category folder if needed
        category_path = self.xcassets_path / category
        category_path.mkdir(exist_ok=True)

        # Create imageset folder
        imageset_name = f"{asset_name}.imageset"
        imageset_path = category_path / imageset_name
        imageset_path.mkdir(exist_ok=True)

        # Copy image file
        dest_image = imageset_path / f"{asset_name}.png"
        shutil.copy2(image_path, dest_image)

        # Create Contents.json
        contents = {
            "images": [
                {
                    "filename": f"{asset_name}.png",
                    "idiom": "universal",
                    "scale": "1x"
                },
                {
                    "idiom": "universal",
                    "scale": "2x"
                },
                {
                    "idiom": "universal",
                    "scale": "3x"
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            },
            "properties": {
                "preserves-vector-representation": False
            }
        }

        contents_path = imageset_path / "Contents.json"
        with open(contents_path, "w") as f:
            json.dump(contents, f, indent=2)

        return str(imageset_path)

    def integrate_all(self):
        """Integrate all assets from manifest"""
        print("=" * 60)
        print("INTEGRATING ASSETS INTO XCODE PROJECT")
        print("=" * 60)

        if not self.xcassets_path.exists():
            print(f"✗ Error: Assets.xcassets not found at {self.xcassets_path}")
            print("  Please ensure you're running from the project root")
            return

        manifest = self.load_manifest()
        print(f"\nFound {len(manifest)} assets to integrate\n")

        # Group assets by type
        assets_by_type = {}
        for asset in manifest:
            asset_type = asset["type"]
            if asset_type not in assets_by_type:
                assets_by_type[asset_type] = []
            assets_by_type[asset_type].append(asset)

        # Integrate each type
        total_integrated = 0

        for asset_type, assets in assets_by_type.items():
            print(f"\n{asset_type.upper().replace('_', ' ')}:")
            print("-" * 40)

            for asset in assets:
                try:
                    image_path = self.project_root / asset["path"]
                    if not image_path.exists():
                        print(f"  ✗ {asset['name']}: File not found at {image_path}")
                        continue

                    # Determine category folder
                    category_map = {
                        "character": "Characters",
                        "enemy": "Enemies",
                        "animation": "Animations",
                        "tileset": "Tilesets",
                        "map_object": "MapObjects",
                        "ui_element": "UI"
                    }
                    category = category_map.get(asset_type, "Generated")

                    imageset_path = self.create_imageset(
                        asset["name"],
                        image_path,
                        category
                    )
                    print(f"  ✓ {asset['name']}: Integrated to {category}/")
                    total_integrated += 1

                except Exception as e:
                    print(f"  ✗ {asset['name']}: Error - {e}")

        print("\n" + "=" * 60)
        print(f"INTEGRATION COMPLETE: {total_integrated}/{len(manifest)} assets")
        print("=" * 60)
        print(f"\nAssets location: {self.xcassets_path}")
        print("\nNext steps:")
        print("  1. Open Xcode project")
        print("  2. Update sprite references in code to use new asset names")
        print("  3. Test in simulator/device")

    def create_asset_reference_guide(self):
        """Create a reference guide for using assets in code"""
        manifest = self.load_manifest()

        guide_path = self.generated_assets / "ASSET_REFERENCE.md"
        with open(guide_path, "w") as f:
            f.write("# Desert Survivors Asset Reference\n\n")
            f.write("This guide shows how to reference generated assets in Swift code.\n\n")

            # Group by type
            assets_by_type = {}
            for asset in manifest:
                asset_type = asset["type"]
                if asset_type not in assets_by_type:
                    assets_by_type[asset_type] = []
                assets_by_type[asset_type].append(asset["name"])

            # Characters
            if "character" in assets_by_type:
                f.write("## Characters\n\n")
                f.write("```swift\n")
                for name in assets_by_type["character"]:
                    f.write(f'let {name.lower()}Sprite = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

            # Enemies
            if "enemy" in assets_by_type:
                f.write("## Enemies\n\n")
                f.write("```swift\n")
                for name in assets_by_type["enemy"]:
                    f.write(f'let {name.lower()}Sprite = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

            # Animations
            if "animation" in assets_by_type:
                f.write("## Animations\n\n")
                f.write("```swift\n")
                f.write("// Animation spritesheets - use SKTextureAtlas or slice manually\n")
                for name in assets_by_type["animation"]:
                    f.write(f'let {name.lower()}Atlas = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

            # Tilesets
            if "tileset" in assets_by_type:
                f.write("## Tilesets\n\n")
                f.write("```swift\n")
                for name in assets_by_type["tileset"]:
                    f.write(f'let {name.lower()} = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

            # Map Objects
            if "map_object" in assets_by_type:
                f.write("## Map Objects\n\n")
                f.write("```swift\n")
                for name in assets_by_type["map_object"]:
                    safe_name = name.replace("_", "").lower()
                    f.write(f'let {safe_name}Sprite = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

            # UI Elements
            if "ui_element" in assets_by_type:
                f.write("## UI Elements\n\n")
                f.write("```swift\n")
                for name in assets_by_type["ui_element"]:
                    safe_name = name.replace("_", "").lower()
                    f.write(f'let {safe_name}Icon = SKTexture(imageNamed: "{name}")\n')
                f.write("```\n\n")

        print(f"\n✓ Asset reference guide created: {guide_path}")


def main():
    integrator = AssetIntegrator()
    integrator.integrate_all()
    integrator.create_asset_reference_guide()


if __name__ == "__main__":
    main()
