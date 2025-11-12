# iOS Firebase Setup Guide - Complete Setup Instructions

> **For the macOS Team Member**: This guide contains everything you need to complete the iOS setup.  
> All configuration files have been prepared on Windows - you just need to run the final setup steps on macOS.

---

## 📋 Current Status - What's Already Done

Your team has already completed all Windows-compatible configuration:

### ✅ Completed (Ready for You)

1. **Podfile Created** (`ios/Podfile`)
   - iOS minimum version: 13.0
   - Firebase dependencies configured
   - Build settings optimized

2. **GoogleService-Info.plist Downloaded** (`ios/Runner/GoogleService-Info.plist`)
   - Project ID: `eternal-water-477911-m6`
   - Bundle ID: `com.example.flutterApplication1`
   - File already copied to correct location

3. **Info.plist Configured** (`ios/Runner/Info.plist`)
   - ✅ Camera permission
   - ✅ Photo Library permission
   - ✅ Microphone permission (placeholder)
   - ✅ Minimum OS version: iOS 13.0
   - ✅ Portrait-only orientation (matching Android)
   - ✅ Google Sign-In URL Scheme configured

4. **AppDelegate.swift Updated** (`ios/Runner/AppDelegate.swift`)
   - ✅ Firebase initialization code added
   - ✅ Imports FirebaseCore

5. **App Check Enabled** (`lib/main.dart`)
   - ✅ Configured with debug provider
   - ✅ Token auto-refresh enabled

6. **Tests Created** (`ios/RunnerTests/RunnerTests.swift`)
   - ✅ Basic unit tests
   - ✅ Firebase configuration test

7. **Automation Scripts** (All ready to use!)
   - ✅ `ios/scripts/setup.sh` - Automated setup
   - ✅ `ios/scripts/build.sh` - Build script
   - ✅ `ios/scripts/test.sh` - Test script
   - ✅ `ios/fastlane/Fastfile` - CI/CD automation

### ⏳ What You Need to Do (macOS Only)

These 5 steps can ONLY be done on macOS with Xcode:

1. **Add GoogleService-Info.plist to Xcode project** (critical!)
2. **Install CocoaPods dependencies** (`pod install`)
3. **Configure App Check in Firebase Console**
4. **Set up code signing in Xcode**
5. **Build and test the app**

**Time Required**: ~15-20 minutes for first-time setup

---

## 🚀 Quick Start (For macOS Team Member)

### Option 1: Automated Setup (Recommended)

The easiest way - just run the setup script:

```bash
# From project root
chmod +x ios/scripts/setup.sh
./ios/scripts/setup.sh
```

The script will:
- ✅ Check that Xcode, CocoaPods, and Flutter are installed
- ✅ Verify GoogleService-Info.plist exists
- ✅ Install Flutter dependencies
- ✅ Generate Riverpod code
- ✅ Install CocoaPods dependencies
- ✅ Open Xcode with instructions to add GoogleService-Info.plist

Then follow the on-screen instructions to add the file via Xcode.

### Option 2: Manual Setup (Step-by-Step)

If you prefer to do it manually, follow the detailed steps below.

---

## 📖 Detailed Setup Instructions

### Prerequisites Check

Before starting, verify you have:

```bash
# Check Xcode is installed
xcodebuild -version
# Should show: Xcode 14.0 or higher

# Check CocoaPods is installed
pod --version
# Should show: 1.11.0 or higher

# Check Flutter is installed
flutter --version
# Should show: Flutter 3.x.x

# If CocoaPods is NOT installed:
sudo gem install cocoapods
```

---

## Step 1: Add GoogleService-Info.plist to Xcode Project

**⚠️ CRITICAL STEP**: The file is already copied, but Xcode won't recognize it until you add it through Xcode's interface.

### Why This Matters
- Just copying the file isn't enough
- Xcode needs to know the file belongs to the Runner target
- Without this, Firebase won't initialize and the app will crash

### How to Do It

1. **Open the workspace** (NOT the .xcodeproj!):
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode's Project Navigator** (left sidebar):
   - Right-click on the **Runner** folder (blue icon)
   - Select **"Add Files to 'Runner'..."**

3. **In the file dialog**:
   - Navigate to `ios/Runner/`
   - Select `GoogleService-Info.plist`

