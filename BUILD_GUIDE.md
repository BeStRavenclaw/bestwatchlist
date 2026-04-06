# Build Guide for BeStWatchList

This guide explains how to build and sign the BeStWatchList app for release.

## Prerequisites

- Flutter SDK installed and configured
- Android SDK with command-line tools
- Java Development Kit (JDK) 17 or higher

## Environment Setup

### 1. Configure API Keys

The app requires a TMDB (The Movie Database) API key to function.

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and replace `YOUR_API_KEY_HERE` with your actual TMDB API key:
   ```
   TMDB_API_KEY=your_actual_api_key_here
   ```

   **Get your API key:** https://www.themoviedb.org/settings/api

**IMPORTANT:** Never commit the `.env` file to version control. It's already included in `.gitignore`.

---

## Release Signing Configuration

### 2. Generate a Release Keystore

To sign your release APK, you need to create a keystore file. Run this command:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Follow the prompts:**
- Enter a strong password for the keystore
- Enter a strong password for the key (can be the same as keystore password)
- Fill in your organizational information

**IMPORTANT:** Save the keystore file (`upload-keystore.jks`) and passwords securely. You'll need them for all future releases.

### 3. Configure Signing Properties

1. Create a `key.properties` file in the `android/` directory:
   ```bash
   cd android
   cp key.properties.example key.properties
   ```

2. Edit `android/key.properties` with your actual values:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

**IMPORTANT:** Never commit `key.properties` or `*.jks` files to version control. They're already included in `.gitignore`.

---

## Building the App

### Development Build (Debug)

For testing during development:

```bash
flutter run
```

or to build a debug APK:

```bash
flutter build apk --debug
```

### Production Build (Release)

#### Build Release APK

```bash
flutter build apk --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

#### Build App Bundle (for Google Play Store)

For Play Store distribution, use an app bundle instead:

```bash
flutter build appbundle --release
```

The bundle will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Installation

### Install Release APK on Device

Connect your Android device via USB and enable USB debugging, then:

```bash
flutter install --release
```

Or manually install the APK:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Troubleshooting

### API Not Working in Release Build

If the TMDB API doesn't work in your release build:

1. **Check `.env` file exists** in the project root
2. **Verify TMDB_API_KEY** is set correctly in `.env`
3. **Rebuild the app** - environment variables are baked into the APK at build time
4. **Check AndroidManifest.xml** has `<uses-permission android:name="android.permission.INTERNET"/>`

### Signing Errors

If you get signing errors:

1. **Verify `key.properties`** exists in `android/` directory
2. **Check keystore file path** in `key.properties` (relative to `android/` directory)
3. **Verify passwords** are correct
4. **Ensure keystore file** (`upload-keystore.jks`) exists

### Build Fails with "Unable to load asset"

If the build fails with an error about loading `.env`:

1. **Ensure `.env` is listed** in `pubspec.yaml` under `assets:`
2. **Run `flutter clean`** and rebuild:
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

---

## Version Management

### Update Version Number

Edit `pubspec.yaml` and update the version:

```yaml
version: 1.0.1+2
#         ^     ^
#         |     |
#         |     Build number (increment for each release)
#         Version name (semantic versioning)
```

**Versioning rules:**
- **Version name** (e.g., `1.0.1`): Follows semantic versioning (MAJOR.MINOR.PATCH)
- **Build number** (e.g., `+2`): Must always increase for each release

---

## Security Best Practices

### Files to NEVER Commit

These files are already in `.gitignore`, but double-check they're never committed:

- `.env` - Contains API keys
- `android/key.properties` - Contains signing passwords
- `*.keystore`, `*.jks` - Signing keystores
- `build/` - Build artifacts

### Backup Your Signing Keys

**CRITICAL:** Back up these files securely:
- `upload-keystore.jks` (or whatever you named it)
- Keystore passwords
- Key alias and passwords

**Without these, you cannot update your app on the Play Store!**

---

## Clean Build

If you encounter issues, try a clean build:

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter build apk --release
```

---

## Build Configuration Summary

| Configuration | File | Purpose |
|--------------|------|---------|
| API Keys | `.env` | TMDB API key (required for app to function) |
| Signing Config | `android/key.properties` | Keystore paths and passwords |
| Signing Keystore | `upload-keystore.jks` | Release signing certificate |
| App Version | `pubspec.yaml` | Version name and build number |

---

## Additional Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [TMDB API Documentation](https://developers.themoviedb.org/3)

---

## Quick Reference Commands

```bash
# Install dependencies
flutter pub get

# Run in development
flutter run

# Build debug APK
flutter build apk --debug

# Build release APK
flutter build apk --release

# Build app bundle (Play Store)
flutter build appbundle --release

# Install on connected device
flutter install --release

# Clean build artifacts
flutter clean
```
