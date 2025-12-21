#!/usr/bin/env python3
"""
Test PixelLab MCP Connection
Verify API connectivity and list available tools
"""

from pixellab_client import PixelLabClient
import sys

def test_connection():
    """Test connection to PixelLab MCP API"""
    print("=" * 60)
    print("TESTING PIXELLAB MCP CONNECTION")
    print("=" * 60)

    try:
        # Initialize client
        print("\n1. Initializing PixelLab client...")
        client = PixelLabClient(
            api_url="https://api.pixellab.ai/mcp",
            api_key="88e2b87c-1255-4754-835b-ab5ea1f6c867"
        )
        print("   ✓ Client initialized")

        # Test connection by listing tools
        print("\n2. Fetching available tools...")
        tools = client.list_tools()
        print(f"   ✓ Connection successful!")
        print(f"   Found {len(tools)} available tools\n")

        # Display available tools
        print("=" * 60)
        print("AVAILABLE PIXELLAB TOOLS")
        print("=" * 60)

        for i, tool in enumerate(tools, 1):
            print(f"\n{i}. {tool.get('name', 'Unknown')}")
            print(f"   Description: {tool.get('description', 'No description')}")

            if 'inputSchema' in tool:
                schema = tool['inputSchema']
                if 'properties' in schema:
                    print("   Parameters:")
                    for param, details in schema['properties'].items():
                        param_type = details.get('type', 'unknown')
                        param_desc = details.get('description', '')
                        required = param in schema.get('required', [])
                        req_marker = "*" if required else ""
                        print(f"     - {param}{req_marker} ({param_type}): {param_desc}")

        print("\n" + "=" * 60)
        print("CONNECTION TEST SUCCESSFUL")
        print("=" * 60)
        print("\nYou can now run:")
        print("  python3 generate_desert_survivors_assets.py")
        print("\nto generate all game assets.")

        return True

    except Exception as e:
        print("\n" + "=" * 60)
        print("CONNECTION TEST FAILED")
        print("=" * 60)
        print(f"\nError: {e}")
        print("\nTroubleshooting:")
        print("  1. Verify MCP server is configured:")
        print("     claude mcp list")
        print("  2. Check API key is valid")
        print("  3. Verify internet connection")
        print("  4. Check PixelLab API status")

        return False


if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)