4. **In the options dialog** (bottom of file picker):
   - ✅ Check: **"Copy items if needed"**
   - ✅ Check: **"Create groups"** (NOT "Create folder references")
   - ✅ Check: **"Add to targets: Runner"** (must be checked!)

5. **Click "Add"**

6. **Verify it worked**:
   - The file should now appear in the **Runner** folder in Project Navigator
   - It should have a document icon (not a folder icon)
   - Click on it - you should see the XML content in the editor

### Common Mistakes to Avoid
- ❌ Adding to "Flutter" folder instead of "Runner"
- ❌ Not checking "Add to targets: Runner"
- ❌ Creating folder reference instead of group
- ❌ Opening Runner.xcodeproj instead of Runner.xcworkspace

---

## Step 2: Install CocoaPods Dependencies

CocoaPods will download all Firebase SDK libraries for iOS.

```bash
# Navigate to iOS directory
cd ios

# Install dependencies
pod install

# This will take 2-5 minutes on first run
# You'll see output like:
# Analyzing dependencies
# Downloading dependencies
# Installing Firebase (10.x.x)
# Installing FirebaseAuth (10.x.x)
# Installing FirebaseCore (10.x.x)
# Installing FirebaseFirestore (10.x.x)
# Installing FirebaseAI (3.x.x)
# Installing FirebaseAppCheck (10.x.x)
# ...
# Pod installation complete! 28 pods installed

# Return to project root
cd ..
```

### If You Get Errors

**"Unable to find a specification for..."**
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

**"CocoaPods could not find compatible versions..."**
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

---

## Step 3: Configure Code Signing

### Why This Matters
- iOS apps must be signed to run on simulator or device
- You need an Apple Developer account (free accounts work for development)

### How to Do It

1. **In Xcode**, with Runner.xcworkspace still open:
   - Click **Runner** project in Project Navigator (top blue icon)
   - Select **Runner** target (under "Targets")
   - Click **"Signing & Capabilities"** tab

2. **Select your team**:
   - In "Team" dropdown, select your Apple ID
   - If you don't see your Apple ID: Click "Add Account..." and sign in
   - Xcode will automatically generate a provisioning profile

3. **Verify Bundle Identifier**:
   - Should be: `com.example.flutterApplication1`
   - If different, update it to match

4. **Repeat for Runner (Tests)** target if needed

---

## Step 4: Build and Run the App

### First Build

```bash
# Clean everything
flutter clean
flutter pub get

# Generate Riverpod code
dart run build_runner build --delete-conflicting-outputs

# List available devices
flutter devices

# Run on simulator (first build takes 3-5 minutes)
flutter run -d iPhone
```

### Expected First Run Behavior

1. **App Check Debug Token** will appear in logs:
   ```
   [Firebase/AppCheck][I-FAA002001] Firebase App Check Debug Token: 
   XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```
   
2. **Copy that token** - you'll need it in the next step

3. **App might show errors** until you add the debug token to Firebase Console

---

## Step 5: Configure Firebase App Check

### Why This Matters
- App Check protects your Firebase resources from abuse
- Without it, API calls will be rejected
- Debug tokens let you test without real attestation

### Add Debug Token

1. **Go to Firebase Console**:
   - Open: https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck

2. **Click "Apps" tab**

3. **Find your iOS app** (`flutter_application_1 (iOS)`)
   - Click the three dots **"..."** → **"Manage debug tokens"**

4. **Add the debug token**:
   - Click **"Add debug token"**
   - Paste the token from your app logs
   - Click **"Add"**

5. **Verify**: Token should appear in the list

### Register Attestation Provider

1. **Still in Firebase App Check**, click on your iOS app

2. **Select provider**:
   - **For Development/Simulator**: Choose **DeviceCheck**
   - **For Production**: Choose **App Attest** (requires iOS 14+)

3. **Click "Save"**

### Set Enforcement Mode

1. **Click "APIs" tab** in Firebase App Check

2. **For each API** (Firebase Authentication, Cloud Firestore, etc.):
   - **Development**: Set to **"Unenforced"**
   - **Production**: Set to **"Enforced"**

3. **Recommendation**: Keep unenforced while testing, enforce before app store release

---

## Step 6: Test Everything Works

### Run the App Again

```bash
flutter run -d iPhone
```

### Verify These Features

1. **Firebase Initialization**
   - Check logs for: `"Firebase configured successfully"`
   - No errors about missing GoogleService-Info.plist

