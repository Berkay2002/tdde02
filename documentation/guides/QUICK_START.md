# Quick Start Guide - Get the App Running

**New to Flutter/Firebase? Start here!** This guide will get you from zero to running the app.

⚠️ **Reality Check**: First-time setup is complex and takes significant time. You need to install multiple tools, configure Firebase, and troubleshoot issues. Budget several hours for your first setup. Don't try to rush it.

---

## Prerequisites - What You Need to Install

### 1. Install Required Software

You **must** install all of these (no shortcuts):

**A. Flutter SDK**

**Method 1: Using VS Code (Easiest)**
1. Install [VS Code](https://code.visualstudio.com/) if you don't have it
2. Open VS Code
3. Press `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (Mac) to open Extensions
4. Search for "Flutter" and install the official Flutter extension
5. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac) to open Command Palette
6. Type "Flutter: New Project" and select it
7. VS Code will prompt you to download Flutter SDK - click "Download SDK"
8. Choose a location (e.g., `C:\src\flutter` on Windows, `~/development/flutter` on Mac)
9. Wait for the download and installation to complete
10. Restart VS Code

**Method 2: Manual Installation**
- Download: [flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- **Windows**: Extract to `C:\src\flutter`, add `C:\src\flutter\bin` to PATH, restart terminal
- **Mac**: Extract, add to PATH in `~/.zshrc` or `~/.bash_profile`, restart terminal

After installation (either method), verify:
```bash
flutter --version
```

**B. Android SDK & Android Studio**

**Option 1: Install via Android Studio (Recommended for Beginners)**
1. Download [Android Studio](https://developer.android.com/studio)
2. Run the installer
3. During installation, ensure these are checked:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Android Virtual Device
4. Complete installation
5. Launch Android Studio
6. Follow the setup wizard to download SDK components

**Option 2: Install Android SDK via Command Line (Advanced)**

This is useful if you don't want the full Android Studio IDE.

**Windows (PowerShell):**
```powershell
# Create directory for Android SDK
New-Item -Path "C:\Android\sdk" -ItemType Directory -Force

# Download Android command line tools
# Go to https://developer.android.com/studio#command-line-tools-only
# Download the "Command line tools only" for Windows
# Extract the zip to C:\Android\sdk\cmdline-tools\latest\

# Add to PATH (run as Administrator)
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android\sdk", "User")
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools", "User")

# Restart PowerShell, then install SDK components
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

**Mac/Linux (Terminal):**
```bash
# Create directory for Android SDK
mkdir -p ~/Android/sdk

# Download Android command line tools
# Go to https://developer.android.com/studio#command-line-tools-only
# Download the "Command line tools only" for your platform
# Extract to ~/Android/sdk/cmdline-tools/latest/

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export ANDROID_HOME=$HOME/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Reload shell config
source ~/.zshrc  # or source ~/.bash_profile

# Install SDK components
sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
```

**After Android SDK Installation (Either Method):**

Accept all Android SDK licenses (REQUIRED):
```bash
# This will prompt you to accept multiple licenses
flutter doctor --android-licenses

# You'll see prompts like this - type 'y' for each:
# Accept? (y/N): y
# Accept? (y/N): y
# ...continue typing 'y' until done
```

If `flutter doctor --android-licenses` doesn't work, use sdkmanager directly:
```bash
# Windows:
%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager --licenses

# Mac/Linux:
$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses
```

**C. Platform-Specific Tools**
- **Windows**: 
  - Visual Studio 2022 (Community Edition) with "Desktop development with C++" workload
  - Python 3.9
- **Mac**: 
  - Xcode (from App Store, very large download)
  - Command Line Tools: `xcode-select --install`
  - CocoaPods: `sudo gem install cocoapods`

**D. Firebase CLI** (REQUIRED for SHA certificate management)
```bash
# Install Node.js first (from nodejs.org) if you don't have it

# Then install Firebase CLI
npm install -g firebase-tools

# Verify installation
firebase --version
```

**E. Dart SDK** (Usually included with Flutter, but verify)
- Check: `dart --version`

### 2. Verify Installation
Open terminal (PowerShell on Windows, Terminal on Mac):
```bash
flutter doctor
```

**You should see:**
- ✅ Flutter (green checkmark)
- ✅ Android toolchain - develop for Android devices
- ⚠️ Some warnings are okay (Chrome, VS Code - not critical)

**Common issues and fixes:**

**If you see "Android licenses not accepted":**
```bash
flutter doctor --android-licenses
# Type 'y' for each license prompt
```

**If you see "cmdline-tools component is missing":**
- Open Android Studio → Settings/Preferences → Appearance & Behavior → System Settings → Android SDK
- Click "SDK Tools" tab
- Check "Android SDK Command-line Tools (latest)"
- Click "Apply" and wait for download

**Mac: If you see Xcode issues:**
```bash
xcode-select --install
```

**Expected `flutter doctor` output after fixes:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices (Android SDK version X.X.X)
    • All Android licenses accepted
[✓] Chrome - develop for the web
[✓] Android Studio (version X.X)
[✓] VS Code (version X.X.X)
[✓] Connected device (if emulator/phone is running)
```

### 3. Create Android Virtual Device (Optional - Can Do Later)

You can create an emulator now or skip and use your physical phone.

**Option A: Use Android Emulator**

1. Open **Android Studio**
2. Go to **More Actions** → **Virtual Device Manager** (or **Device Manager** in toolbar)
3. Click **Create Device**
4. Choose **Pixel 5** or **Pixel 6** → **Next**
5. Download a system image:
   - Recommended: **Android 13 (API 33)** or **Android 14 (API 34)**
   - Click **Download** next to the system image (large download)
6. Click **Next** → **Finish**
7. Click ▶️ to launch the emulator (takes time on first launch)

**Option B: Use Your Physical Phone**
- Enable Developer Options (tap Build Number 7 times in Settings → About Phone)
- Enable USB Debugging (Settings → Developer Options)
- Connect via USB
- Allow debugging prompt on phone

---

## Set Up Firebase CLI

### 1. Login to Firebase
```bash
firebase login
```
- Browser will open
- Sign in with your Google account
- Grant permissions

### 2. Verify Login
```bash
firebase projects:list
```
You should see `eternal-water-477911-m6` in the list.

### 3. Set Active Project
```bash
firebase use eternal-water-477911-m6
```

---

## Clone the Project

### Clone the Repository
```bash
# Navigate to where you want the project
cd ~/Projects  # Mac
cd C:\Users\YourName\Projects  # Windows

# Clone the repository
git clone https://github.com/Berkay2002/tdde02.git
cd tdde02
```

### Install Dependencies
```bash
# Downloads all required packages
flutter pub get
```

This downloads 50+ packages including Firebase, camera, AI, and other dependencies.

---

## Configure Google Sign-In (CRITICAL STEP)

⚠️ **Most common failure point.** Google Sign-In won't work without SHA certificates. Each developer must do this once.

### Step 1: Generate Your SHA Certificates
```bash
# Navigate to android folder
cd android

# Windows PowerShell:
.\gradlew signingReport

# Mac/Linux:
./gradlew signingReport
```

**Look for this section in the output:**
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
SHA1: 11:9D:A7:93:09:22:E1:01:09:41:10:15:44:4D:A9:DC:4F:DA:66:BB
SHA-256: 7C:B7:E8:20:A7:4F:24:6B:01:D4:94:9E:A8:EF:FD:14:FF:86:3E:00:03:8B:70:64:48:F7:8F:B6:B6:E8:C7:3F
```

**Copy both values** - you'll need them in the next step:
- **SHA1**: The string after `SHA1:`
- **SHA-256**: The string after `SHA-256:`

### Step 2: Register Your SHA Certificates in Firebase

**Using Firebase CLI (Recommended)**
```bash
# Return to project root
cd ..

# Ensure you're logged in
firebase login

# Set the correct project
firebase use eternal-water-477911-m6

# Add your SHA-1 (replace YOUR_SHA1_HERE with your actual SHA-1)
firebase apps:android:sha:create 1:593064071345:android:65206fcaee9311bbb71290 YOUR_SHA1_HERE

# Add your SHA-256 (replace YOUR_SHA256_HERE with your actual SHA-256)
firebase apps:android:sha:create 1:593064071345:android:65206fcaee9311bbb71290 YOUR_SHA256_HERE

# Download updated google-services.json
firebase apps:sdkconfig ANDROID 1:593064071345:android:65206fcaee9311bbb71290 -o android/app/google-services.json
```

**Alternative: Using Firebase Console**
1. Go to [Firebase Console](https://console.firebase.google.com/project/eternal-water-477911-m6)
2. Click ⚙️ **Project Settings** → **General** tab
3. Scroll to **Your apps** → Find the Android app
4. Click **Add fingerprint** (SHA certificate fingerprints section)
5. Paste your **SHA-1** → **Save**
6. Click **Add fingerprint** again → Paste your **SHA-256** → **Save**
7. Download `google-services.json` and replace `android/app/google-services.json`

### Step 3: Configure App Check (After First Run)

You'll do this **after running the app once**.

1. Run the app (it will fail, but that's expected - we need the debug token from logs)
2. Look in terminal output for:
   ```
   Enter this debug secret into the allow list: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   ```
3. Copy that token
4. Open [Firebase App Check](https://console.firebase.google.com/project/eternal-water-477911-m6/appcheck)
5. Go to **Apps** tab → Find your app → Click **Manage debug tokens**
6. Paste the token → **Save**
7. Go to **APIs** tab → Find **Firebase Authentication** → Set enforcement to **Unenforced**
8. Run the app again

**Why this matters:**
- **SHA certificates**: Required for Google Sign-In
- **App Check token**: Prevents unauthorized API access
- **Each developer** needs their own SHA (tied to your keystore)
- **One-time setup** per developer

---

## Build and Run

### 1. Clean Build
```bash
flutter clean
flutter pub get
```

### 2. Check Your Device is Connected
```bash
flutter devices
```

**You should see:**
- Emulator name (e.g., `sdk gphone64 x86 64`), OR
- Your phone name (if USB connected)

**If no devices:**
- Launch Android emulator from Android Studio
- Wait for it to fully boot
- Run `flutter devices` again

### 3. Run the App
```bash
flutter run
```

**What happens:**
- **First build**: Takes a long time (downloads Gradle dependencies, compiles)
- **Subsequent builds**: Much faster
- App installs on device/emulator
- App opens automatically

**Common first-time build warnings (SAFE TO IGNORE):**
```
Note: Some input files use or override a deprecated API.
warning: [options] source value 8 is obsolete
W/LocalRequestInterceptor: Error getting App Check token; using placeholder token instead.
```

These are expected and won't affect functionality.

### 4. First Run - Get App Check Token

On the first run, the app will fail with an App Check error. This is expected!

1. Look in the terminal for the debug token (see Step 3 above under "Configure App Check")
2. Add it to Firebase Console
3. Run `flutter run` again

### 5. Sign In and Test

1. Click **Continue with Google** or **Sign Up** with email
2. Grant camera permissions when prompted
3. Take a photo of ingredients or select from gallery
4. Wait for AI to detect ingredients
5. Generate a recipe!

---

## That's It! 🎉

**Your app should now be running!** 

### Important Notes for Team Members

### Understanding the Setup

**Why Each Developer Needs Their Own SHA Certificates:**
- SHA certificates are tied to your computer's debug keystore
- Located at `~/.android/debug.keystore` (Mac) or `C:\Users\YourName\.android\debug.keystore` (Windows)
- Your teammate's SHA won't work for you - everyone must add their own
- One-time setup per developer (unless you change computers)

**Why You Need an App Check Debug Token:**
- Each emulator/device generates a unique token
- Required to bypass App Check during development
- Different from production where you'd use Play Integrity

**How the AI Works:**
- Runs in the cloud via Google's Gemini API through Firebase
- No model downloads needed
- Always up-to-date
- Requires internet connection

---

## What Next?

### Understanding the Code
- **Want to modify UI?** → See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#project-structure)
- **Want to understand AI prompts?** → See [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)
- **Want to add features?** → See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#where-to-add-new-features)

### Common Issues

**"Google sign in failed" - PlatformException: sign_in_failed**
- **Cause**: Missing SHA certificates (99% of cases)
- **Fix**: 
  1. Run `cd android && ./gradlew signingReport`
  2. Copy SHA-1 and SHA-256
  3. Add to Firebase Console (see Step 2 above)
  4. Download updated `google-services.json`
  5. Run `flutter clean && flutter run`

**"Firebase App Check token is invalid"**
- **Cause**: Missing debug token
- **Fix**: 
  1. Check terminal logs for debug token
  2. Add to Firebase Console → App Check → Manage debug tokens
  3. Set enforcement to "Unenforced"
  4. Run again

**First build is extremely slow**
- **Cause**: Normal - downloading Gradle dependencies
- **Fix**: Be patient, subsequent builds are much faster
- If stuck for too long: `flutter clean && flutter run`

**Build errors after `git pull`**
- **Fix**: 
```bash
flutter clean
flutter pub get
flutter run
```

**AI detection not working**
- Check internet connection
- Try again (API has quota limits)
- Ensure photo is clear and well-lit

**Hot reload tips:**
- Save file → App auto-reloads
- Press `r` in terminal for manual reload
- Press `R` for full restart
- Press `q` to quit

---

## Daily Development Workflow

**Getting latest code:**
```bash
git pull origin dev
flutter pub get
flutter run
```

**Making changes:**
1. Edit files in VS Code or Android Studio
2. Save → App hot reloads automatically
3. Press `r` for manual reload, `R` for restart

**Committing changes:**
```bash
git add .
git commit -m "feat: describe what you changed"
git push origin dev/your-name
```

**First time setup:**
```bash
git checkout -b dev/your-name
git push -u origin dev/your-name
```

See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#git-branching-strategy) for complete workflow.

---

## Advanced Troubleshooting

### ❌ "flutter: command not found"
- Add Flutter to PATH:
  - **Windows**: Add `C:\src\flutter\bin` to System Environment Variables
  - **Mac**: Add `export PATH="$PATH:/path/to/flutter/bin"` to `~/.zshrc` or `~/.bash_profile`
- **IMPORTANT**: Restart terminal (or reboot) after adding to PATH
- Verify: `flutter --version`

### "No devices found"
```bash
# Check available devices
flutter devices

# If none, launch Android emulator from Android Studio or connect phone
```

### "Gradle build failed"
```bash
flutter clean
cd android
./gradlew clean  # Mac/Linux
.\gradlew clean  # Windows
cd ..
flutter pub get
flutter run
```

### "CocoaPods error" (iOS/Mac only)
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### "Module not found" / "Package not found"
```bash
flutter pub get
flutter clean
flutter run
```

### Nuclear option (when all else fails)
```bash
flutter clean
flutter pub get
cd android
./gradlew clean  # or .\gradlew clean on Windows
cd ..
flutter run
```

**Still stuck?**
- See detailed troubleshooting: [FIREBASE_TROUBLESHOOTING.md](FIREBASE_TROUBLESHOOTING.md)
- Check [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#common-issues--troubleshooting)
- Flutter docs: [docs.flutter.dev](https://docs.flutter.dev)

---

## Need More Help?

| Topic | Guide |
|-------|-------|
| Full setup guide with all details | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) |
| Understanding Gemini AI setup | [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md) |
| Project structure & architecture | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#project-structure) |
| Git workflow & branching | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#git-branching-strategy) |
| Firebase/Firestore setup | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#firebase-configuration) |
| Testing on different platforms | [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#testing-on-different-platforms) |

---

**Remember**: First build is slow, but Flutter's **hot reload** makes development super fast after that! Just save your file and see changes instantly (no rebuild needed). 🚀
