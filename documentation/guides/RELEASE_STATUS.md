# Snapgredient - Release Status

**Last Updated**: December 3, 2025

This document tracks the progress of preparing **Snapgredient** for Google Play Store release.

---

## 📱 App Information

| Property | Value |
|----------|-------|
| **App Name** | Snapgredient |
| **Package Name** | `com.snapgredient.app` |
| **Version** | 1.0.0+1 |
| **Min SDK** | 23 (Android 6.0 Marshmallow) |
| **Target SDK** | Latest (via Flutter) |

---

## ✅ Completed Tasks

### 1. App Renaming & Rebranding
- [x] Changed app name from "AI Recipe Generator" to **Snapgredient**
- [x] Updated `pubspec.yaml` - package name to `snapgredient`
- [x] Updated `AndroidManifest.xml` - app label
- [x] Updated `app_constants.dart` - `appName` constant
- [x] Updated all test file imports

### 2. Package Name Migration
- [x] Changed from `com.example.flutter_application_1` to `com.snapgredient.app`
- [x] Updated `build.gradle.kts` - `applicationId` and `namespace`
- [x] Created new Kotlin package structure: `com/snapgredient/app/`
- [x] Moved `MainActivity.kt` to new package location
- [x] Removed old `com/example/flutter_application_1/` directory

### 3. Firebase Configuration
- [x] Created new Android app in Firebase Console
- [x] **New App ID**: `1:593064071345:android:b5fdfdbc53b59dceb71290`
- [x] Updated `google-services.json` with new app configuration
- [x] Updated `firebase_options.dart` with new Android app ID
- [x] Updated `firebase.json` with new app ID references
- [x] Added SHA-1 certificate: `36:E8:FB:F9:0E:5A:EC:54:CA:04:B3:EC:50:39:83:A9:F0:18:8B:9F`
- [x] Added SHA-256 certificate: `0F:82:22:0C:54:B5:34:AE:4B:86:A1:22:00:4B:F5:B9:5C:41:65:E6:3B:1E:84:0F:CB:7F:42:E5:4A:54:D9:DA`

### 4. Release Signing Setup
- [x] Generated upload keystore: `C:\Users\berka\upload-keystore.jks`
  - Validity: 10,000 days (until ~2053)
  - Algorithm: RSA 2048-bit
  - Alias: `upload`
  - Owner: `CN=Berkay Orhan, OU=Berkay Orhan, O=Berkay Orhan, L=Norrkoping, ST=Ostergotland, C=SE`
- [x] Created `android/key.properties` with keystore credentials
- [x] Configured `build.gradle.kts` for release signing
- [x] Added `key.properties` and `*.jks` to `.gitignore`

### 5. ProGuard/R8 Configuration
- [x] Created `android/app/proguard-rules.pro` with rules for:
  - Flutter engine
  - Firebase & Google Play Services
  - Google Play Core (deferred components)
  - Google Sign-In
  - Camera plugin
  - Image Picker
  - Permission Handler
  - OkHttp
  - Kotlin
- [x] Enabled minification and shrinking in release builds

### 6. Build Artifacts Generated
- [x] **Release APK**: `build/app/outputs/flutter-apk/app-release.apk` (68.6 MB)
- [x] **App Bundle**: `build/app/outputs/bundle/release/app-release.aab` (54.7 MB)

### 7. App Icons Generated
- [x] Configured `flutter_launcher_icons` in `pubspec.yaml`
- [x] Generated Android launcher icons (all densities)
- [x] Generated Android adaptive icons with white background
- [x] Generated iOS icons (alpha removed for App Store compliance)
- [x] Generated Web favicon and icons
- [x] Generated Windows and macOS icons

### 8. AI Security & Rate Limiting
- [x] Enabled **Firebase App Check** with Play Integrity (production) / Debug (development)
- [x] Added SHA-1 and SHA-256 certificates to Snapgredient app in Firebase
- [x] Implemented **5-hour window rate limiting** (aligned with meal cycles)
- [x] Added server-side validation in Firestore security rules
- [x] Configured production-ready rate limits:
  - 5 recipes per 5-hour window
  - 15 recipes per day
  - 8 ingredient scans per 5-hour window  
  - 25 ingredient scans per day
- [x] User-friendly error messages when limits reached
- [x] **Pro user system** for beta testers with generous limits:
  - 50 recipes per 5-hour window
  - 200 recipes per day
  - Emails configured in `lib/core/constants/app_constants.dart`

---

## 🔲 Pending Tasks

### Before Play Store Upload
- [x] **Create custom app icons** - Generated using flutter_launcher_icons
  - All Android mipmap sizes generated (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
  - Adaptive icons configured with white background
  - iOS, Web, Windows, and macOS icons also generated
  - Use `logo.png` (512x512) for Play Store listing
- [ ] **Backup keystore** to secure cloud storage

### Google Play Console
- [ ] Create app in Google Play Console
- [ ] Complete **App content** section:
  - [ ] Privacy policy URL
  - [ ] App access instructions
  - [ ] Ads declaration (no ads)
  - [ ] Content rating questionnaire
  - [ ] Target audience (13+)
  - [ ] Data safety form
- [ ] Create **Store listing**:
  - [ ] Short description (80 chars)
  - [ ] Full description (4000 chars)
  - [ ] Feature graphic (1024x500)
  - [ ] Phone screenshots (2-8)
  - [ ] Tablet screenshots (optional)
- [ ] Upload `.aab` to Internal testing track
- [ ] Review Pre-launch report
- [ ] Promote to Production

### Privacy Policy
- [ ] Create privacy policy addressing:
  - Camera permission usage
  - Photo processing (not stored)
  - Google Sign-In data
  - Firebase data storage
  - AI processing via Gemini API
- [ ] Host privacy policy (GitHub Pages, Google Doc, or website)

---

## 📁 Key File Locations

| File | Path |
|------|------|
| Upload Keystore | `C:\Users\berka\upload-keystore.jks` |
| Key Properties | `android/key.properties` |
| Google Services | `android/app/google-services.json` |
| Firebase Options | `lib/firebase_options.dart` |
| ProGuard Rules | `android/app/proguard-rules.pro` |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` |
| App Bundle | `build/app/outputs/bundle/release/app-release.aab` |

---

## 🔐 Security Credentials

### Keystore Information
```
Alias: upload
Keystore: C:\Users\berka\upload-keystore.jks
...
```

---

## ⚠️ Important Reminders

1. **NEVER commit `key.properties`** - Contains keystore passwords
2. **NEVER commit `upload-keystore.jks`** - Your signing key
3. **BACKUP your keystore** - You cannot update the app without it
4. **Keep SHA certificates in Firebase** - Required for Google Sign-In

---

## 🛠️ Build Commands

### Clean Build
```powershell
cd project_root_directory
flutter clean
flutter pub get
```

### Build Release APK
```powershell
flutter build apk --release
```

### Build App Bundle (for Play Store)
```powershell
flutter build appbundle --release
```

### Install on Device
```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0+1 | Dec 3, 2025 | Initial release preparation |

---

## Support

For issues with the release process, refer to:
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)
