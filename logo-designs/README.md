# BeStWatchList Logo Implementation Guide

This directory contains your custom black and gold logo design and scripts to implement it across your Flutter app.

## Your Logo Design

**File:** `option4-hybrid.svg`

- **Design:** Clapperboard inside a streaming screen
- **Colors:** Elegant black (#1A1A1A) and gold (#D4AF37)
- **Features:**
  - Tilted clapper bar with black/gold stripes
  - Centered play button
  - Modern monitor frame with stand
  - Clean, professional aesthetic

## Quick Start

### Option 1: Automated Generation (Recommended)

1. **Install Node.js** (if not already installed):
   - Download from: https://nodejs.org/
   - Install the LTS version

2. **Install dependencies:**
   ```bash
   cd logo-designs
   npm install
   ```

3. **Generate all icons:**
   ```bash
   npm run generate
   ```

This will automatically create PNG files at all required sizes for:
- Web (192x192, 512x512, maskable variants, favicon)
- Android (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- iOS (coming soon - requires macOS)

### Option 2: Manual Generation

If you prefer to generate icons manually or don't have Node.js:

1. **Use an online SVG to PNG converter:**
   - https://cloudconvert.com/svg-to-png
   - https://svgtopng.com/

2. **Required sizes:**

   **Web Icons:**
   - `web/icons/Icon-192.png` → 192x192px
   - `web/icons/Icon-512.png` → 512x512px
   - `web/icons/Icon-maskable-192.png` → 192x192px with 20% padding
   - `web/icons/Icon-maskable-512.png` → 512x512px with 20% padding
   - `web/favicon.png` → 16x16px

   **Android Icons:**
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` → 48x48px
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` → 72x72px
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` → 96x96px
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` → 144x144px
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` → 192x192px

   **Note:** Maskable icons need 20% safe zone padding (10% on each side) with #1A1A1A background.

## Post-Generation Steps

### 1. Update Web Manifest

Edit `web/manifest.json` and update the theme colors:

```json
{
  "background_color": "#1A1A1A",
  "theme_color": "#D4AF37"
}
```

### 2. Test Web App

```bash
flutter run -d chrome
```

Check:
- Browser tab favicon
- PWA icon when adding to home screen
- Icon appears correctly in both light and dark themes

### 3. Test Android App

```bash
flutter run -d <your-android-device>
```

Check:
- App icon on home screen
- App icon in app drawer
- Adaptive icon on Android 8.0+

### 4. iOS Icons (macOS only)

For iOS, you'll need to generate the icon set in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Navigate to `Runner/Assets.xcassets/AppIcon.appiconset`
3. Drag and drop the PNG files for each required size

Or use an online tool like: https://www.appicon.co/

## Files in This Directory

- `option4-hybrid.svg` - Your final logo design (master file)
- `option1-film-reel.svg` - Alternative design option
- `option2-clapperboard.svg` - Alternative design option
- `option3-screen-star.svg` - Alternative design option
- `preview.html` - Interactive preview of all designs
- `generate-icons.js` - Automated icon generation script
- `package.json` - Node.js dependencies
- `README.md` - This file

## Design Specifications

- **Primary Color:** Gold (#D4AF37)
- **Secondary Color:** Deep Black (#1A1A1A)
- **Format:** SVG (vector, infinitely scalable)
- **Aspect Ratio:** 1:1 (square)
- **Style:** Minimal, geometric, elegant

## Troubleshooting

**Icons look blurry on Android:**
- Make sure you've generated all density variants (mdpi through xxxhdpi)
- Clear app data and reinstall

**Maskable icons look cut off:**
- Ensure 20% safe zone padding (10% on each side)
- Background should be #1A1A1A

**Favicon not showing in browser:**
- Hard refresh: Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)
- Clear browser cache

## Need Help?

If you encounter any issues:
1. Check that the SVG file exists and is valid
2. Verify Node.js and npm are installed correctly
3. Make sure file paths in generate-icons.js are correct
4. Check console output for specific error messages

---

🎬 Enjoy your new elegant black and gold BeStWatchList logo!