2. **App Check**
   - Check logs for: `"App Check token obtained successfully"`
   - Should see token refresh messages

3. **Authentication**
   - Try signing in with Google
   - Should work without errors

4. **Camera**
   - Grant camera permission when prompted
   - Take a photo - should work

5. **Firestore**
   - Try saving a recipe
   - Check Firebase Console → Firestore - data should appear

---

## 🧪 Running Tests

### Flutter Tests
```bash
flutter test
```

### iOS Unit Tests
```bash
./ios/scripts/test.sh
```

### Using Fastlane
```bash
cd ios
fastlane test          # Run all tests
fastlane build_debug   # Build debug version
fastlane ci            # Full CI workflow
cd ..
```

---

## 🔧 Troubleshooting

### ❌ "GoogleService-Info.plist not found" Error

**Symptom**: App crashes on launch with Firebase error

**Solution**: You didn't add the file via Xcode properly
1. In Xcode Project Navigator, look for `GoogleService-Info.plist`
2. If it's not there or in wrong folder, delete it
3. Re-add using Step 1 instructions above
4. Make sure "Add to targets: Runner" is checked

### ❌ "Module 'Firebase' not found" Error

**Symptom**: Build fails with import errors

**Solution**: CocoaPods didn't install correctly
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### ❌ "Signing requires a development team" Error

**Symptom**: Can't run on simulator or device

**Solution**: Follow Step 3 (Code Signing) again

### ❌ App Check Token Errors

**Symptom**: "App Check token validation failed"

**Solution**: 
1. Make sure you added debug token to Firebase Console
2. Check token matches exactly (no extra spaces)
3. Verify enforcement mode is "Unenforced" for development

### ❌ "Pod install" Takes Forever

**Symptom**: Stuck on "Analyzing dependencies"

**Solution**:
```bash
cd ios
pod repo update
rm -rf ~/Library/Caches/CocoaPods
pod install
cd ..
```

### ❌ Google Sign-In Not Working

**Symptom**: Sign-in button does nothing or shows error

**Solution**: Verify URL scheme was added correctly
```bash
# Check if URL scheme exists
grep -A 5 "CFBundleURLTypes" ios/Runner/Info.plist

# Should show:
# com.googleusercontent.apps.593064071345-d1tcm7otn1obrdmg7gd98e8pts678bpv
```

---

## 📊 Configuration Comparison (iOS vs Android)

Your iOS setup now matches Android exactly:

| Feature | Android | iOS | Status |
|---------|---------|-----|--------|
| Firebase Config | ✅ google-services.json | ✅ GoogleService-Info.plist | Complete |
| Dependency Management | ✅ Gradle | ✅ CocoaPods | Complete |
| Min Platform Version | ✅ API 21 (Android 5.0) | ✅ iOS 13.0 | Complete |
| Permissions | ✅ AndroidManifest.xml | ✅ Info.plist | Complete |
| Firebase Init | ✅ MainActivity.kt | ✅ AppDelegate.swift | Complete |
| App Check | ✅ Debug mode | ✅ Debug mode | Complete |
| Google Sign-In | ✅ Auto-configured | ✅ URL Scheme | Complete |
| Orientation | ✅ Portrait only | ✅ Portrait only | Complete |
| Unit Tests | ✅ widget_test.dart | ✅ RunnerTests.swift | Complete |
| Build Scripts | ✅ Gradle tasks | ✅ Fastlane + scripts | Complete |

---

## 📁 File Structure After Setup

```
ios/
├── Podfile                          ✅ CocoaPods configuration
├── Podfile.lock                     🆕 Generated by pod install
├── Pods/                            🆕 Firebase SDKs (28+ frameworks)
├── Runner.xcworkspace/              ✅ Open THIS in Xcode (not .xcodeproj)
├── Runner/
│   ├── AppDelegate.swift            ✅ Firebase initialization
│   ├── Info.plist                   ✅ Permissions & URL schemes
│   └── GoogleService-Info.plist     ✅ Firebase config (must add via Xcode)
├── RunnerTests/
│   └── RunnerTests.swift            ✅ Unit tests
├── scripts/
│   ├── setup.sh                     ✅ Automated setup
│   ├── build.sh                     ✅ Build automation
│   └── test.sh                      ✅ Test automation
└── fastlane/
    └── Fastfile                     ✅ CI/CD configuration
```

