# EV Application - Build & Deployment Guide

## Table of Contents
1. Development Environment Setup
2. Building Debug APK
3. Building Release APK
4. Signing APK
5. Deployment to Device
6. Troubleshooting

---

## 1. Development Environment Setup

### Prerequisites
- Windows/Mac/Linux system
- Android SDK (API 30+)
- Flutter SDK (v3.0+)
- Java Development Kit (JDK) 11+
- Android Studio or VS Code

### Install Flutter
```bash
# Download Flutter
git clone https://github.com/flutter/flutter.git

# Add to PATH
# Windows: C:\path\to\flutter\bin
# Mac/Linux: export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter --version
flutter doctor
```

### Android SDK Setup
```bash
# Accept licenses
flutter doctor --android-licenses

# Update Android SDK
# In Android Studio: SDK Manager → Install API 30+
# Minimum target: Android 10 (API 29)
# Recommended: Android 14 (API 34)
```

---

## 2. Building Debug APK

### Quick Build
```bash
# Navigate to project directory
cd /path/to/ev

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug

# Output: build/app/outputs/apk/debug/app-debug.apk
```

### Install on Device
```bash
# Connect device via USB (enable USB debugging)
flutter devices

# Install and run
flutter run

# Or manually install APK
adb install -r build/app/outputs/apk/debug/app-debug.apk
```

---

## 3. Building Release APK

### Prepare for Release
```bash
# Clean previous builds
flutter clean

# Get latest dependencies
flutter pub get

# Run code analysis
flutter analyze

# Build release APK
flutter build apk --release

# Output: build/app/outputs/apk/release/app-release.apk
```

### Build Options
```bash
# Split APKs by architecture (smaller size)
flutter build apk --release --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (64-bit x86)

# Universal APK (all architectures in one)
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

---

## 4. Signing APK

### Method 1: Using keytool (One-time Setup)

**Step 1: Generate Keystore**
```bash
# Windows (run in PowerShell as Administrator)
keytool -genkey -v -keystore $env:USERPROFILE\key.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias flutter_release

# Mac/Linux
keytool -genkey -v -keystore ~/key.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias flutter_release

# Follow prompts:
# - Store Password: [enter secure password]
# - Key Password: [same password]
# - First and Last Name: Head of Department / Department
# - Organization Unit: Electrical Engineering
# - Organization: Your Institution
# - City: [your city]
# - State: [your state]
# - Country Code: [e.g., PK for Pakistan]
```

**Step 2: Create Signing Configuration**

Create `android/key.properties`:
```properties
storePassword=[your-store-password]
keyPassword=[your-key-password]
keyAlias=flutter_release
storeFile=../key.jks
```

**⚠️ IMPORTANT**: Never commit `key.properties` to version control!

**Step 3: Configure Gradle**

Edit `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

**Step 4: Build Signed APK**
```bash
flutter build apk --release
```

### Method 2: Manual Signing (Alternative)

If keystore setup fails:
```bash
# Build unsigned APK
flutter build apk --release --no-sign

# Sign manually with jarsigner
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore ~/key.jks \
  build/app/outputs/apk/release/app-release-unsigned.apk \
  flutter_release

# Verify signature
jarsigner -verify -certs build/app/outputs/apk/release/app-release-unsigned.apk
```

---

## 5. Deployment to Device

### Via USB
```bash
# Enable USB debugging on device
# Device → Settings → Developer Options → USB Debugging (ON)

# Connect device
adb devices

# Install APK
adb install -r build/app/outputs/apk/release/app-release.apk

# Or use Flutter
flutter install
```

### Via ADB Wireless
```bash
# Connect device via USB first

# Enable wireless debugging
adb tcpip 5555

# Find device IP (in Android settings)
# Connect wirelessly
adb connect [device-ip]:5555

# Install
adb install -r build/app/outputs/apk/release/app-release.apk
```

### APK Transfer Methods
1. **Google Drive/Cloud**: Upload APK and download on device
2. **Email**: Send via email and open from device
3. **USB Transfer**: Copy APK to device storage
4. **ADB**: Use adb install command
5. **QR Code**: Generate QR linking to APK location

