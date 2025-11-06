# Development Guide - AI Recipe Generator
**Team Guide for Setup, Development, and Troubleshooting**

> 📱 Flutter + Supabase + On-Device AI (Gemma 3n)  
> Target Platforms: iOS & Android

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [First-Time Setup](#first-time-setup)
3. [Running the App](#running-the-app)
4. [Supabase Configuration](#supabase-configuration)
5. [Project Structure](#project-structure)
6. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
7. [Development Workflow](#development-workflow)
8. [Testing on Different Platforms](#testing-on-different-platforms)
9. [Working with AI Model](#working-with-ai-model)
10. [Git Handling](#git-handling)

---

## Prerequisites

### Required Software

#### All Platforms
- **Flutter SDK**: 3.24 or higher ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Git**: For version control
- **VS Code** or **Android Studio**: Recommended IDEs
  - VS Code Extensions: Flutter, Dart, Riverpod Snippets
  - Android Studio: Flutter plugin

#### Windows Developers
- **Android Studio**: For Android development
- **PowerShell**: Already installed (you're good!)
- **Visual Studio** (optional): For Windows desktop development

#### Mac Developers
- **Xcode** (latest version): For iOS development
  - Command Line Tools: `xcode-select --install`
- **Android Studio**: For Android development
- **CocoaPods**: `sudo gem install cocoapods`

### Accounts Needed
- ✅ **GitHub Account**: Access to repository (already have this)
- ✅ **Supabase Account**: Access to team project (already have this)

---

## First-Time Setup

### 1. Clone the Repository
```bash
# Navigate to your projects folder
cd ~/Projects  # Mac
cd C:\Users\YourName\Projects  # Windows

# Clone the repository
git clone https://github.com/Berkay2002/tdde02.git
cd tdde02
```

### 2. Verify Flutter Installation
```bash
# Check Flutter is properly installed
flutter doctor

# Expected output:
# [✓] Flutter (Channel stable, 3.24.x)
# [✓] Android toolchain
# [✓] Xcode (Mac only)
# [✓] VS Code / Android Studio
# [!] Some warnings are okay (e.g., Chrome not needed for mobile)
```

**Fix Common `flutter doctor` Issues:**
- ❌ Android licenses not accepted: `flutter doctor --android-licenses` (accept all)
- ❌ Xcode not found (Mac): Install from App Store, then run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- ❌ CocoaPods not installed (Mac): `sudo gem install cocoapods`

### 3. Install Project Dependencies
```bash
# This downloads all packages from pubspec.yaml
flutter pub get

# If you see errors, try cleaning first:
flutter clean
flutter pub get
```

**What This Does:**
- Downloads packages: `supabase_flutter`, `camera`, `tflite_flutter`, `riverpod`, etc.
- Creates `.dart_tool` folder with package metadata

### 4. Configure Environment Variables

**Create `.env` file** (copy from `.env.example`):
```bash
# Windows PowerShell
Copy-Item .env.example .env

# Mac/Linux
cp .env.example .env
```

**Edit `.env` file** with your Supabase credentials:
```dotenv
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Where to Find Supabase Credentials:**
1. Go to [supabase.com](https://supabase.com) → Your Project
2. Click **Settings** (gear icon) → **API**
3. Copy:
   - **Project URL** → `SUPABASE_URL`
   - **anon/public key** → `SUPABASE_ANON_KEY`

> ⚠️ **Important**: Never commit `.env` to Git! It's already in `.gitignore`.

### 5. Run Code Generation (for Riverpod)
```bash
# Generate provider code (needed for state management)
dart run build_runner build --delete-conflicting-outputs

# This creates *.g.dart files (already in .gitignore)
```

---

## Running the App

### Quick Start (Any Platform)
```bash
# 1. Check available devices
flutter devices

# 2. Run on connected device/emulator
flutter run

# 3. Hot reload while running (press 'r' in terminal)
# 4. Hot restart (press 'R' in terminal)
# 5. Quit (press 'q' in terminal)
```

### Running on Specific Platforms

#### 🤖 Android Emulator
```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run app on emulator
flutter run
```

**Create an Emulator (if none exist):**
1. Open **Android Studio** → **Device Manager**
2. Click **Create Device** → Choose **Pixel 5** or similar
3. Download system image (API 33+ recommended)
4. Finish setup and launch

#### 📱 Android Physical Device
1. **Enable Developer Options:**
   - Go to **Settings** → **About Phone**
   - Tap **Build Number** 7 times
2. **Enable USB Debugging:**
   - **Settings** → **Developer Options** → Enable **USB Debugging**
3. **Connect via USB:**
   ```bash
   # Check device is detected
   adb devices
   
   # Run app
   flutter run
   ```

#### 🍎 iOS Simulator (Mac Only)
```bash
# List simulators
xcrun simctl list devices

# Open default simulator
open -a Simulator

# Run app
flutter run
```

#### 📱 iOS Physical Device (Mac Only)
1. **Open Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
2. **Sign the App:**
   - Select **Runner** project → **Signing & Capabilities**
   - Choose your **Team** (personal Apple ID is fine)
3. **Connect iPhone via USB:**
   - Trust computer on iPhone
4. **Run:**
   ```bash
   flutter run
   ```

#### 🌐 Chrome (Web Testing - Limited Features)
```bash
# Run in Chrome browser (camera might not work properly)
flutter run -d chrome
```

> ⚠️ **Note**: Camera and AI features require physical device or emulator, not web.

---

## Supabase Configuration

### Database Setup (First Time Only)

**The database schema has already been applied!** The migrations have been run and your database structure is ready to use.

**What Already Exists:**
- ✅ `profiles` table (user profile data: display name, avatar, bio, preferences)
- ✅ `user_preferences` table (cooking preferences: skill level, dietary restrictions, favorite cuisines, kitchen equipment)
- ✅ `recipes` table (AI-generated recipes with ingredients, instructions, ratings)
- ✅ Row Level Security (RLS) policies (users only see their own data)
- ✅ Automatic profile creation trigger (creates profile + preferences on signup)

**Database Tables Explained:**

1. **`profiles`** - Extended user information:
   - Basic info: email, display_name, avatar_url, bio
   - Settings: language_preference, theme_preference, notifications
   - Automatically created when user signs up

2. **`user_preferences`** - Cooking preferences:
   - skill_level: 'beginner', 'intermediate', 'advanced'
   - spice_tolerance: 'none', 'mild', 'medium', 'hot', 'very_hot'
   - cooking_time_preference: 'quick', 'moderate', 'long'
   - dietary_restrictions: array of strings (e.g., ["vegetarian", "gluten-free"])
   - excluded_ingredients: ingredients to avoid
   - favorite_cuisines, favorite_proteins, kitchen_equipment: arrays

3. **`recipes`** - AI-generated recipes:
   - Basic info: recipe_name, description, prep_time, cook_time, servings
   - Categorization: cuisine_type, difficulty_level, meal_type
   - Content: ingredients (JSONB), instructions (text array)
   - Metadata: detected_ingredients, dietary_tags, allergens
   - User features: is_favorite, rating (1-5), notes

### Verify Setup

**Check Database Tables:**
1. Go to **Supabase Dashboard** → Your Project → **Table Editor**
2. You should see tables: `profiles`, `user_preferences`, `recipes`
3. Click on each table to see the column structure

**Test Authentication:**
1. Run the app and sign up with a test email: `test@example.com`
2. Check **Supabase Dashboard** → **Authentication** → Users
3. Check **Table Editor** → `profiles` - you should see auto-created profile
4. Check **Table Editor** → `user_preferences` - you should see auto-created preferences

**Test Recipe Creation:**
1. Create a recipe in the app (when AI feature is implemented)
2. Check **Supabase Dashboard** → **Table Editor** → `recipes`
3. You should see your saved recipe with all fields

### Supabase Troubleshooting

**❌ Error: "Invalid API key"**
- Double-check `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Restart app after editing `.env`
- Make sure you copied the **anon/public key**, not the service_role key

**❌ Error: "Row Level Security Policy Violation"**
- Make sure you're logged in (authenticated) before trying to save/read data
- RLS policies require `auth.uid()` to match the user_id in the table
- Test: Check if you can see your user in **Supabase Dashboard** → **Authentication**

**❌ Error: "Table does not exist"**
- The migrations have already been applied, but if you see this:
- Go to **Supabase Dashboard** → **SQL Editor**
- Run: `SELECT * FROM profiles LIMIT 1;` to test
- If it fails, contact berkay (database may need re-initialization)

**❌ Error: "Column does not exist"**
- Make sure you pulled the latest code: `git pull origin main`
- Check if the column exists in **Supabase Dashboard** → **Table Editor**
- Column names in code must match snake_case in database (e.g., `display_name` not `displayName`)

**❌ Profile/Preferences Not Auto-Created on Signup**
- Check **Supabase Dashboard** → **Database** → **Functions**
- Look for `handle_new_user()` function
- Check **Database** → **Triggers** for `on_auth_user_created` trigger
- If missing, notify team lead to reapply migration

---

## Project Structure

### Overview
```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/
│   │   └── app_constants.dart  # App-wide settings
│   ├── theme/
│   │   └── app_theme.dart      # Colors, fonts
│   └── utils/                   # Helper functions
├── features/
│   ├── auth/                    # Login, signup screens
│   ├── camera/                  # Camera capture logic
│   ├── ingredient_detection/    # AI ingredient detection
│   ├── recipe_generation/       # AI recipe generation
│   └── recipe_history/          # Saved recipes, home screen
└── shared/
    ├── providers/               # Global Riverpod providers
    └── widgets/                 # Reusable UI components
```

### Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization, runs first |
| `lib/features/recipe_history/presentation/screens/home_screen.dart` | Main home screen |
| `lib/features/auth/domain/entities/profile.dart` | User profile model |
| `lib/features/auth/domain/entities/user_preferences.dart` | Cooking preferences model |
| `lib/features/recipe_generation/domain/entities/recipe.dart` | Recipe model |
| `supabase/migrations/001_initial_schema.sql` | Original database structure |
| `pubspec.yaml` | Dependencies list |
| `.env` | Supabase credentials (YOU create this) |

### Where to Add New Features

| Task | Location |
|------|----------|
| Add new screen | `lib/features/<feature>/presentation/screens/` |
| Add new widget | `lib/features/<feature>/presentation/widgets/` or `lib/shared/widgets/` |
| Add new Supabase API call | `lib/features/<feature>/data/repositories/` |
| Add new data model (for Supabase) | `lib/features/<feature>/data/models/` |
| Add new domain entity | `lib/features/<feature>/domain/entities/` |
| Add new Riverpod provider | `lib/features/<feature>/presentation/providers/` |
| Add new constant | `lib/core/constants/app_constants.dart` |

### Understanding the Data Flow

**How data moves through the app:**

1. **User Action** → (e.g., user saves a recipe)
2. **Presentation Layer** (`screens/`, `widgets/`) → Uses Riverpod provider
3. **Provider** (`providers/`) → Calls repository
4. **Repository** (`data/repositories/`) → Converts entity to model, calls Supabase
5. **Supabase** → Saves to database
6. **Response** → Comes back through repository
7. **Repository** → Converts model back to entity
8. **Provider** → Updates state
9. **UI** → Rebuilds with new data

**Example: Saving a Recipe**
```dart
// 1. User taps "Save" button (UI)
// 2. Widget calls provider
ref.read(recipeProvider.notifier).saveRecipe(recipe);

// 3. Provider calls repository
await _recipeRepository.saveRecipe(recipe);

// 4. Repository converts to model and saves to Supabase
final model = RecipeModel.fromEntity(recipe);
await supabase.from('recipes').insert(model.toJson());

// 5. Data saved! ✅
```

---

## Common Issues & Troubleshooting

### Build Errors

#### ❌ "Gradle build failed" (Android)
```bash
# Solution 1: Clean build
flutter clean
flutter pub get
cd android
./gradlew clean  # Mac/Linux
gradlew.bat clean  # Windows
cd ..
flutter build apk

# Solution 2: Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.0  # Mac/Linux
gradlew.bat wrapper --gradle-version 8.0  # Windows
```

#### ❌ "CocoaPods not installed" (iOS/Mac)
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

#### ❌ "Module 'tflite_flutter' not found"
```bash
flutter pub get
flutter clean
flutter run
```

### Runtime Errors

#### ❌ "Camera permission denied"
**Problem**: User denied camera permission or not requested properly.

**Solution:**
- **Android**: Check `android/app/src/main/AndroidManifest.xml` has:
  ```xml
  <uses-permission android:name="android.permission.CAMERA"/>
  ```
- **iOS**: Check `ios/Runner/Info.plist` has:
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>We need camera access to scan your fridge</string>
  ```

#### ❌ "Supabase connection error"
```dart
// Check your .env file is loaded properly
// Verify in lib/main.dart or where Supabase is initialized:
import 'package:flutter_dotenv/flutter_dotenv.dart';

// If using flutter_dotenv, initialize:
await dotenv.load(fileName: ".env");
```

**Alternative**: Hardcode temporarily for testing (DON'T commit!):
```dart
const supabaseUrl = 'https://your-project.supabase.co';
const supabaseAnonKey = 'your-key-here';
```

#### ❌ "AI Model not loading"
**Problem**: TFLite model file missing or incorrect path.

**Solution:**
1. Check `assets/models/gemma-3n-e4b-it-int4.tflite` exists
2. Verify `pubspec.yaml` includes:
   ```yaml
   flutter:
     assets:
       - assets/models/
   ```
3. Run `flutter pub get` and rebuild

### Hot Reload Issues

#### ❌ "Hot reload not working / changes not showing"
```bash
# Try hot restart (capital R in terminal)
R

# If still not working, stop and rebuild:
q  # quit
flutter run
```

#### ❌ "State not updating after hot reload"
- **Riverpod providers**: Hot reload sometimes requires restart
- Use **hot restart (R)** instead of hot reload (r)

---

## Development Workflow

### Daily Workflow
```bash
# 1. Switch to your dev branch
git checkout dev/your-name

# 2. Sync with latest dev changes
git pull origin dev

# 3. Install any new dependencies
flutter pub get

# 4. Regenerate provider code (if new providers added)
dart run build_runner build --delete-conflicting-outputs

# 5. Run app
flutter run

# 6. At end of day, push your work
git add .
git commit -m "feat: Your changes description"
git push origin dev/your-name
```

### Before Committing Code

```bash
# 1. Format code
dart format lib/

# 2. Analyze for issues
flutter analyze

# 3. Run tests (if any)
flutter test

# 4. Check what you're committing
git status
git diff

# 5. Commit
git add .
git commit -m "feat: Add ingredient detection UI"
git push origin main
```

### Git Branching Strategy

**We use a three-tier branching model:**

```
main (protected)
  └── dev (integration branch)
        └── dev/{developer} (personal dev branches)
```

**Branch Purposes:**
- **`main`**: Production-ready code (PROTECTED - no direct pushes)
- **`dev`**: Integration branch for testing features together
- **`dev/{developer}`**: Your personal development branch (e.g., `dev/berkay`, `dev/alice`)

**Workflow:**

#### 1. Setting Up Your Dev Branch (First Time)
```bash
# Make sure you have the latest code
git pull origin main

# Create your personal dev branch
git checkout -b dev/your-name
# Example: git checkout -b dev/berkay

# Push your branch to GitHub
git push -u origin dev/your-name
```

#### 2. Daily Development Workflow
```bash
# Start your day - sync with dev branch
git checkout dev/your-name
git pull origin dev

# Work on your feature, make changes
# ... edit files ...

# Commit regularly (small commits are good!)
git add .
git commit -m "feat: Add recipe card component"

# Push to your branch at end of day
git push origin dev/your-name
```

#### 3. Small Changes → `dev` Branch (Pull Request)
For small, self-contained changes (bug fixes, minor features, documentation):

```bash
# Create a feature branch from dev
git checkout dev
git pull origin dev
git checkout -b feature/fix-camera-permissions

# Make your changes
# ... edit files ...

# Commit and push
git add .
git commit -m "fix: Add camera permission handling for Android"
git push origin feature/fix-camera-permissions

# Create Pull Request on GitHub:
# - Base: dev
# - Compare: feature/fix-camera-permissions
# - Request review from at least 1 teammate
```

#### 4. Big Changes → `dev/{developer}` Branch (Merge Request)
For major features or experimental work:

```bash
# Work in your personal dev branch
git checkout dev/your-name

# Make multiple commits over days/weeks
git add .
git commit -m "feat: Add ingredient detection UI"
# ... more work ...
git commit -m "feat: Integrate AI model with UI"
# ... more work ...
git commit -m "test: Add tests for ingredient detection"

# When ready, create Merge Request:
# 1. Push your branch
git push origin dev/your-name

# 2. On GitHub, create Pull Request:
#    - Base: dev
#    - Compare: dev/your-name
#    - Add detailed description of changes
#    - Request review from team
```

#### 5. Merging `dev` → `main` (Team Decision)
When `dev` is stable and tested:

```bash
# Team lead creates Pull Request:
# - Base: main
# - Compare: dev
# - All team members review
# - Merge only when everyone approves
```

**Branch Protection Rules:**
- ✅ `main`: Requires PR approval, no direct pushes
- ✅ `dev`: Requires PR approval for merges
- ✅ `dev/{developer}`: You can push directly (it's yours!)

**When to Use Which:**

| Scenario | Branch to Use | Action |
|----------|--------------|--------|
| Quick bug fix | `feature/fix-name` → `dev` | Pull Request |
| Documentation update | `docs/update-readme` → `dev` | Pull Request |
| Small UI tweak | `feature/button-style` → `dev` | Pull Request |
| New major feature | `dev/your-name` | Work here, merge to `dev` when done |
| Experimental code | `dev/your-name` | Test freely, merge if it works |
| Refactoring multiple files | `dev/your-name` | Work here, merge to `dev` when stable |

---

## Testing on Different Platforms

### Performance Testing

| Platform | Expected Performance | Notes |
|----------|---------------------|-------|
| Android (Mid-range) | AI: 5-10s, UI: 60fps | Test on Pixel 5 equivalent |
| Android (Low-end) | AI: 10-20s, UI: 30-60fps | May lag during inference |
| iOS (iPhone 12+) | AI: 3-7s, UI: 60fps | Generally faster than Android |
| Emulator/Simulator | AI: 15-30s, UI: 30fps | Much slower than physical device |

### Camera Testing

**Best Practices:**
- ✅ Test on **physical devices** (camera doesn't work well in emulators)
- ✅ Test different lighting conditions
- ✅ Test with real fridge photos (not stock images)

**Android Emulator Camera:**
- Emulator camera shows test patterns, not real camera
- Use **image picker** to upload test images instead

**iOS Simulator Camera:**
- Similar to Android, limited functionality

---

## Working with AI Model

### Model Status

> 🚧 **Currently**: The AI model (`gemma-3n-e4b-it-int4.tflite`) is **not included** in the repo due to size (~2-3GB).

### Getting the Model

**Option 1: Team Member Has It**
Ask a teammate who already downloaded it to share via Google Drive/Dropbox.

**Option 2: Download from Hugging Face**
1. Visit: [google/gemma-3n-e4b-it](https://huggingface.co/google/gemma-3n-e4b-it)
2. Follow conversion instructions to TFLite format
3. Place in `assets/models/gemma-3n-e4b-it-int4.tflite`

**Option 3: Mock for Development**
```dart
// Temporarily bypass AI for UI development
// In lib/features/ingredient_detection/data/services/gemma_inference_service.dart

Future<String> detectIngredients(Uint8List imageBytes) async {
  // Mock response
  await Future.delayed(Duration(seconds: 2));
  return "chicken, tomatoes, onions, garlic, olive oil";
}
```

### Model Troubleshooting

**❌ "Model file not found"**
```dart
// Verify asset path in pubspec.yaml:
flutter:
  assets:
    - assets/models/

// Rebuild
flutter clean
flutter pub get
flutter run
```

**❌ "Out of memory during inference"**
- Close other apps
- Test on device with 4GB+ RAM
- Reduce image size before inference

---

## Git Handling

### Git Best Practices

**DO:**
- ✅ Pull from `dev` before starting work: `git pull origin dev`
- ✅ Work in your `dev/{your-name}` branch for big features
- ✅ Commit often with clear messages
- ✅ Push at end of day to your branch
- ✅ Create Pull Requests for small changes
- ✅ Test your code before creating PR/MR
- ✅ Review teammates' Pull Requests
- ✅ Write descriptive PR descriptions

**DON'T:**
- ❌ Push directly to `main` (it's protected anyway)
- ❌ Push directly to `dev` (use PR instead)
- ❌ Commit `.env` file (has secrets!)
- ❌ Commit generated files (`*.g.dart`, `*.freezed.dart`, `build/`)
- ❌ Create PR with failing tests or build errors
- ❌ Merge your own PR without review
- ❌ Force push to shared branches (`git push -f`)

### Merge Conflicts

**If you see merge conflicts:**
```bash
# 1. Make sure you're in your branch
git checkout dev/your-name

# 2. Pull latest changes from dev
git pull origin dev

# 3. Open conflicted files (VS Code shows them)
# 4. Choose which version to keep (or combine both)
# 5. Remove conflict markers (<<<<, ====, >>>>)
# 6. Test app still works!

# 7. Mark as resolved
git add .
git commit -m "fix: Resolve merge conflict in [file]"
git push origin dev/your-name
```

**Avoiding Conflicts:**
- Sync with `dev` regularly: `git pull origin dev`
- Communicate with team about which files you're working on
- Keep your feature branches short-lived (merge often)
- Pull before pushing: `git pull origin dev/your-name` (if multiple people work on your branch)

### Code Review Checklist

**Before creating Pull Request:**
- [ ] Code builds without errors: `flutter build apk` (or `flutter build ios`)
- [ ] Tested on at least one device/emulator
- [ ] No hardcoded secrets (check for API keys, URLs in code)
- [ ] No `.env` or generated files in commit
- [ ] Formatted code: `dart format lib/`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Wrote clear commit messages
- [ ] Updated documentation if needed
- [ ] PR description explains what and why

**When reviewing others' PRs:**
- [ ] Read the code changes carefully
- [ ] Check if it follows project structure
- [ ] Pull the branch and test it: `git checkout feature/branch-name`
- [ ] Look for potential bugs or edge cases
- [ ] Suggest improvements kindly
- [ ] Approve if everything looks good

---

## Platform-Specific Notes

### Windows Developers

**PowerShell Commands:**
```powershell
# Check Flutter version
flutter --version

# Find devices
flutter devices

# Run with verbose logging (for debugging)
flutter run -v

# Build APK for Android
flutter build apk --release
```

**Android SDK Location:**
- Default: `C:\Users\YourName\AppData\Local\Android\Sdk`

### Mac Developers

**Terminal Commands:**
```bash
# Same as Windows, but some paths differ
flutter doctor

# iOS-specific: Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# CocoaPods update
cd ios && pod update && cd ..
```

**Xcode Tips:**
- Keep Xcode updated via App Store
- If build fails, try: **Product** → **Clean Build Folder** (Cmd+Shift+K)

---

## Quick Reference

### Essential Commands

| Command | Description |
|---------|-------------|
| `flutter doctor` | Check setup health |
| `flutter pub get` | Install dependencies |
| `flutter clean` | Clean build cache |
| `flutter run` | Run app |
| `flutter devices` | List available devices |
| `flutter analyze` | Check for code issues |
| `dart format lib/` | Format code |
| `git pull origin main` | Get latest code |

### Emergency Fixes

**"Nothing works!"**
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**"Emulator won't start"**
- Close Android Studio/Xcode
- Restart computer
- Try different emulator (create new one)

**"I broke something"**
```bash
# Reset to last working commit
git log  # find last good commit hash
git reset --hard <commit-hash>
```

---

## Getting Help

### Resources
- 📖 [Flutter Docs](https://docs.flutter.dev/)
- 📖 [Riverpod Docs](https://riverpod.dev/)
- 📖 [Supabase Flutter Docs](https://supabase.com/docs/reference/dart)
- 💬 Team chat/Discord

### Debugging Tips
1. **Read error messages carefully** - they usually tell you what's wrong
2. **Google the error** - add "flutter" to your search
3. **Check `flutter doctor`** - fixes 80% of setup issues
4. **Ask teammates** - they might have solved it already
5. **Use `print()` statements** - simple but effective debugging

---

## Next Steps

**After Setup:**
1. ✅ Run app successfully on your device
2. ✅ Create test account and log in
3. ✅ Explore the codebase (start with `lib/main.dart`)
4. ✅ Pick a feature to work on (check issues/tasks)

**Learning Resources:**
- [Flutter Basics (Official)](https://docs.flutter.dev/get-started/codelab)
- [Riverpod Tutorial](https://codewithandrea.com/articles/flutter-state-management-riverpod/)
- [Supabase Quickstart](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)

---

**Good luck! 🚀**

If you run into issues not covered here, document the solution and update this guide for the team!