---

## 🎯 What Makes This Setup Complete

### Security
- ✅ App Check configured for API protection
- ✅ Debug tokens for development
- ✅ Ready to switch to production attestation

### Authentication  
- ✅ Firebase Auth initialized
- ✅ Google Sign-In URL scheme configured
- ✅ Matches Android authentication setup

### Database
- ✅ Firestore configured
- ✅ Security rules already deployed
- ✅ Same rules as Android

### AI Features
- ✅ Firebase AI (Gemini) configured
- ✅ Cloud-based (no local models needed)
- ✅ Same prompts and settings as Android

### Development Workflow
- ✅ Hot reload works
- ✅ Debug builds configured
- ✅ Tests ready to run
- ✅ CI/CD scripts available

---

## 🚀 Next Steps After Setup

### Immediate Testing
1. Run the app on simulator
2. Test camera and photo picker
3. Try Google Sign-In
4. Generate a recipe with AI
5. Save to Firestore

### Team Collaboration
1. Commit your changes (if Pods updated)
2. Share debug token with team (for their devices)
3. Document any signing certificate setup
4. Update team about iOS readiness

### Before Production
1. Switch App Check from DeviceCheck to App Attest
2. Set enforcement mode to "Enforced"
3. Remove debug tokens
4. Set up proper code signing with distribution certificate
5. Test on physical iOS devices

---

## 📚 Additional Resources

