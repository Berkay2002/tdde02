# Google Play Store Release Guide

This guide walks you through preparing and publishing your **Snapgredient** app to the Google Play Store.

> 📊 **See [RELEASE_STATUS.md](RELEASE_STATUS.md) for current progress tracking**

## 📋 Pre-Release Checklist

### ✅ Completed
- [x] Release signing configuration in `build.gradle.kts`
- [x] ProGuard rules for code obfuscation
- [x] Minimum SDK set to 23 (Android 6.0+)
- [x] App name updated to "Snapgredient"
- [x] Application ID set to `com.snapgredient.app`
- [x] `.gitignore` updated to exclude sensitive files
- [x] Upload keystore generated (`C:\Users\berka\upload-keystore.jks`)
- [x] `key.properties` configured
- [x] Firebase updated with new package name
- [x] SHA-1 and SHA-256 certificates added to Firebase
- [x] Release APK built successfully (68.6 MB)
- [x] App Bundle built successfully (54.7 MB)
- [x] Firebase App Check enabled (Play Integrity for production)
- [x] AI rate limiting configured (5-hour windows)

### 🔲 Action Required
- [x] Create custom app icons (launcher icons)
- [ ] Backup keystore to secure location
- [ ] Complete Google Play Console setup
- [ ] Create and host privacy policy
- [ ] Upload to Play Store

---

## ✅ 1️⃣ Application ID (COMPLETED)

**Status**: ✅ Done

The app has been configured with a unique application ID:
- **Package Name**: `com.snapgredient.app`
- **App Name**: Snapgredient

Files updated:
- `android/app/build.gradle.kts` - applicationId and namespace
- `android/app/src/main/AndroidManifest.xml` - app label
- `android/app/src/main/kotlin/com/snapgredient/app/MainActivity.kt`
- `lib/core/constants/app_constants.dart`
- `pubspec.yaml`

Firebase updated:
- New Android app created with package `com.snapgredient.app`
- App ID: `1:593064071345:android:b5fdfdbc53b59dceb71290`
- `google-services.json` and `firebase_options.dart` updated

---

## ✅ 2️⃣ Upload Keystore (COMPLETED)

**Status**: ✅ Done

Keystore generated and configured:
- **Location**: `C:\Users\berka\upload-keystore.jks`
- **Alias**: `upload`
- **Validity**: 10,000 days (until ~2053)
- **Owner**: CN=Berkay Orhan, OU=Berkay Orhan, O=Berkay Orhan, L=Norrkoping, ST=Ostergotland, C=SE


### ⚠️ CRITICAL: Backup Your Keystore!
- Store `upload-keystore.jks` in a secure location (cloud backup, etc.)
- You'll need this keystore to update your app FOREVER
- If you lose it, you cannot update your app on Play Store!

---

## ✅ 3️⃣ key.properties (COMPLETED)

**Status**: ✅ Done

File created at `android/key.properties` with keystore credentials.

**Never commit this file to git!** (Already added to `.gitignore`)

---

## ✅ 4️⃣ Create App Icons (COMPLETED)

**Status**: ✅ Done

App icons have been generated using `flutter_launcher_icons` package.

### Generated Icons
| Platform   | Status | Notes                                    |
|------------|--------|------------------------------------------|
| Android    | ✅     | All mipmap densities generated           |
| Adaptive   | ✅     | White background with transparent logo   |
| iOS        | ✅     | Alpha channel removed for App Store      |
| Web        | ✅     | Favicon and icons generated              |
| Windows    | ✅     | Icon generated                           |
| macOS      | ✅     | Icon generated                           |

### Configuration
Defined in `pubspec.yaml` under `flutter_launcher_icons` section.

### Play Store Icon
Use `logo.png` from project root for your Play Store listing (512x512 PNG).

### Regenerate Icons (if needed)
```powershell
dart run flutter_launcher_icons
```

---

## ✅ 5️⃣ Build Release App Bundle (COMPLETED)

**Status**: ✅ Done

Both release builds have been generated successfully:

| Build Type | Location | Size |
|------------|----------|------|
| **App Bundle** | `build/app/outputs/bundle/release/app-release.aab` | 54.7 MB |
| **APK** | `build/app/outputs/flutter-apk/app-release.apk` | 68.6 MB |

### Rebuild Commands (if needed)
```powershell
cd c:\Users\berka\Project\flutter\tdde02
flutter clean
flutter pub get
flutter build appbundle --release
```

