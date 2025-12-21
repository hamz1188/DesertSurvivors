const fs = require('fs');
const path = require('path');

const BRIDGE_URL = 'http://localhost:3847';
const OUTPUT_DIR = '/Users/hameli/DesertSurvivors/tools/anim_test';

if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });

async function generateSpriteSheet(name, prompt) {
    console.log(`Generating sprite sheet for ${name}...`);
    try {
        const response = await fetch(`${BRIDGE_URL}/generate_image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                description: `${prompt}, pixel art sprite sheet, 4 frames walking animation sequence, horizontal strip, white background`,
                image_size: { width: 128, height: 128 } // 128x128 gives room for 4x 32px frames (maybe arranged 2x2 or strip)
            })
        });

        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();

        if (data.images && data.images.length > 0) {
            const buffer = Buffer.from(data.images[0].base64, 'base64');
            fs.writeFileSync(path.join(OUTPUT_DIR, `${name}_sheet.png`), buffer);
            console.log(`✓ Saved ${name}_sheet.png`);
        } else {
            console.error(`✗ No images returned`);
        }
    } catch (e) {
        console.error(`Error:`, e.message);
    }
}

generateSpriteSheet('sand_scarab_anim', 'small desert beetle game enemy');
