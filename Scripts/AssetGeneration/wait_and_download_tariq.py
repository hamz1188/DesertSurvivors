#!/usr/bin/env python3
"""
Wait for Tariq character to complete and download automatically
"""

import requests
import json
import time
from pathlib import Path

CHARACTER_ID = "1b6c1bbc-06e8-4fb6-aa9a-54cca2782d3d"

def check_and_download():
    """Check status repeatedly until ready, then download"""
    api_url = "https://api.pixellab.ai/mcp"
    headers = {
        "Authorization": "Bearer 88e2b87c-1255-4754-835b-ab5ea1f6c867",
        "Content-Type": "application/json"
    }

    print("=" * 70)
    print("WAITING FOR TARIQ CHARACTER GENERATION")
    print("=" * 70)
    print()

    max_attempts = 60  # 5 minutes max (5 second intervals)
    attempt = 0

    while attempt < max_attempts:
        attempt += 1

        payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "get_character",
                "arguments": {
                    "character_id": CHARACTER_ID
                }
            }
        }

        try:
            response = requests.post(api_url, headers=headers, json=payload, timeout=30)

            if response.status_code == 200:
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

                # Check if character is ready
                if "result" in result and "content" in result["result"]:
                    for content in result["result"]["content"]:
                        if content["type"] == "text":
                            text = content["text"]

                            # Check if still processing
                            if "still being generated" in text:
                                # Extract percentage if available
                                if "% complete" in text:
                                    percent_start = text.find("(") + 1
                                    percent_end = text.find("%")
                                    percent = text[percent_start:percent_end]
                                    print(f"[Attempt {attempt}] Progress: {percent}% complete...")
                                else:
                                    print(f"[Attempt {attempt}] Still processing...")

                                time.sleep(5)
                                continue

                            # Check if ready (contains download URL or image data)
                            elif "Download" in text or "ready" in text.lower():
                                print("\n✓ Character generation complete!")
                                print(text)

                                # Try to find download URL in text
                                if "https://" in text:
                                    url_start = text.find("https://")
                                    url_end = text.find(")", url_start)
                                    if url_end == -1:
                                        url_end = text.find(" ", url_start)
                                    if url_end == -1:
                                        url_end = text.find("\n", url_start)

                                    download_url = text[url_start:url_end].strip()

                                    print(f"\nDownloading from: {download_url}")

                                    # Download the ZIP file
                                    download_response = requests.get(download_url, timeout=60)

                                    if download_response.status_code == 200:
                                        output_dir = Path("../../GeneratedAssets/characters")
                                        output_dir.mkdir(parents=True, exist_ok=True)

                                        zip_path = output_dir / "Tariq.zip"
                                        with open(zip_path, "wb") as f:
                                            f.write(download_response.content)

                                        print(f"✓ Downloaded to: {zip_path}")
                                        print(f"\nFile size: {len(download_response.content)} bytes")

                                        # Extract the ZIP
                                        import zipfile
                                        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                                            zip_ref.extractall(output_dir / "Tariq")

                                        print(f"✓ Extracted to: {output_dir / 'Tariq'}/")
                                        print("\n" + "=" * 70)
                                        print("SUCCESS! Tariq character ready.")
                                        print("=" * 70)
                                        return True

                        elif content["type"] == "image":
                            # Direct image data
                            print("\n✓ Character ready (image data received)!")
                            # Handle image download
                            return True

        except Exception as e:
            print(f"[Attempt {attempt}] Error: {e}")

        time.sleep(5)

    print("\n✗ Timeout: Character generation took longer than expected")
    return False

if __name__ == "__main__":
    check_and_download()
