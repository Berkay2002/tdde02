# Quick Start Guide - Get the App Running in 10 Minutes

**New to Flutter/Firebase? Start here!** This guide will get you from zero to running the app with minimal setup.

---

## What You Need (5 minutes)

### 1. Install Flutter
- **Download**: [flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- **Windows**: Download ZIP, extract to `C:\src\flutter`, add to PATH
- **Mac**: Download ZIP, extract, add to PATH, install Xcode from App Store

### 2. Verify Installation
Open terminal (PowerShell on Windows, Terminal on Mac):
```bash
flutter doctor
```

**You should see:**
- ✅ Flutter (green checkmark)
- ✅ Android toolchain (or Xcode for Mac)
- ⚠️ Some warnings are okay (Chrome, VS Code - not critical)

**Fix common issues:**
```bash
# Android: Accept licenses
flutter doctor --android-licenses

# Mac: Install Xcode Command Line Tools
xcode-select --install
```

### 3. Get an Android Device/Emulator Ready

**Option A: Use Your Phone (Recommended for Beginners)**
1. Enable **Developer Options** on your Android phone:
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times (yes, really!)
2. Enable **USB Debugging**:
   - **Settings** → **Developer Options** → Turn on **USB Debugging**
3. Connect phone to computer with USB cable
4. Allow debugging on your phone when prompted

**Option B: Use Android Emulator**
1. Open **Android Studio** (download if you don't have it)
2. Go to **Device Manager** (right sidebar)
3. Click **Create Device** → Choose **Pixel 9** → Download system image → Finish
4. Click ▶️ to launch emulator

---

## Get the Code (2 minutes)

### 1. Clone the Repository
```bash
# Navigate to where you want the project
cd ~/Projects  # Mac
cd C:\Users\YourName\Projects  # Windows

# Clone the repository
git clone https://github.com/Berkay2002/tdde02.git
cd tdde02
```

### 2. Install Dependencies
```bash
# This downloads all packages (might take 2-3 minutes)
flutter pub get
```

**What this does**: Downloads Firebase, camera, AI packages, and other dependencies.

---

## Run the App (3 minutes)

### 1. Check Your Device is Connected
```bash
flutter devices
```

**You should see:**
- Your phone name (if USB connected), OR
- Emulator name (if emulator is running)

### 2. Run the App
```bash
flutter run
```

**What happens:**
- App builds (first time takes 2-5 minutes ☕)
- App installs on your device
- App opens automatically!

### 3. Test the App
1. **Sign up** with a test email or Google account
2. **Allow camera permissions** when prompted
3. **Take a photo** of food items (or select from gallery)
4. **Wait 2-5 seconds** for AI to detect ingredients
5. **Generate a recipe**!

---

## That's It! 🎉

**Your app is now running!** The AI is working in the cloud (Google's Gemini API via Firebase), so:
- ✅ No model downloads needed
- ✅ Always up-to-date AI

---

## What Next?

### Understanding the Code
- **Want to modify UI?** → See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#project-structure)
- **Want to understand AI prompts?** → See [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)
- **Want to add features?** → See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#where-to-add-new-features)

### Common Questions

**Q: The app is slow to start**
- First build takes 2-5 minutes (normal!)
- Subsequent builds are much faster (10-30 seconds)

**Q: "Camera permission denied"**
- Close app
- Go to phone Settings → Apps → (App Name) → Permissions → Enable Camera

**Q: "Firebase error" or "Permission denied"**
- Make sure you're logged in (sign up first!)
- Firebase is already configured - just run the app

**Q: AI detection not working**
- Check internet connection (AI runs in the cloud)
- Try again (free API has quota limits)
- Make sure photo is clear and well-lit

**Q: Build errors after `git pull`**
```bash
flutter clean
flutter pub get
flutter run
```

**Q: How do I make changes to the code?**
- Open project in **VS Code** or **Android Studio**
- Edit files in `lib/` folder
- Save file → App auto-reloads (hot reload)!
- Press `r` in terminal to manually reload
- Press `R` for full restart

### Git Workflow (for team members)

**Daily workflow:**
```bash
# 1. Get latest code
git pull origin dev

# 2. Work on your changes
# ... edit files in VS Code/Android Studio ...

# 3. Test your changes
flutter run
# Press 'r' for hot reload after saving files

# 4. Save your work
git add .
git commit -m "feat: Describe what you changed"
git push origin dev-your-name
```

**First time setup:**
```bash
# Create your personal dev branch
git checkout -b dev/your-name
git push -u origin dev/your-name
```

See [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#git-branching-strategy) for more details.

---

## Troubleshooting

### ❌ "flutter: command not found"
- Add Flutter to PATH (see Flutter installation docs)
- Restart terminal after adding to PATH

### ❌ "No devices found"
- **Android phone**: Enable USB debugging, reconnect
- **Emulator**: Launch emulator first, then run `flutter run`

### ❌ "Gradle build failed" (Android)
```bash
flutter clean
cd android
./gradlew clean  # Mac
gradlew.bat clean  # Windows
cd ..
flutter run
```

### ❌ "CocoaPods error" (iOS/Mac)
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### ❌ "Module not found" errors
```bash
flutter pub get
flutter clean
flutter run
```

### Still stuck?
- Check the detailed [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md#common-issues--troubleshooting)
- Ask the team on Slack/Discord
- Check Flutter docs: [docs.flutter.dev](https://docs.flutter.dev)

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
