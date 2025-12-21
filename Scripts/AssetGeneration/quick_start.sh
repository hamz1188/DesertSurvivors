#!/bin/bash
# Quick Start Script for PixelLab Asset Generation

set -e  # Exit on error

echo "======================================================================"
echo "DESERT SURVIVORS - PIXELLAB ASSET GENERATION"
echo "======================================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "pixellab_client.py" ]; then
    echo "Error: Please run this script from Scripts/AssetGeneration directory"
    exit 1
fi

# Step 1: Install dependencies
echo "Step 1: Installing Python dependencies..."
echo "----------------------------------------------------------------------"
pip3 install -q -r requirements.txt
echo "✓ Dependencies installed"
echo ""

# Step 2: Test connection
echo "Step 2: Testing PixelLab MCP connection..."
echo "----------------------------------------------------------------------"
python3 test_connection.py
if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Connection test failed. Please check the error above."
    exit 1
fi
echo ""

# Step 3: Generate assets
echo "Step 3: Generate all game assets..."
echo "----------------------------------------------------------------------"
read -p "This will generate ~80+ assets and may take 5-10 minutes. Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Asset generation cancelled."
    exit 0
fi

python3 generate_desert_survivors_assets.py
if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Asset generation failed. Please check the error above."
    exit 1
fi
echo ""

# Step 4: Integrate into Xcode
echo "Step 4: Integrate assets into Xcode project..."
echo "----------------------------------------------------------------------"
read -p "Integrate assets into Assets.xcassets? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 integrate_assets.py
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ Asset integration failed. Please check the error above."
        exit 1
    fi
fi

echo ""
echo "======================================================================"
echo "COMPLETE!"
echo "======================================================================"
echo ""
echo "Next steps:"
echo "  1. Open Xcode and verify assets in Assets.xcassets"
echo "  2. Check GeneratedAssets/ASSET_REFERENCE.md for usage examples"
echo "  3. Update your Swift code to use the new assets"
echo ""
echo "Asset locations:"
echo "  - Generated files: GeneratedAssets/"
echo "  - Xcode assets: DesertSurvivors/Assets.xcassets/"
echo "  - Reference guide: GeneratedAssets/ASSET_REFERENCE.md"
echo ""