### Firebase Documentation
- [FlutterFire iOS Setup](https://firebase.google.com/docs/flutter/setup?platform=ios)
- [App Check iOS](https://firebase.google.com/docs/app-check/ios/devicecheck-provider)
- [Firebase Console](https://console.firebase.google.com/project/eternal-water-477911-m6)

### iOS Development
- [Xcode Documentation](https://developer.apple.com/xcode/)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [iOS Developer Library](https://developer.apple.com/documentation/)

### Project-Specific
- Quick Reference: `ios/README.md`
- Development Guide: `documentation/guides/DEVELOPMENT_GUIDE.md`
- Gemini API Setup: `documentation/guides/GEMINI_API_SETUP.md`

---

## ✅ Success Checklist

Use this checklist to verify everything is set up correctly:

### Setup Verification
- [ ] Xcode installed and up to date
- [ ] CocoaPods installed (`pod --version` works)
- [ ] Flutter configured (`flutter doctor` shows no critical errors)
- [ ] GoogleService-Info.plist added via Xcode (appears in Runner folder)
- [ ] `pod install` completed successfully (Pods/ directory created)
- [ ] Code signing configured (team selected in Xcode)

### App Testing
- [ ] App builds without errors
- [ ] Firebase initializes (no errors in logs)
- [ ] App Check token obtained (check logs)
- [ ] Camera permission works
- [ ] Photo picker works
- [ ] Google Sign-In works
- [ ] Can save data to Firestore
- [ ] AI recipe generation works

### Firebase Console
- [ ] iOS app registered in Firebase project
- [ ] App Check provider selected (DeviceCheck or App Attest)
- [ ] Debug token added (if using simulator)
- [ ] APIs set to appropriate enforcement mode

### Team Coordination
- [ ] Informed team iOS setup is complete
- [ ] Shared any configuration changes
- [ ] Documented any issues encountered
- [ ] Tested parity with Android version

## Prerequisites
- macOS with Xcode installed
- Firebase CLI installed: `npm install -g firebase-tools`
- Access to Firebase Console for project `eternal-water-477911-m6`
- CocoaPods installed: `sudo gem install cocoapods`

## Step 1: Get GoogleService-Info.plist from Firebase Console

### Option A: Download from Firebase Console (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/project/eternal-water-477911-m6)
2. Click the gear icon ⚙️ next to "Project Overview" → **Project Settings**
3. Scroll to **Your apps** section
4. If iOS app exists:
   - Find the iOS app (bundle ID: `com.example.flutterApplication1` or similar)
   - Click the iOS app → Download `GoogleService-Info.plist`
5. If iOS app does NOT exist:
   - Click **Add app** → Choose **iOS**
   - Bundle ID: `com.example.flutterApplication1`
   - App nickname: `flutter_application_1 (iOS)`
   - App Store ID: (leave blank)
   - Click **Register app**
   - Download `GoogleService-Info.plist`
   - Click **Continue** → **Continue to console**

### Option B: Use Firebase CLI
```bash
# Login to Firebase
firebase login

# Set active project
firebase use eternal-water-477911-m6

# List iOS apps
firebase apps:list IOS

# If iOS app exists, get app ID and download config
# Replace APP_ID with actual app ID from list command
firebase apps:sdkconfig IOS APP_ID -o ios/Runner/GoogleService-Info.plist

# If no iOS app exists, create one first:
firebase apps:create IOS com.example.flutterApplication1 --display-name="flutter_application_1 (iOS)"
# Then download config with the new app ID
```

## Step 2: Add GoogleService-Info.plist to Xcode Project

### Copy File to Project
```bash
# From project root
cp /path/to/downloaded/GoogleService-Info.plist ios/Runner/
```

### Add to Xcode (REQUIRED - File must be added via Xcode, not just copied!)
1. Open `ios/Runner.xcworkspace` in Xcode (NOT `Runner.xcodeproj`!)
2. Right-click on **Runner** folder in Project Navigator
3. Select **Add Files to "Runner"...**
4. Navigate to `ios/Runner/` and select `GoogleService-Info.plist`
5. **IMPORTANT**: Check these options:
   - ✅ **Copy items if needed**
   - ✅ **Create groups** (NOT "Create folder references")
   - ✅ **Add to targets: Runner**
6. Click **Add**
7. Verify file appears in **Runner** folder (not in Flutter folder!)

## Step 3: Install CocoaPods Dependencies

```bash
# Navigate to iOS directory
cd ios

# Install pods (this will download Firebase SDKs)
pod install

# If you get errors, try:
pod repo update
pod install --repo-update

# Return to project root
cd ..
```

**Expected output:**
```
Analyzing dependencies
Downloading dependencies
Installing Firebase (10.x.x)
Installing FirebaseAuth (10.x.x)
Installing FirebaseCore (10.x.x)
Installing FirebaseFirestore (10.x.x)
Installing FirebaseAI (3.x.x)
Installing FirebaseAppCheck (10.x.x)
...
Pod installation complete! XX pods installed
```

## Step 4: Verify Configuration

### Check Files Exist
```bash
# From project root
ls ios/Runner/GoogleService-Info.plist
ls ios/Podfile
ls ios/Podfile.lock
ls ios/Runner.xcworkspace
```

### Verify GoogleService-Info.plist Content
```bash
# Check if file contains your Firebase project ID
cat ios/Runner/GoogleService-Info.plist | grep eternal-water-477911-m6
```

Should show lines containing `eternal-water-477911-m6`.

### Check Info.plist Permissions
```bash
cat ios/Runner/Info.plist | grep -A 1 NSCameraUsageDescription
```

Should show:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan your fridge and detect ingredients.</string>
```

## Step 5: Build and Run on iOS

### Clean Build
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
```

### Run on Simulator
```bash
# List available simulators
flutter devices

# Run on first available iOS device
flutter run -d iPhone
```

### Run on Physical Device (Requires Apple Developer Account)
```bash
# Connect iPhone via USB
# Trust computer on iPhone

# Run
flutter run -d "Your iPhone Name"
```

## Step 6: Configure App Check for iOS (REQUIRED)

Firebase App Check protects your backend resources from abuse. You must register your iOS app with an attestation provider.

### Option A: DeviceCheck (Development - Easiest)

**For local development and testing:**

1. Go to [Firebase Console App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
2. Click on your iOS app (`flutter_application_1 (iOS)`)
3. Select **DeviceCheck** provider
4. Click **Save**

**No additional code needed** - DeviceCheck works automatically in development.

### Option B: App Attest (Production - Recommended)

**For production releases:**

1. Go to [Firebase Console App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
2. Click on your iOS app
3. Select **App Attest** provider
4. Click **Save**

**Requirements:**
- iOS 14.0+ devices
- Physical device (doesn't work in simulator)
- App must be code-signed with valid provisioning profile

### Configure App Check in Code

The app is already configured in `lib/main.dart`:

```dart
// App Check is initialized automatically
await FirebaseAppCheck.instance.activate(
  appleProvider: AppleProvider.deviceCheck, // Development
  // appleProvider: AppleProvider.appAttest, // Production
);
```

### Debug Token (For Development/Testing)

If using a simulator or need to bypass App Check:

1. Run the app once on simulator/device
2. Check terminal/console logs for debug token:
   ```
   [Firebase/AppCheck][I-FAA002001] Firebase App Check Debug Token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```
3. Copy the debug token
4. Go to [Firebase Console App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
5. Click **Apps** tab
6. Find your iOS app → Click **...** → **Manage debug tokens**
7. Click **Add debug token**
8. Paste your token → **Add**

**Important**: Debug tokens are for development only. Remove before production release.

### Verify App Check is Working

```bash
# Run app
flutter run -d iPhone

# Check logs for:
# ✅ "App Check token obtained successfully"
# ❌ "App Check token error" - means configuration issue
```

## Step 7: Configure Google Sign-In for iOS (If Using)

### Add URL Scheme to Info.plist
1. Open `GoogleService-Info.plist`
2. Find `REVERSED_CLIENT_ID` (e.g., `com.googleusercontent.apps.123456-abcdef`)
3. Open `ios/Runner/Info.plist` in Xcode
4. Add URL Scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
    </array>
  </dict>
</array>
```

Or use Firebase CLI:
```bash
# Get REVERSED_CLIENT_ID
grep REVERSED_CLIENT_ID ios/Runner/GoogleService-Info.plist

# Manually add to Info.plist using text editor or Xcode
```

## Troubleshooting

### ❌ "GoogleService-Info.plist not found"
**Solution**: Make sure you added the file via Xcode, not just copied it.
1. Delete `ios/Runner/GoogleService-Info.plist` if it exists
2. Follow Step 2 again, adding via Xcode

### ❌ "CocoaPods could not find compatible versions"
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
cd ..
```

### ❌ "Firebase not initialized" on iOS
**Solution**: Verify `AppDelegate.swift` has:
```swift
import FirebaseCore

FirebaseApp.configure()
```

### ❌ "Module 'Firebase' not found"
**Solution**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

### ❌ "Signing requires a development team"
**Solution**: 
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project in Project Navigator
3. Select **Runner** target → **Signing & Capabilities** tab
4. Select your **Team** from dropdown
5. Xcode will automatically provision

### ❌ "Undefined symbols for architecture arm64"
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## Comparison with Android

| Configuration | Android | iOS |
|---------------|---------|-----|
| Config File | `android/app/google-services.json` | `ios/Runner/GoogleService-Info.plist` |
| Dependency Management | Gradle (build.gradle.kts) | CocoaPods (Podfile) |
| Initialization | MainActivity.kt (automatic) | AppDelegate.swift |
| Min Version | Android 5.0 (API 21) | iOS 13.0 |
| Permissions | AndroidManifest.xml | Info.plist |
| Build Tool | Gradle | Xcode + CocoaPods |

## Step 8: Enforcement Mode (Production)

Once App Check is set up and tested:

1. Go to [Firebase Console App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
2. Click **APIs** tab
3. For each API (Firebase Auth, Firestore, etc.):
   - During development: Keep **Unenforced** (allows requests without valid tokens)
   - For production: Switch to **Enforced** (blocks requests without valid tokens)

**Recommendation**: Keep unenforced during development, enforce before production release.

## Files Modified/Created

### Created:
- ✅ `ios/Podfile` - CocoaPods configuration
- ✅ `ios/README.md` - Quick setup reference
- ✅ `documentation/guides/IOS_FIREBASE_SETUP.md` - This guide
- ⬜ `ios/Runner/GoogleService-Info.plist` - Firebase iOS config (you must download)

### Modified:
- ✅ `ios/Runner/Info.plist` - Added permissions and minimum OS version
- ✅ `ios/Runner/AppDelegate.swift` - Added Firebase initialization

## Next Steps

After successful setup:
1. Test camera functionality
2. Test Firebase Authentication (Google Sign-In)
3. Test Firestore operations
4. Test AI recipe generation
5. Compare behavior with Android version

## Resources

- [FlutterFire iOS Setup](https://firebase.google.com/docs/flutter/setup?platform=ios)
- [Firebase Console](https://console.firebase.google.com/project/eternal-water-477911-m6)
- [CocoaPods Guides](https://guides.cocoapods.org/)
- [Xcode Documentation](https://developer.apple.com/xcode/)

---

**Last Updated**: November 12, 2025
**Status**: Ready for iOS Firebase configuration
