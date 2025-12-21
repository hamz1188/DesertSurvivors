const fs = require('fs');
const path = require('path');

const BRIDGE_URL = 'http://localhost:3847';
const ENEMIES_DIR = '/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets/Enemies';

const ENEMIES = [
    // Tier 1 (Remaining) - desert_rat moved to end
    { name: 'scorpion', prompt: 'desert scorpion, moving claws and tail, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },
    { name: 'dust_sprite', prompt: 'magical dust cloud spirit, swirling, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' },

    // Tier 2 (All) - Using size: 256 for higher detail potential
    { name: 'mummified_wanderer', prompt: 'egyptian mummy walking, bandage wrappings, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'sand_cobra', prompt: 'desert cobra slithering, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'desert_bandit', prompt: 'hooded bandit walking with scimitar, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },
    { name: 'cursed_jackal', prompt: 'anubis jackal warrior walking, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background', size: 256 },

    // Retry desert_rat last
    { name: 'desert_rat', prompt: 'desert jerboa rodent, tan fur, top-down game sprite, pixel art walk cycle, 4 frames horizontal strip, white background' }
];

async function generateSheet(enemy) {
    console.log(`\nGenerating animation for ${enemy.name}...`);
    const size = enemy.size || 128;

    try {
        const response = await fetch(`${BRIDGE_URL}/generate_image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                description: enemy.prompt,
                image_size: { width: size, height: size }
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
        await new Promise(r => setTimeout(r, 2000)); // Increased delay to 2s to be safer
    }
    console.log("\nAll Done!");
}

run();
