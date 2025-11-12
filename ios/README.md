# iOS Setup - Required Firebase Configuration

⚠️ **IMPORTANT**: The iOS app requires `GoogleService-Info.plist` to function properly.

## ✅ Completed

All configuration files have been created and are ready:

- ✅ **Podfile** - CocoaPods dependencies configured
- ✅ **GoogleService-Info.plist** - Firebase iOS config downloaded and copied
- ✅ **Info.plist** - All permissions and settings configured
- ✅ **AppDelegate.swift** - Firebase initialization added
- ✅ **App Check** - Enabled in main.dart (debug mode)
- ✅ **Google Sign-In** - URL scheme configured
- ✅ **RunnerTests** - Basic tests added
- ✅ **Build Scripts** - Setup, build, and test scripts created
- ✅ **Fastlane** - CI/CD configuration ready

## ⏳ Requires macOS

The following steps can ONLY be completed on macOS:

### Quick Setup on macOS
### Quick Setup on macOS

**Option 1: Automated Setup Script**
```bash
chmod +x ios/scripts/setup.sh
./ios/scripts/setup.sh
```

**Option 2: Manual Setup**

#### 1. Install CocoaPods (if not already installed)
```bash
sudo gem install cocoapods
```

#### 2. Add GoogleService-Info.plist to Xcode (CRITICAL!)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click **Runner** folder → **Add Files to "Runner"...**
3. Select `ios/Runner/GoogleService-Info.plist`
4. ✅ Check: **Copy items if needed**
5. ✅ Check: **Add to targets: Runner**
6. Click **Add**

#### 3. Install Dependencies
```bash
cd ios
pod install
cd ..
```

#### 4. Configure Signing
1. In Xcode, select **Runner** project
2. Select **Runner** target → **Signing & Capabilities**
3. Select your **Team** from dropdown

#### 5. Run the App
```bash
flutter run -d iPhone
```

## Firebase App Check Setup

After first run, you'll need to configure App Check:

### 1. Get Debug Token
Run the app once and check console for:
```
Firebase App Check Debug Token: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

### 2. Add Token to Firebase Console
1. Go to [Firebase Console App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
2. Click **Apps** tab
3. Find iOS app → **Manage debug tokens**
4. Click **Add debug token** → Paste token → **Add**

### 3. Register Attestation Provider
1. In Firebase Console App Check → Select iOS app
2. Choose provider:
   - **DeviceCheck** (for development)
   - **App Attest** (for production, iOS 14+)
3. Click **Save**

### 4. Set Enforcement Mode
1. Click **APIs** tab
2. For development: Keep **Unenforced**
3. For production: Switch to **Enforced**

## Available Scripts

### Setup Script
```bash
./ios/scripts/setup.sh
```
Automates entire iOS setup process on macOS.

### Build Script
```bash
./ios/scripts/build.sh
```
Builds iOS app with all dependencies.

### Test Script
```bash
./ios/scripts/test.sh
```
Runs Flutter and iOS unit tests.

### Fastlane
```bash
cd ios
fastlane test          # Run tests
fastlane build_debug   # Build debug
fastlane build_release # Build release
fastlane ci            # Full CI workflow
```

## Configuration Files Created

### iOS-Specific
- `Podfile` - CocoaPods configuration
- `GoogleService-Info.plist` - Firebase iOS config
- `RunnerTests/RunnerTests.swift` - Unit tests
- `Flutter/AppConfig.xcconfig` - Build configuration
- `.xcode.env` - Xcode environment variables
- `fastlane/Fastfile` - CI/CD automation
- `scripts/setup.sh` - Automated setup
- `scripts/build.sh` - Build automation
- `scripts/test.sh` - Test automation

### Updated
- `Info.plist` - Permissions and URL schemes
- `AppDelegate.swift` - Firebase initialization

### Cross-Platform
- `lib/main.dart` - App Check enabled

## Build Configuration

| Setting | Value |
|---------|-------|
| Minimum iOS Version | 13.0 |
| Swift Version | 5.0 |
| Bitcode | Disabled |
| Bundle ID | com.example.flutterApplication1 |
| Orientation | Portrait only |
| Firebase Project | eternal-water-477911-m6 |

## Platform Parity with Android

| Feature | Android | iOS | Status |
|---------|---------|-----|--------|
| Firebase Config | ✅ | ✅ | Complete |
| Dependencies | ✅ | ✅ | Complete |
| Permissions | ✅ | ✅ | Complete |
| Firebase Init | ✅ | ✅ | Complete |
| App Check | ✅ | ✅ | Complete |
| Google Sign-In | ✅ | ✅ | Complete |
| Unit Tests | ✅ | ✅ | Complete |
| Build Scripts | ✅ | ✅ | Complete |
| CI/CD | ✅ | ✅ | Complete |
| Orientation | ✅ | ✅ | Complete |

## Troubleshooting

**"GoogleService-Info.plist not found"**
→ Follow Step 2 above to add file via Xcode

**"Module 'Firebase' not found"**
→ Run `cd ios && pod install && cd ..`

**"CocoaPods errors"**
→ Run `cd ios && pod repo update && pod install && cd ..`

---

For more help, see [IOS_FIREBASE_SETUP.md](../../documentation/guides/IOS_FIREBASE_SETUP.md)
