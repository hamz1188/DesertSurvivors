const fs = require('fs');
const path = require('path');
const child_process = require('child_process');

const BRIDGE_URL = 'http://localhost:3847';
const ENEMIES_DIR = '/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets/Enemies';

const ENEMIES = [
    // Tier 1 (32x32 frames -> 128x? strip, request 128x128 grid or strip)
    { name: 'sand_scarab', prompt: 'small desert beetle, brown shell, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },
    { name: 'desert_rat', prompt: 'desert jerboa rodent, tan fur, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },
    { name: 'scorpion', prompt: 'desert scorpion, moving claws and tail, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },
    { name: 'dust_sprite', prompt: 'magical dust cloud spirit, swirling, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },

    // Tier 2 (originally 48x48. 128x128 canvas can fit 2 frames wide? Or 4 frames if they are small. 
    // Requesting 4 frame strip might squash them if prompt isn't handled well by model on 128px width.
    // Actually, model v2 handles 128x128. If we want 4 frames, that's 32px width per frame. 
    // Tier 1 is 32px, so 128 width is perfect (4x32=128).
    // Tier 2 is 48px. 4x48 = 192. 128 is too small for a 4-frame strip of 48px.
    // We should request 256x256 for Tier 2 to be safe, or just 256 width.
    // API v2 supports 256x256. Let's use 256x256 for Tier 2 and crop/scale or just use the sheet.
    // If we request "4 frames horizontal strip", and canvas is 256 wide, each frame is 64px. 
    // That covers the 48px requirement nicely.
    { name: 'mummified_wanderer', prompt: 'egyptian mummy walking, bandage wrappings, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'sand_cobra', prompt: 'desert cobra slithering, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'desert_bandit', prompt: 'hooded bandit walking with scimitar, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'cursed_jackal', prompt: 'anubis jackal warrior walking, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 }
];

async function generateSheet(enemy) {
    console.log(`\nGenerating animation for ${enemy.name}...`);
    const size = enemy.size || 128; // Default 128 for Tier 1

    try {
        const response = await fetch(`${BRIDGE_URL}/generate_image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                description: enemy.prompt,
                image_size: { width: size, height: size } // Square canvas requirement
            })
        });

        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        if (data.images && data.images.length > 0) {
            saveAsset(enemy.name, data.images[0].base64);
        } else {
            console.error(`✗ No images returned for ${enemy.name}`);
        }
    } catch (e) {
        console.error(`Error generating ${enemy.name}:`, e.message);
    }
}

function saveAsset(name, base64Data) {
    const imagesetName = `${name}_sheet`;
    const imagesetDir = path.join(ENEMIES_DIR, `${imagesetName}.imageset`);

    if (fs.existsSync(imagesetDir)) fs.rmSync(imagesetDir, { recursive: true, force: true });
    fs.mkdirSync(imagesetDir, { recursive: true });

    const filename = `${imagesetName}.png`;
    fs.writeFileSync(path.join(imagesetDir, filename), Buffer.from(base64Data, 'base64'));

    const contents = {
        "images": [
            { "filename": filename, "idiom": "universal", "scale": "1x" },
            { "idiom": "universal", "scale": "2x" },
            { "idiom": "universal", "scale": "3x" }
        ],
        "info": { "author": "xcode", "version": 1 }
    };
    fs.writeFileSync(path.join(imagesetDir, 'Contents.json'), JSON.stringify(contents, null, 2));
    console.log(`✓ Saved ${imagesetName}`);
}

async function run() {
    for (const enemy of ENEMIES) {
        await generateSheet(enemy);
        // Small delay to be nice to local server / rate limits
        await new Promise(r => setTimeout(r, 1000));
    }
    console.log("\nAll Done!");
}

run();
