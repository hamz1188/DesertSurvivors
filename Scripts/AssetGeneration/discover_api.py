#!/usr/bin/env python3
"""
Discover PixelLab API tools and parameters
"""

import requests
import json

api_url = "https://api.pixellab.ai/mcp"
headers = {
    "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867",
    "Content-Type": "application/json"
}

# Request to list all available tools
payload = {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/list",
    "params": {}
}

print("Fetching available tools from PixelLab API...")
print("=" * 60)

response = requests.post(api_url, headers=headers, json=payload, timeout=30)

print(f"Status Code: {response.status_code}")
print()

if response.status_code == 200:
    # Handle SSE response
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

    # Pretty print the result
    print(json.dumps(result, indent=2))

    # Save to file
    with open("api_tools.json", "w") as f:
        json.dump(result, f, indent=2)
    print("\n✓ API tools saved to api_tools.json")
else:
    print(f"Error: {response.text}")
