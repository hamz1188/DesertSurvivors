#!/usr/bin/env python3
"""
PixelLab MCP Client
Programmatically generate game assets using the PixelLab API via MCP protocol
"""

import requests
import json
import os
from pathlib import Path
from typing import Dict, List, Optional, Any

class PixelLabClient:
    """Client for interacting with PixelLab MCP API"""

    def __init__(self, api_url: str, api_key: str):
        self.api_url = api_url
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        self.output_dir = Path("GeneratedAssets")
        self.output_dir.mkdir(exist_ok=True)

    def _make_request(self, method: str, params: Dict[str, Any]) -> Dict:
        """Make MCP protocol request to PixelLab API"""
        payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": method,
            "params": params
        }

        response = requests.post(
            self.api_url,
            headers=self.headers,
            json=payload
        )
        response.raise_for_status()
        return response.json()

    def list_tools(self) -> List[Dict]:
        """List all available PixelLab tools"""
        result = self._make_request("tools/list", {})
        return result.get("result", {}).get("tools", [])

    def create_character(
        self,
        name: str,
        description: str,
        style: str = "16-bit",
        view: str = "top-down",
        size: int = 64,
        color_palette: Optional[List[str]] = None
    ) -> str:
        """Generate a character sprite"""
        params = {
            "name": name,
            "description": description,
            "style": style,
            "view": view,
            "size": size,
        }
        if color_palette:
            params["color_palette"] = color_palette

        result = self._make_request("tools/call", {
            "name": "create_character",
            "arguments": params
        })

        return self._save_asset(result, f"characters/{name}.png")

    def animate_character(
        self,
        character_name: str,
        animations: List[str],  # e.g., ["idle", "walk", "attack", "death"]
        frames_per_animation: int = 4,
        frame_duration: float = 0.1
    ) -> str:
        """Generate character animation sprite sheet"""
        params = {
            "character_name": character_name,
            "animations": animations,
            "frames_per_animation": frames_per_animation,
            "frame_duration": frame_duration
        }

        result = self._make_request("tools/call", {
            "name": "animate_character",
            "arguments": params
        })

        return self._save_asset(result, f"animations/{character_name}_spritesheet.png")

    def create_tileset(
        self,
        name: str,
        tileset_type: str,  # "top-down", "sidescroller", "isometric"
        tiles: List[str],  # e.g., ["sand", "dune", "rock", "oasis"]
        tile_size: int = 64,
        variations: int = 3
    ) -> str:
        """Generate tileset"""
        params = {
            "name": name,
            "type": tileset_type,
            "tiles": tiles,
            "tile_size": tile_size,
            "variations": variations
        }

        result = self._make_request("tools/call", {
            "name": "create_tileset",
            "arguments": params
        })

        return self._save_asset(result, f"tilesets/{name}_{tileset_type}.png")

    def create_map_object(
        self,
        name: str,
        description: str,
        object_type: str = "prop",  # "prop", "decoration", "obstacle"
        size: int = 64,
        has_shadow: bool = True
    ) -> str:
        """Generate map object/prop"""
        params = {
            "name": name,
            "description": description,
            "type": object_type,
            "size": size,
            "has_shadow": has_shadow
        }

        result = self._make_request("tools/call", {
            "name": "create_map_object",
            "arguments": params
        })

        return self._save_asset(result, f"objects/{name}.png")

    def _save_asset(self, result: Dict, relative_path: str) -> str:
        """Save generated asset to file"""
        asset_data = result.get("result", {})

        # Check if result contains image data (base64 or URL)
        if "image_data" in asset_data:
            import base64
            image_data = base64.b64decode(asset_data["image_data"])
            output_path = self.output_dir / relative_path
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, "wb") as f:
                f.write(image_data)

            return str(output_path)

        elif "image_url" in asset_data:
            # Download from URL
            image_response = requests.get(asset_data["image_url"])
            image_response.raise_for_status()

            output_path = self.output_dir / relative_path
            output_path.parent.mkdir(parents=True, exist_ok=True)

            with open(output_path, "wb") as f:
                f.write(image_response.content)

            return str(output_path)

        else:
            raise ValueError(f"Unexpected result format: {asset_data}")


def main():
    """Example usage of PixelLabClient"""
    # Initialize client
    client = PixelLabClient(
        api_url="https://api.pixellab.ai/mcp",
        api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
    )

    # List available tools
    print("Available PixelLab tools:")
    tools = client.list_tools()
    for tool in tools:
        print(f"  - {tool.get('name')}: {tool.get('description')}")
    print()


if __name__ == "__main__":
    main()
