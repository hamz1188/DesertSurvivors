const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const BRIDGE_URL = 'http://localhost:3847';
const ENEMY_DIR = '/Users/hameli/DesertSurvivors/DesertSurvivors/Assets.xcassets/Enemies';

const TARGET_NAME = process.argv[2]; // e.g. "sand_scarab"

if (!TARGET_NAME) {
    console.error("Please provide an enemy name (e.g., node import_enemy.js sand_scarab)");
    process.exit(1);
}

async function importEnemy() {
    console.log(`Searching for "${TARGET_NAME}"...`);

    try {
        // 1. List characters to find the ID
        const listResponse = await fetch(`${BRIDGE_URL}/characters`);
        const listData = await listResponse.json();

        // The characters are in a "characters" array, and ID is "id"
        const character = listData.characters.find(c => c.name === TARGET_NAME);

        if (!character) {
            console.error(`✗ Character "${TARGET_NAME}" not found in your PixelLab account.`);
            console.log("Found characters:", listData.characters.map(c => c.name).join(', '));
            return;
        }

        console.log(`✓ Found "${TARGET_NAME}" (ID: ${character.id})`);

        // 2. Download ZIP
        // The bridge doesn't have a direct ZIP download proxy, so we'll use curl directly with the token 
        // OR we can add a zip route to the bridge. 
        // Let's use the direct curl method like we did in previous steps for reliability, 
        // using the token from the environment/bridge.
        // Actually, let's just use the bridge if we can or just straight curl.

        // We will assume the token is known or we can just grab it from a hardcoded string since we are in a script for the user.
        // But better yet, I should check if the bridge has a ZIP route. 
        // Looking at previous valid bridge code, I didn't verify a ZIP route.
        // Let's just use curl with the known token for now to be safe and fast.

        const TOKEN = "88e2b87c-1255-4754-835b-ab5ea1f6c867";
        const zipUrl = `https://api.pixellab.ai/v2/characters/${character.id}/zip`;
        const tmpZipPath = `/tmp/${TARGET_NAME}.zip`;
        const tmpExtractPath = `/tmp/${TARGET_NAME}`;

        console.log(`Downloading ZIP...`);
        execSync(`curl -s -o ${tmpZipPath} "${zipUrl}" -H "Authorization: Bearer ${TOKEN}"`);

        // 3. Extract and Install
        console.log(`Extracting and installing...`);
        execSync(`rm -rf ${tmpExtractPath}`);
        execSync(`unzip -o ${tmpZipPath} -d ${tmpExtractPath} > /dev/null`);

        // Check if rotation images exist (standard structure: rotations/south.png, etc.)
        const southPath = path.join(tmpExtractPath, 'rotations', 'south.png');

        if (fs.existsSync(southPath)) {
            const imagesetDir = path.join(ENEMY_DIR, `${TARGET_NAME}.imageset`);

            // Clean old
            if (fs.existsSync(imagesetDir)) {
                fs.rmSync(imagesetDir, { recursive: true, force: true });
            }
            fs.mkdirSync(imagesetDir, { recursive: true });

            // Copy south facing sprite (default)
            fs.copyFileSync(southPath, path.join(imagesetDir, `${TARGET_NAME}.png`));

            // Create Contents.json
            const contents = {
                "images": [
                    { "filename": `${TARGET_NAME}.png`, "idiom": "universal", "scale": "1x" },
                    { "idiom": "universal", "scale": "2x" },
                    { "idiom": "universal", "scale": "3x" }
                ],
                "info": { "author": "xcode", "version": 1 }
            };
            fs.writeFileSync(path.join(imagesetDir, 'Contents.json'), JSON.stringify(contents, null, 2));

            console.log(`✓ Successfully installed ${TARGET_NAME} to Assets`);
        } else {
            console.error(`✗ Could not find 'rotations/south.png' in the ZIP.`);
            // List contents to debug
            execSync(`ls -R ${tmpExtractPath}`);
        }

        // Cleanup
        fs.unlinkSync(tmpZipPath);
        fs.rmSync(tmpExtractPath, { recursive: true, force: true });

    } catch (error) {
        console.error(`Error:`, error.message);
    }
}

importEnemy();
