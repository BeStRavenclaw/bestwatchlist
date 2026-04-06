/**
 * Icon Generator Script for BeStWatchList Logo
 *
 * This script converts the SVG logo to PNG files at all required sizes
 * for Flutter web, Android, and iOS platforms.
 *
 * Prerequisites:
 * 1. Install Node.js from https://nodejs.org/
 * 2. Run: npm install sharp
 * 3. Run: node generate-icons.js
 */

const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

// Base paths
const svgPath = path.join(__dirname, 'option4-hybrid.svg');
const projectRoot = path.join(__dirname, '..');

// Icon configurations
const iconConfigs = [
  // Web icons
  { size: 192, output: path.join(projectRoot, 'web/icons/Icon-192.png'), maskable: false },
  { size: 512, output: path.join(projectRoot, 'web/icons/Icon-512.png'), maskable: false },
  { size: 192, output: path.join(projectRoot, 'web/icons/Icon-maskable-192.png'), maskable: true },
  { size: 512, output: path.join(projectRoot, 'web/icons/Icon-maskable-512.png'), maskable: true },

  // Web favicon
  { size: 16, output: path.join(projectRoot, 'web/favicon.png'), maskable: false },

  // Android icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
  { size: 48, output: path.join(projectRoot, 'android/app/src/main/res/mipmap-mdpi/ic_launcher.png'), maskable: false },
  { size: 72, output: path.join(projectRoot, 'android/app/src/main/res/mipmap-hdpi/ic_launcher.png'), maskable: false },
  { size: 96, output: path.join(projectRoot, 'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png'), maskable: false },
  { size: 144, output: path.join(projectRoot, 'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png'), maskable: false },
  { size: 192, output: path.join(projectRoot, 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png'), maskable: false },
];

// Function to add safe zone padding for maskable icons (20% padding)
function addMaskablePadding(size) {
  const padding = Math.floor(size * 0.1); // 10% padding on each side = 20% total
  return {
    padded: true,
    paddingSize: padding,
    canvasSize: size
  };
}

async function generateIcon(config) {
  try {
    let svgBuffer = fs.readFileSync(svgPath);

    if (config.maskable) {
      // For maskable icons, we need to add padding (safe zone)
      const { paddingSize, canvasSize } = addMaskablePadding(config.size);
      const innerSize = canvasSize - (paddingSize * 2);

      // First resize the SVG to the inner size
      const resizedIcon = await sharp(svgBuffer)
        .resize(innerSize, innerSize)
        .png()
        .toBuffer();

      // Then create a canvas with padding
      await sharp({
        create: {
          width: canvasSize,
          height: canvasSize,
          channels: 4,
          background: { r: 26, g: 26, b: 26, alpha: 1 } // #1A1A1A background
        }
      })
      .composite([{
        input: resizedIcon,
        top: paddingSize,
        left: paddingSize
      }])
      .png()
      .toFile(config.output);

      console.log(`✓ Generated maskable icon: ${path.basename(config.output)} (${config.size}x${config.size})`);
    } else {
      // Standard icon without padding
      await sharp(svgBuffer)
        .resize(config.size, config.size)
        .png()
        .toFile(config.output);

      console.log(`✓ Generated icon: ${path.basename(config.output)} (${config.size}x${config.size})`);
    }
  } catch (error) {
    console.error(`✗ Failed to generate ${config.output}:`, error.message);
  }
}

async function generateAllIcons() {
  console.log('🎨 BeStWatchList Icon Generator\n');
  console.log(`📂 Source SVG: ${svgPath}\n`);

  for (const config of iconConfigs) {
    await generateIcon(config);
  }

  console.log('\n✅ All icons generated successfully!');
  console.log('\nNext steps:');
  console.log('1. Update web/manifest.json theme colors');
  console.log('2. Test the app: flutter run -d chrome');
  console.log('3. Build for Android/iOS to verify icons\n');
}

// Run the generator
generateAllIcons().catch(console.error);
