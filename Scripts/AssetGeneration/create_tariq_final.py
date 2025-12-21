#!/usr/bin/env python3
"""
Create Tariq character using PixelLab API with correct parameters
"""

import requests
import json
import time
from pathlib import Path

def create_character():
    """Create Tariq character"""
    api_url = "https://api.pixellab.ai/mcp"
    headers = {
        "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867",
        "Content-Type": "application/json"
    }

    print("=" * 70)
    print("CREATING TARIQ - DESERT SURVIVORS MAIN CHARACTER")
    print("=" * 70)

    # Character creation request with correct parameters
    create_payload = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": "create_character",
            "arguments": {
                "description": "Young Arabian warrior with curved dagger, wearing flowing desert robes and turban, tan skin, determined expression, gold trim on robes",
                "name": "Tariq",
                "n_directions": 8,  # 8 directional views for smooth movement
                "size": 64,  # 64px canvas
                "proportions": '{"type": "preset", "name": "heroic"}',
                "outline": "single color black outline",
                "shading": "medium shading",
                "detail": "high detail"
            }
        }
    }

    print("\nStep 1: Creating character...")
    print(f"  Description: {create_payload['params']['arguments']['description']}")
    print(f"  Size: {create_payload['params']['arguments']['size']}px")
    print(f"  Directions: {create_payload['params']['arguments']['n_directions']}")
    print()

    response = requests.post(api_url, headers=headers, json=create_payload, timeout=30)

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

    print("✓ Character creation job queued!")
    print(json.dumps(result, indent=2))

    # Extract job_id and character_id
    if "result" in result and "content" in result["result"]:
        for content in result["result"]["content"]:
            if content["type"] == "text":
                text = content["text"]
                print(f"\nAPI Response: {text}")

                # Try to extract IDs from response
                if "job_id" in text or "character_id" in text:
                    # Save the response
                    output_dir = Path("../../GeneratedAssets/characters")
                    output_dir.mkdir(parents=True, exist_ok=True)

                    with open(output_dir / "tariq_creation_response.json", "w") as f:
                        json.dump(result, f, indent=2)

                    print(f"\n✓ Response saved to: {output_dir / 'tariq_creation_response.json'}")
                    print("\nNOTE: Character generation takes 3-5 minutes.")
                    print("Use get_character tool with the job_id or character_id to check status.")
                    return True

    return False

if __name__ == "__main__":
    create_character()
