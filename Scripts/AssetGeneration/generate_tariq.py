#!/usr/bin/env python3
"""
Generate Tariq character sprite using PixelLab API
"""

import requests
import json
import sys
from pathlib import Path

def generate_tariq():
    """Generate Tariq character sprite"""
    print("=" * 60)
    print("GENERATING TARIQ CHARACTER")
    print("=" * 60)

    api_url = "https://api.pixellab.ai/mcp"
    headers = {
        "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867",
        "Content-Type": "application/json"
    }

    # Character specification
    character_spec = {
        "name": "Tariq",
        "description": "Young Arabian warrior with curved dagger, wearing flowing desert robes and turban, tan skin, determined expression",
        "style": "16-bit",
        "view": "high top-down",  # Changed from "top-down" to "high top-down"
        "size": 64,
        "color_palette": ["#D4A574", "#8B4513", "#FFD700", "#2C1810"]
    }

    print("\nCharacter Specifications:")
    print(f"  Name: {character_spec['name']}")
    print(f"  Description: {character_spec['description']}")
    print(f"  Style: {character_spec['style']}")
    print(f"  Size: {character_spec['size']}x{character_spec['size']}")
    print(f"  Colors: {', '.join(character_spec['color_palette'])}")
    print()

    # Try different API endpoints/formats
    endpoints_to_try = [
        # Standard MCP format
        {
            "payload": {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "tools/call",
                "params": {
                    "name": "create_character",
                    "arguments": character_spec
                }
            }
        },
        # Direct API format
        {
            "payload": {
                "action": "create_character",
                "params": character_spec
            }
        },
        # Alternative format
        {
            "payload": character_spec
        }
    ]

    for i, endpoint in enumerate(endpoints_to_try, 1):
        print(f"Attempt {i}/{len(endpoints_to_try)}...")
        try:
            response = requests.post(
                api_url,
                headers=headers,
                json=endpoint["payload"],
                timeout=30
            )

            print(f"  Status Code: {response.status_code}")
            print(f"  Response: {response.text[:200]}...")

            if response.status_code == 200:
                # Handle SSE (Server-Sent Events) response
                response_text = response.text
                if response_text.startswith("event: message"):
                    # Parse SSE format
                    lines = response_text.split('\n')
                    for line in lines:
                        if line.startswith("data: "):
                            data_json = line[6:]  # Remove "data: " prefix
                            result = json.loads(data_json)
                            break
                else:
                    result = response.json()

                print(f"\n✓ Success! Response received")
                print(json.dumps(result, indent=2)[:500])

                # Try to save the result
                output_dir = Path("../../GeneratedAssets/characters")
                output_dir.mkdir(parents=True, exist_ok=True)

                with open(output_dir / "tariq_response.json", "w") as f:
                    json.dump(result, f, indent=2)

                print(f"\n✓ Response saved to: {output_dir / 'tariq_response.json'}")
                return True

        except Exception as e:
            print(f"  Error: {e}")

        print()

    print("=" * 60)
    print("All attempts failed. The PixelLab API may require")
    print("different authentication or endpoint format.")
    print("=" * 60)
    return False

if __name__ == "__main__":
    success = generate_tariq()
    sys.exit(0 if success else 1)
