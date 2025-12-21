#!/usr/bin/env python3
"""
Check status and download Tariq character
"""

import requests
import json
import time
import base64
from pathlib import Path

CHARACTER_ID = "1b6c1bbc-06e8-4fb6-aa9a-54cca2782d3d"

def get_character(character_id):
    """Get character status and download if ready"""
    api_url = "https://api.pixellab.ai/mcp"
    headers = {
        "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867",
        "Content-Type": "application/json"
    }

    payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": "get_character",
            "arguments": {
                "character_id": character_id
            }
        }
    }

    print(f"Checking status for character {character_id}...")
    print()

    response = requests.post(api_url, headers=headers, json=payload, timeout=30)

    if response.status_code != 200:
        print(f"✗ Error: {response.status_code}")
        print(response.text)
        return False

    # Parse SSE response
    response_text = response.text
    if response_text.startswith("event: message"):
        lines = response_text.split('\n')
        for line in lines:
            if line.startswith("data: "):
                data_json = line[6:]
                result = json.loads(data_json)
                break
    else:
        result = json.loads(response_text)

    # Save full response
    output_dir = Path("../../GeneratedAssets/characters")
    output_dir.mkdir(parents=True, exist_ok=True)

    with open(output_dir / "tariq_status.json", "w") as f:
        json.dump(result, f, indent=2)

    # Print result
    print(json.dumps(result, indent=2))

    # Check if we have image data or URL
    if "result" in result and "content" in result["result"]:
        for content in result["result"]["content"]:
            if content["type"] == "image":
                # Image data available
                print("\n✓ Character ready! Downloading...")

                # Check if it's base64 or URL
                if "data" in content:
                    # Base64 encoded image
                    image_data = base64.b64decode(content["data"])
                    output_path = output_dir / "Tariq.png"

                    with open(output_path, "wb") as f:
                        f.write(image_data)

                    print(f"✓ Saved to: {output_path}")
                    return True

                elif "url" in content:
                    # Download from URL
                    image_response = requests.get(content["url"])
                    output_path = output_dir / "Tariq.png"

                    with open(output_path, "wb") as f:
                        f.write(image_response.content)

                    print(f"✓ Saved to: {output_path}")
                    return True

            elif content["type"] == "text":
                print(f"\nStatus: {content['text']}")

    return False

if __name__ == "__main__":
    print("=" * 70)
    print("CHECKING TARIQ CHARACTER STATUS")
    print("=" * 70)
    print()

    get_character(CHARACTER_ID)
