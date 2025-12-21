const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const BRIDGE_URL = 'http://localhost:3847/create_map_object';
const ENEMY_DIR = '/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets/Enemies';

const enemies = [
    {
        name: 'sand_scarab',
        prompt: 'realistic desert scarab beetle, shiny dark bronze shell, six segmented legs, antennae, viewed from above, crawling pose, pixel art creature sprite',
        size: 32
    },
    {
        name: 'desert_rat',
        prompt: 'realistic desert jerboa rodent, sandy tan fur, large ears, long thin tail, four legs crouched, viewed from above, pixel art animal sprite',
        size: 32
    },
    {
        name: 'scorpion',
        prompt: 'realistic desert scorpion arachnid, tan exoskeleton, eight legs, two large pincers, curved segmented tail with stinger, viewed from above, pixel art creature sprite',
        size: 32
    },
    {
        name: 'dust_sprite',
        prompt: 'small swirling dust devil, golden sand particles spinning in vortex, magical glowing core center, ethereal wispy trails, pixel art elemental sprite',
        size: 32
    },
    {
        name: 'sand_cobra',
        prompt: 'realistic egyptian cobra snake, tan and brown scales, raised hood spread wide, forked tongue, coiled body ready to strike, viewed from above, pixel art animal sprite',
        size: 48
    },
    {
        name: 'cursed_jackal',
        prompt: 'supernatural jackal beast, black and gold fur, glowing violet eyes, egyptian collar jewelry, ghostly purple aura around body, snarling fangs, viewed from above, pixel art monster sprite',
        size: 48
    }
];

async function generateEnemy(enemy) {
    console.log(`Generating ${enemy.name}...`);
    try {
        const response = await fetch(BRIDGE_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                description: enemy.prompt,
                width: enemy.size,
                height: enemy.size,
                view: 'high top-down',
                outline: 'thin',
                shading: 'soft',
                detail: 'medium'
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (data.images && data.images.length > 0) {
            const base64Data = data.images[0].base64;
            const buffer = Buffer.from(base64Data, 'base64');

            const imagesetDir = path.join(ENEMY_DIR, `${enemy.name}.imageset`);
            if (!fs.existsSync(imagesetDir)) {
                fs.mkdirSync(imagesetDir, { recursive: true });
            }

            const filePath = path.join(imagesetDir, `${enemy.name}.png`);
            fs.writeFileSync(filePath, buffer);

            // Create Contents.json
            const contents = {
                "images": [
                    { "filename": `${enemy.name}.png`, "idiom": "universal", "scale": "1x" },
                    { "idiom": "universal", "scale": "2x" },
                    { "idiom": "universal", "scale": "3x" }
                ],
                "info": { "author": "xcode", "version": 1 }
            };
            fs.writeFileSync(path.join(imagesetDir, 'Contents.json'), JSON.stringify(contents, null, 2));

            console.log(`✓ Saved ${enemy.name}`);
        } else {
            console.error(`✗ No images returned for ${enemy.name}`);
        }

    } catch (error) {
        console.error(`✗ Error generating ${enemy.name}:`, error.message);
    }
}

async function main() {
    for (const enemy of enemies) {
        await generateEnemy(enemy);
        // Wait a bit between requests to avoid rate limits
        await new Promise(resolve => setTimeout(resolve, 2000));
    }
    console.log('Done!');
}

main();