### Install APK for testing
```powershell
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔲 6️⃣ Google Play Console Setup

**Status**: 🔲 Pending - Account created, app setup needed

### Create Developer Account
1. Go to [Google Play Console](https://play.google.com/console)
2. ✅ Pay the one-time $25 registration fee (Done)
3. Complete identity verification

### Create App Listing
1. Click "Create app"
2. Fill in:
   - **App name**: Snapgredient
   - **Default language**: English (US)
   - **App or game**: App
   - **Free or paid**: Free (or Paid if monetizing)

### Required Store Listing Assets
| Asset                | Requirements                          |
|----------------------|---------------------------------------|
| App icon             | 512x512 PNG                          |
| Feature graphic      | 1024x500 PNG                         |
| Phone screenshots    | Min 2, 16:9 or 9:16, 320-3840 px     |
| Tablet screenshots   | Min 1 (7" and 10" tablets)           |
| Short description    | Max 80 characters                    |
| Full description     | Max 4000 characters                  |

### Content Rating
Complete the content rating questionnaire - your app likely qualifies for:
- **PEGI 3** (Europe)
- **Everyone** (US - ESRB)

### Privacy Policy
You MUST have a privacy policy URL. Create one addressing:
- Data collection (camera, photos)
- Firebase authentication data
- How user data is stored and protected

Free privacy policy generators:
- [Termly](https://termly.io)
- [PrivacyPolicies.com](https://www.privacypolicies.com)

---

## 7️⃣ Pre-Launch Report

Before releasing:
1. Upload your .aab to the **Internal testing** track
2. Review the Pre-launch report for:
   - Crash reports
   - Performance issues
   - Accessibility warnings
   - Security vulnerabilities

---

## 8️⃣ Release Tracks

| Track              | Purpose                                |
|--------------------|----------------------------------------|
| Internal testing   | Quick testing (up to 100 testers)     |
| Closed testing     | Beta testing with invite links        |
| Open testing       | Public beta                           |
| Production         | Full public release                   |

**Recommended Flow**: Internal → Closed → Production

---

## 9️⃣ App Signing by Google Play

Google Play App Signing is recommended:
- Google manages your app signing key
- You keep an upload key (your keystore)
- More secure - if upload key is compromised, Google can help

When you first upload your app bundle, you'll be prompted to opt in.

---

## 📝 App Description Template

### Short Description (80 chars max)
```
Snap your ingredients, get delicious AI-powered recipes instantly!
```

### Full Description
```
Snapgredient transforms your available ingredients into delicious recipes using advanced AI technology.

📸 SNAP & COOK
Simply take a photo of your ingredients, and our AI will identify them and generate personalized recipes just for you.

🍳 FEATURES
• Instant ingredient detection from photos
• AI-powered recipe generation
• Support for dietary restrictions (Vegan, Gluten-Free, etc.)
• Save your favorite recipes
• Works with any cuisine type

👨‍🍳 PERFECT FOR
• Reducing food waste by using what you have
• Finding dinner inspiration quickly
• Cooking with dietary restrictions
• Learning new recipes

🔒 PRIVACY FIRST
Your photos are processed securely and never stored. Sign in with Google for a seamless experience.

Download now and turn your ingredients into amazing meals!
```

---

## ⚠️ Common Rejection Reasons

1. **Missing privacy policy** - Must be accessible and accurate
2. **Broken functionality** - Test all features thoroughly
3. **Misleading description** - Be accurate about AI capabilities
4. **Copyright issues** - Ensure all images/assets are licensed
5. **Crashes on startup** - Test on multiple devices

---

## 🔐 Security Reminders

- [x] Enable Firebase App Check for production
- [x] Review Firestore security rules
- [x] Configure AI rate limiting
- [ ] Remove any debug/test API keys
- [ ] Enable Firebase Authentication verification

---

## 🛡️ AI Security & Rate Limiting (COMPLETED)

**Status**: ✅ Done

The app uses Gemini AI via Firebase AI Logic. To prevent API abuse and control costs:

### Firebase App Check
Enabled in `lib/main.dart` to verify requests come from your legitimate app:
- **Production**: Play Integrity (Android), Device Check (iOS)
- **Debug**: Debug provider for testing

### Rate Limiting Strategy
Implemented in `lib/core/services/rate_limiter_service.dart`:

| Resource | Per 5-Hour Window | Per Day | Rationale |
|----------|-------------------|---------|------------|
| Recipe Generation | 5 | 15 | ~3 meals × 5 options |
| Ingredient Scans | 8 | 25 | Allows retries |

### Pro Users (Beta Testers)
Users with emails in the whitelist get significantly higher limits:

| Resource | Per 5-Hour Window | Per Day |
|----------|-------------------|----------|
| Recipe Generation | 50 | 200 |
| Ingredient Scans | 100 | 300 |

**To add a Pro user:**
1. Open `lib/core/constants/app_constants.dart`
2. Add their email (lowercase) to `proUserEmails` list:
   ```dart
   static const List<String> proUserEmails = [
     'berkayorhan@hotmail.se',
     'newtester@example.com',  // Add here
   ];
   ```
3. Rebuild the app

**Why 5-hour windows?**
- Aligns with natural meal prep cycles (breakfast → lunch → dinner)
- Encourages spread usage throughout the day
- Prevents burst abuse while being generous for genuine use

### Firestore Security Rules
Server-side validation in `firestore.rules`:
- Counters can only increment by 1 or reset
- Users can only access their own usage data
- No deletion of usage history allowed

### User Experience
When limits are reached, users see friendly messages:
- "Recipe credits used up for now" with time until reset
- "More credits available in X hours and Y minutes"

### Files Modified
- `lib/main.dart` - App Check activation
- `lib/core/constants/app_constants.dart` - Rate limit values
- `lib/core/services/rate_limiter_service.dart` - 5-hour window logic
- `lib/core/errors/rate_limit_exceptions.dart` - User-friendly messages
- `firestore.rules` - Server-side validation

---

## 📱 Testing Before Release

Test your release build on real devices:
```powershell
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

Test on:
- [ ] Low-end Android device
- [ ] High-end Android device
- [ ] Android 6.0 (API 23)
- [ ] Latest Android version
- [ ] Different screen sizes

---

## Need Help?

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Documentation](https://firebase.google.com/docs)
