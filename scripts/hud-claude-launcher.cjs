#!/usr/bin/env node

/**
 * HUD Claude Launcher
 *
 * A minimal wrapper that launches Claude Code with ESM import().
 * State tracking is now handled by hooks (UserPromptSubmit, Stop) instead of
 * fetch interception, since Claude Code uses undici internally which bypasses
 * global.fetch patches.
 *
 * Usage:
 *   node ~/.claude/scripts/hud-claude-launcher.cjs [claude args...]
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const { pathToFileURL } = require('url');

function findClaudeCliPath() {
    try {
        const whichResult = execSync('which claude', {
            encoding: 'utf-8',
            stdio: ['pipe', 'pipe', 'pipe']
        }).trim();
        if (whichResult && fs.existsSync(whichResult)) {
            return whichResult;
        }
    } catch (e) {}

    const possiblePaths = [
        '/opt/homebrew/bin/claude',
        '/usr/local/bin/claude',
        path.join(process.env.HOME, '.npm-global/bin/claude'),
        path.join(process.env.HOME, '.local/bin/claude'),
    ];

    for (const p of possiblePaths) {
        if (fs.existsSync(p)) {
            return p;
        }
    }

    return null;
}

function resolveClaudeEntryPoint(binPath) {
    const realPath = fs.realpathSync(binPath);

    if (realPath.endsWith('.js') || realPath.endsWith('.cjs') || realPath.endsWith('.mjs')) {
        return realPath;
    }

    const nodeModulesMatch = realPath.match(/(.+\/node_modules\/@anthropic-ai\/claude-code)/);
    if (nodeModulesMatch) {
        const packageDir = nodeModulesMatch[1];
        const cliPath = path.join(packageDir, 'cli.js');
        if (fs.existsSync(cliPath)) {
            return cliPath;
        }
        const distCliPath = path.join(packageDir, 'dist', 'cli.js');
        if (fs.existsSync(distCliPath)) {
            return distCliPath;
        }
    }

    try {
        const npmRoot = execSync('npm root -g', { encoding: 'utf-8', stdio: ['pipe', 'pipe', 'pipe'] }).trim();
        const cliPath = path.join(npmRoot, '@anthropic-ai', 'claude-code', 'cli.js');
        if (fs.existsSync(cliPath)) {
            return cliPath;
        }
    } catch (e) {}

    return realPath;
}

async function main() {
    const claudeBinPath = findClaudeCliPath();
    if (!claudeBinPath) {
        console.error('[HUD] Error: Could not find claude CLI.');
        console.error('[HUD] Please ensure @anthropic-ai/claude-code is installed globally.');
        process.exit(1);
    }

    const claudeEntryPoint = resolveClaudeEntryPoint(claudeBinPath);

    process.argv = [process.argv[0], claudeEntryPoint, ...process.argv.slice(2)];

    const importUrl = pathToFileURL(claudeEntryPoint).href;
    await import(importUrl);
}

main().catch(err => {
    console.error('[HUD] Error:', err);
    process.exit(1);
});