---

## 6. Troubleshooting

### Build Issues

**Issue**: "Flutter SDK not found"
```bash
# Solution: Update local.properties
# Ensure flutter.sdk path is correct
cat local.properties

# Or regenerate
flutter config --android-sdk /path/to/android/sdk
```

**Issue**: Gradle build fails
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug

# Check Android SDK version
flutter doctor -v

# Upgrade Gradle
# Edit android/gradle/wrapper/gradle-wrapper.properties
# gradle-6.7 → gradle-8.0
```

**Issue**: Out of memory during build
```bash
# Increase heap size
export _JAVA_OPTIONS="-Xmx4g"
flutter build apk --release
```

### APK Installation Issues

**Issue**: "App not installed"
```bash
# Check device storage
adb shell df

# Clear package cache
adb shell pm clear com.ev.studentrecords

# Reinstall
adb install -r build/app/outputs/apk/release/app-release.apk
```

**Issue**: "Signature verification failed"
```bash
# Uninstall previous version
adb uninstall com.ev.studentrecords

# Clear cache
adb shell pm cache clear

# Reinstall
adb install build/app/outputs/apk/release/app-release.apk
```

**Issue**: APK crashes on startup
```bash
# Check logcat
adb logcat -s flutter:*

# Run debug version for logs
flutter run -v

# Check database initialization
# App should create database automatically on first run
```

### Performance Issues

**Issue**: Slow database queries
```dart
// Add indexes to frequently queried fields
// Already implemented in database_service.dart:
// - idx_behaviorColor
// - idx_classAcademicYear
```

**Issue**: High memory usage
```bash
# Profile app
flutter run --profile

# Use DevTools
devtools

# Check for memory leaks in student list screens
```

---

## Automated Build Pipeline

### Using Fastlane (Optional)

**Install Fastlane**:
```bash
sudo gem install fastlane
fastlane init
```

**Build with Fastlane**:
```bash
fastlane android build_release
```

### CI/CD with GitHub Actions

Create `.github/workflows/build.yml`:
```yaml
name: Build APK

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release.apk
          path: build/app/outputs/apk/release/app-release.apk
```

---

## Distribution Options

### 1. Direct APK Distribution
- Share APK file via email, drive, cloud storage
- Users download and install manually
- Enable "Unknown Sources" in Android settings

### 2. Google Play Store
```bash
# Build AAB (Android App Bundle)
flutter build appbundle --release

# Upload to Play Console
# https://play.google.com/console
```

### 3. Internal Testing
```bash
# Build debug APK
flutter build apk --debug

# Share with testers via TestFlight alternative
# Or use internal Firebase Testing Lab
```

---

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1
#         ↑       ↑
#     Version  Build Number
```

Update in Android (`android/app/build.gradle`):
```gradle
versionCode 1      // Increment for each release
versionName "1.0.0" // Format: major.minor.patch
```

---

## Keystore Backup

**CRITICAL**: Backup your keystore file securely!

```bash
# Create backup
cp ~/key.jks ~/key.jks.backup

# Store securely (encrypted external drive, cloud backup)
# If lost, you cannot update app on Play Store!
```

---

## Post-Build Checklist

- [ ] APK tested on Android 10+ devices
- [ ] Database initializes correctly
- [ ] All screens navigate properly
- [ ] Student CRUD operations work
- [ ] Photo/document upload works
- [ ] Call/SMS/WhatsApp functions tested
- [ ] Backup/restore functions tested
- [ ] Export to PDF/Excel works
- [ ] No crashes in logcat
- [ ] App size is acceptable (~50-60 MB)
- [ ] Battery usage is normal
- [ ] Storage usage is minimal

---

## Support Commands

```bash
# View help
flutter build apk --help

# Verbose output
flutter build apk --release -v

# Specific Android version
flutter build apk --release --android-gradle-daemon

# Check APK info
aapt dump badging build/app/outputs/apk/release/app-release.apk

# Verify APK signature
jarsigner -verify -verbose -certs build/app/outputs/apk/release/app-release.apk
```

---

**Last Updated**: January 2026  
**Compatibility**: Flutter 3.0+, Android 10+
