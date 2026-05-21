#!/usr/bin/env node

import sharp from 'sharp';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');

const log = (...args) => console.log('[icons]', ...args);

const ANDROID_MIPMAP_SIZES = {
  'mipmap-mdpi': 48,
  'mipmap-hdpi': 72,
  'mipmap-xhdpi': 96,
  'mipmap-xxhdpi': 144,
  'mipmap-xxxhdpi': 192,
};

const ANDROID_FOREGROUND_SIZES = {
  'mipmap-mdpi': 108,
  'mipmap-hdpi': 162,
  'mipmap-xhdpi': 216,
  'mipmap-xxhdpi': 324,
  'mipmap-xxxhdpi': 432,
};

const ANDROID_RES_DIR = path.resolve(ROOT, 'android/app/src/main/res');

const TAURI_ICONS_DIR = path.resolve(ROOT, 'src-tauri/icons');

const TAURI_PNG_SIZES = [
  { name: '32x32.png', size: 32 },
  { name: '64x64.png', size: 64 },
  { name: '128x128.png', size: 128 },
  { name: '128x128@2x.png', size: 256 },
];

const TAURI_SQUARE_LOGOS = [
  { name: 'Square30x30Logo.png', size: 30 },
  { name: 'Square44x44Logo.png', size: 44 },
  { name: 'Square71x71Logo.png', size: 71 },
  { name: 'Square89x89Logo.png', size: 89 },
  { name: 'Square107x107Logo.png', size: 107 },
  { name: 'Square142x142Logo.png', size: 142 },
  { name: 'Square150x150Logo.png', size: 150 },
  { name: 'Square284x284Logo.png', size: 284 },
  { name: 'Square310x310Logo.png', size: 310 },
  { name: 'StoreLogo.png', size: 50 },
];

const PUBLIC_DIR = path.resolve(ROOT, 'public');
const PWA_ICONS = [
  { name: 'icon-192.png', size: 192 },
  { name: 'icon-512.png', size: 512 },
];

const FALLBACK_CANDIDATES = [
  path.resolve(ROOT, 'public/icon-512.png'),
  path.resolve(ROOT, 'src-tauri/icons/icon.png'),
  path.resolve(ROOT, 'public/icon-192.png'),
];

async function downloadImage(url) {
  const resp = await fetch(url, { signal: AbortSignal.timeout(10000) });
  if (!resp.ok) throw new Error(`Download failed: ${resp.status}`);
  return Buffer.from(await resp.arrayBuffer());
}

async function getSourceImage(sourceArg) {
  // 1. Explicit source arg
  if (sourceArg) {
    if (sourceArg.startsWith('http://') || sourceArg.startsWith('https://')) {
      log(`Downloading from ${sourceArg}...`);
      return await downloadImage(sourceArg);
    }
    log(`Reading local file: ${sourceArg}`);
    return await fs.readFile(sourceArg);
  }

  // 2. Settings API
  const apiUrl = process.env.API_URL || 'http://localhost:8000';
  try {
    log(`Fetching logo URL from ${apiUrl}/settings...`);
    const settingsRes = await fetch(`${apiUrl}/settings`, { signal: AbortSignal.timeout(5000) });
    if (settingsRes.ok) {
      const settings = await settingsRes.json();
      const logoUrl = settings.logo_url;
      if (logoUrl) {
        const fullUrl = logoUrl.startsWith('http') ? logoUrl : `${apiUrl}${logoUrl}`;
        log(`Downloading logo from ${fullUrl}...`);
        return await downloadImage(fullUrl);
      }
    }
  } catch {
    log('Settings API unreachable — trying fallback icons.');
  }

  // 3. Fallback: use existing icon file
  for (const fp of FALLBACK_CANDIDATES) {
    try {
      const buf = await fs.readFile(fp);
      log(`Using fallback: ${fp}`);
      return buf;
    } catch { /* not found, try next */ }
  }

  return null;
}

async function resizeTo(image, size) {
  return sharp(image).resize(size, size, { fit: 'cover' }).png().toBuffer();
}

async function generateAndroidIcons(image) {
  log('Generating Android launcher icons...');

  for (const [dir, size] of Object.entries(ANDROID_MIPMAP_SIZES)) {
    const outDir = path.join(ANDROID_RES_DIR, dir);
    await fs.mkdir(outDir, { recursive: true });
    const buf = await resizeTo(image, size);
    await fs.writeFile(path.join(outDir, 'ic_launcher.png'), buf);
    await fs.writeFile(path.join(outDir, 'ic_launcher_round.png'), buf);
  }
  log('  ✓ Regular launcher icons');

  for (const [dir, size] of Object.entries(ANDROID_FOREGROUND_SIZES)) {
    const outDir = path.join(ANDROID_RES_DIR, dir);
    await fs.mkdir(outDir, { recursive: true });
    const buf = await resizeTo(image, size);
    await fs.writeFile(path.join(outDir, 'ic_launcher_foreground.png'), buf);
  }
  log('  ✓ Adaptive foreground icons');
}

