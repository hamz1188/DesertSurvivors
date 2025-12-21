#!/usr/bin/env node
/**
 * PixelLab v2 API Bridge Server
 * 
 * This server acts as a bridge between Antigravity and the PixelLab v2 REST API.
 * 
 * Usage:
 *   1. Run: node pixellab_bridge.js
 *   2. Server runs on http://localhost:3847
 */

const http = require('http');
const https = require('https');

const PIXELLAB_API_TOKEN = process.env.PIXELLAB_API_TOKEN || '88e2b87c-1255-4754-835b-ab5ea1f6c867';
const PORT = 3847;
const BASE_PATH = '/v2';

// Helper to make HTTPS requests to PixelLab v2 API
function pixelLabRequest(method, path, body = null) {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: 'api.pixellab.ai',
            port: 443,
            path: `${BASE_PATH}${path}`,
            method: method,
            headers: {
                'Authorization': `Bearer ${PIXELLAB_API_TOKEN}`,
                'Content-Type': 'application/json',
            }
        };

        console.log(`→ ${method} ${options.path}`);

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                console.log(`← ${res.statusCode}`);
                try {
                    const parsed = JSON.parse(data);
                    if (res.statusCode >= 400) {
                        console.error(`ERROR BODY:`, JSON.stringify(parsed, null, 2));
                    }
                    resolve({ status: res.statusCode, data: parsed });
                } catch (e) {
                    resolve({ status: res.statusCode, data: { raw: data } });
                }
            });
        });

        req.on('error', (e) => {
            console.error('Request error:', e.message);
            reject(e);
        });

        if (body) {
            const bodyStr = JSON.stringify(body);
            console.log(`   Body: ${bodyStr.substring(0, 100)}...`);
            req.write(bodyStr);
        }
        req.end();
    });
}

// Main server
const server = http.createServer(async (req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // Parse request body
    let body = '';
    req.on('data', chunk => body += chunk);

    await new Promise(resolve => req.on('end', resolve));

    let params = {};
    try {
        if (body) params = JSON.parse(body);
    } catch (e) { }

    const url = req.url;
    console.log(`\n=== ${req.method} ${url} ===`);

    try {
        let result;

        // Route handlers using correct v2 API endpoints
        if (url === '/create_character_8dir' && req.method === 'POST') {
            // Create character with 8 directions
            const defaults = {
                description: 'fantasy character',
                image_size: { width: 64, height: 64 },
                view: 'low top-down',
                outline: 'medium',
                shading: 'soft',
                detail: 'high'
            };
            const upstreamBody = { ...defaults, ...params };
            result = await pixelLabRequest('POST', '/create-character-with-8-directions', upstreamBody);
        }
        else if (url === '/create_character_4dir' && req.method === 'POST') {
            // Create character with 4 directions
            const defaults = {
                description: 'fantasy character',
                image_size: { width: 64, height: 64 },
                view: 'low top-down',
                outline: 'medium',
                shading: 'soft',
                detail: 'high'
            };
            const upstreamBody = { ...defaults, ...params };
            result = await pixelLabRequest('POST', '/create-character-with-4-directions', upstreamBody);
        }
        else if (url === '/animate_character' && req.method === 'POST') {
            // Animate an existing character
            // Templates: walking, running, idle, attacking, dying, etc.
            result = await pixelLabRequest('POST', '/animate-character', {
                character_id: params.character_id,
                template_animation_id: params.template_animation_id || 'walking',
                action_description: params.action_description || null,
                animation_name: params.animation_name || null
            });
        }
        else if (url.startsWith('/job/')) {
            // Check job status
            const jobId = url.split('/')[2];
            result = await pixelLabRequest('GET', `/background-jobs/${jobId}`);
        }
        else if (url.startsWith('/character/')) {
            // Get character details
            const charId = url.split('/')[2];
            result = await pixelLabRequest('GET', `/characters/${charId}`);
        }
        else if (url === '/characters') {
            // List all characters
            result = await pixelLabRequest('GET', '/characters');
        }
        else if (url === '/create_tileset' && req.method === 'POST') {
            // Create tileset
            // API expects POST /tilesets
            result = await pixelLabRequest('POST', '/tilesets', {
                lower_description: params.lower_description || 'grass',
                upper_description: params.upper_description || 'sand',
                tile_size: params.tile_size || { width: 32, height: 32 },
                transition_size: params.transition_size || 0.25,
                view: params.view || 'high top-down',
                outline: 'lineless',
                shading: 'basic shading',
                detail: 'medium detail'
            });
        }
        else if (url === '/generate_image' && req.method === 'POST') {
            // Generic generation (for icons etc)
            result = await pixelLabRequest('POST', '/generate-image-v2', params);
        }
        else if (url.startsWith('/tileset/')) {
            // Get tileset status/details
            const tilesetId = url.split('/')[2];
            result = await pixelLabRequest('GET', `/tilesets/${tilesetId}`);
        }
        else if (url === '/create_map_object' && req.method === 'POST') {
            // Create map object using generate-image-v2
            const enhancedDescription = `${params.description}, ${params.view || 'high top-down'} view, ${params.outline || 'thin'} outline, ${params.shading || 'soft'} shading, ${params.detail || 'medium'} detail`;

            result = await pixelLabRequest('POST', '/generate-image-v2', {
                description: enhancedDescription,
                image_size: {
                    width: params.width || 32,
                    height: params.height || 32
                },
                no_background: true
            });
        }
        else if (url.startsWith('/map-object/')) {
            // Get map object status
            const objId = url.split('/')[2];
            result = await pixelLabRequest('GET', `/map-objects/${objId}`);
        }
        else if (url === '/balance') {
            // Check account balance
            result = await pixelLabRequest('GET', '/balance');
        }
        else if (url === '/health') {
            result = { status: 200, data: { status: 'ok', message: 'PixelLab v2 Bridge Server Running' } };
        }
        else {
            result = {
                status: 404,
                data: {
                    error: 'Unknown endpoint',
                    available: [
                        'POST /create_character_8dir - Create 8-directional character',
                        'POST /create_character_4dir - Create 4-directional character',
                        'POST /animate_character - Animate a character',
                        'GET  /job/:id - Check job status',
                        'GET  /character/:id - Get character details',
                        'GET  /characters - List all characters',
                        'GET  /balance - Check credit balance',
                        'GET  /health - Health check'
                    ]
                }
            };
        }

        res.writeHead(result.status || 200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(result.data, null, 2));

    } catch (error) {
        console.error('Server error:', error);
        res.writeHead(500, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: error.message }));
    }
});

server.listen(PORT, () => {
    console.log(`\n🎨 PixelLab v2 Bridge Server running at http://localhost:${PORT}`);
    console.log(`   Token: ${PIXELLAB_API_TOKEN.substring(0, 8)}...`);
    console.log('');
    console.log('   Endpoints:');
    console.log('     POST /create_character_8dir - Create 8-directional character');
    console.log('     POST /create_character_4dir - Create 4-directional character');
    console.log('     POST /animate_character     - Animate a character');
    console.log('     GET  /job/:id               - Check job status');
    console.log('     GET  /character/:id         - Get character details');
    console.log('     GET  /characters            - List all characters');
    console.log('     GET  /balance               - Check credit balance');
    console.log('     GET  /health                - Health check');
    console.log('');
});