async function generateTauriIcons(image) {
  log('Generating Tauri desktop icons...');
  await fs.mkdir(TAURI_ICONS_DIR, { recursive: true });

  await fs.writeFile(path.join(TAURI_ICONS_DIR, 'icon.png'), await resizeTo(image, 512));
  log('  ✓ icon.png');

  for (const { name, size } of TAURI_PNG_SIZES) {
    await fs.writeFile(path.join(TAURI_ICONS_DIR, name), await resizeTo(image, size));
  }
  log('  ✓ PNG icons');

  for (const { name, size } of TAURI_SQUARE_LOGOS) {
    await fs.writeFile(path.join(TAURI_ICONS_DIR, name), await resizeTo(image, size));
  }
  log('  ✓ Square logos');
}

async function generatePWAIcons(image) {
  log('Generating PWA icons...');
  await fs.mkdir(PUBLIC_DIR, { recursive: true });

  for (const { name, size } of PWA_ICONS) {
    await fs.writeFile(path.join(PUBLIC_DIR, name), await resizeTo(image, size));
  }
  log('  ✓ PWA icons');

  const png32 = await resizeTo(image, 32);
  await fs.writeFile(path.join(PUBLIC_DIR, 'favicon.png'), png32);
  log('  ✓ favicon.png');
}

async function generateTauriAndroidIcons(image) {
  log('Generating Tauri Android icons...');
  const tauriDir = path.resolve(ROOT, 'src-tauri', 'icons', 'android');

  for (const [dir, size] of Object.entries(ANDROID_MIPMAP_SIZES)) {
    const outDir = path.join(tauriDir, dir);
    await fs.mkdir(outDir, { recursive: true });
    const buf = await resizeTo(image, size);
    await fs.writeFile(path.join(outDir, 'ic_launcher.png'), buf);
    await fs.writeFile(path.join(outDir, 'ic_launcher_round.png'), buf);
  }

  for (const [dir, size] of Object.entries(ANDROID_FOREGROUND_SIZES)) {
    const outDir = path.join(tauriDir, dir);
    await fs.mkdir(outDir, { recursive: true });
    await fs.writeFile(path.join(outDir, 'ic_launcher_foreground.png'), await resizeTo(image, size));
  }
  log('  ✓ Tauri Android icons');
}

async function generateTauriIosIcons(image) {
  log('Generating Tauri iOS icons...');
  const iosDir = path.resolve(ROOT, 'src-tauri', 'icons', 'ios');
  await fs.mkdir(iosDir, { recursive: true });

  const iOS_SIZES = [
    { name: 'AppIcon-20x20@1x.png', size: 20 },
    { name: 'AppIcon-20x20@2x.png', size: 40 },
    { name: 'AppIcon-20x20@3x.png', size: 60 },
    { name: 'AppIcon-29x29@1x.png', size: 29 },
    { name: 'AppIcon-29x29@2x.png', size: 58 },
    { name: 'AppIcon-29x29@3x.png', size: 87 },
    { name: 'AppIcon-40x40@1x.png', size: 40 },
    { name: 'AppIcon-40x40@2x.png', size: 80 },
    { name: 'AppIcon-40x40@3x.png', size: 120 },
    { name: 'AppIcon-60x60@2x.png', size: 120 },
    { name: 'AppIcon-60x60@3x.png', size: 180 },
    { name: 'AppIcon-76x76@1x.png', size: 76 },
    { name: 'AppIcon-76x76@2x.png', size: 152 },
    { name: 'AppIcon-83.5x83.5@2x.png', size: 167 },
    { name: 'AppIcon-512@2x.png', size: 1024 },
  ];

  for (const { name, size } of iOS_SIZES) {
    await fs.writeFile(path.join(iosDir, name), await resizeTo(image, size));
  }
  log('  ✓ iOS icons');
}

async function main() {
  const sourceArg = process.argv[2] || process.env.SOURCE_IMAGE;

  log('Loading source image...');
  const imageBuffer = await getSourceImage(sourceArg);

  if (!imageBuffer) {
    log('');
    log('⚠️  No source image available. Using existing icons.');
    log('   To generate icons from the store logo, start the backend or provide');
    log('   a source image: node scripts/generate-icons.mjs <path-or-url>');
    process.exit(0);
  }

  try {
    const metadata = await sharp(imageBuffer).metadata();
    if (!metadata.width || !metadata.height) {
      throw new Error('Invalid image: could not read dimensions');
    }
    log(`Source: ${metadata.width}x${metadata.height}, ${metadata.format}`);

    await generateAndroidIcons(imageBuffer);
    await generateTauriIcons(imageBuffer);
    await generatePWAIcons(imageBuffer);
    await generateTauriAndroidIcons(imageBuffer);
    await generateTauriIosIcons(imageBuffer);

    log('');
    log('✅ All icons generated from store logo!');
    log('');
    log('Tip: For Tauri .ico and .icns, run: npx tauri icon');
  } catch (err) {
    console.error('[icons] Error:', err.message);
    process.exit(1);
  }
}

main();
