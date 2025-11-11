# Development Guide - AI Recipe Generator
**Team Guide for Setup, Development, and Troubleshooting**

> 📱 Flutter + Firebase + Cloud AI (Gemini API)  
> Target Platforms: iOS & Android

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [First-Time Setup](#first-time-setup)
3. [Running the App](#running-the-app)
4. [Firebase Configuration](#firebase-configuration)
5. [Project Structure](#project-structure)
6. [Common Issues & Troubleshooting](#common-issues--troubleshooting)
7. [Development Workflow](#development-workflow)
8. [Testing on Different Platforms](#testing-on-different-platforms)
9. [Working with Gemini AI](#working-with-gemini-ai)
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
- ✅ **Firebase Project Access**: Access to team project `eternal-water-477911-m6` (project owner will grant access)
- ✅ **Google Account**: Required for Firebase authentication and testing

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
- Downloads packages: `firebase_core`, `firebase_auth`, `firebase_ai`, `camera`, `image`, `riverpod`, etc.
- Note: Gemini AI runs in the cloud via Firebase AI - no local model downloads required!
- Creates `.dart_tool` folder with package metadata

### 4. Configure Firebase (Already Done!)

**Firebase is already configured for the project!** The following files are already in the repository:
- ✅ `firebase.json` - Firebase project configuration
- ✅ `lib/firebase_options.dart` - Auto-generated Firebase options
- ✅ `android/app/google-services.json` - Android Firebase config
- ✅ `firestore.rules` - Firestore security rules
- ✅ `storage.rules` - Firebase Storage security rules

**No additional Firebase setup needed for development!** Just run `flutter pub get` and you're ready.

**Optional - Firebase CLI (for advanced users):**
If you want to deploy security rules or manage Firebase from command line:

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# View current project
firebase projects:list
```

> ⚠️ **Note**: You don't need Firebase CLI for regular development. It's only needed if you're modifying Firestore rules or deploying hosting.

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

## Firebase Configuration

### Database Setup (Already Configured!)

**The Firestore database is already set up and ready to use!** The security rules have been deployed and your database structure is configured.

**What Already Exists:**
- ✅ `profiles` collection (user profile data: display name, avatar, bio, preferences)
- ✅ `user_preferences` collection (cooking preferences: skill level, dietary restrictions, favorite cuisines, kitchen equipment)
- ✅ `recipes` collection (AI-generated recipes with ingredients, instructions, ratings)
- ✅ `recipe_cache` collection (cached recipe generations for improved performance)
- ✅ Row Level Security via Firestore Rules (users only see their own data)
- ✅ Automatic profile creation on signup (Firebase Auth triggers)

**Firestore Collections Explained:**

1. **`profiles`** - Extended user information:
   - Document ID = User's Firebase Auth UID
   - Basic info: email, display_name, avatar_url, bio
   - Settings: language_preference, theme_preference, notifications
   - Automatically created when user signs up

2. **`user_preferences`** - Cooking preferences:
   - Document ID = User's Firebase Auth UID
   - skill_level: 'beginner', 'intermediate', 'advanced'
   - spice_tolerance: 'none', 'mild', 'medium', 'hot', 'very_hot'
   - cooking_time_preference: 'quick', 'moderate', 'long'
   - dietary_restrictions: array of strings (e.g., ["vegetarian", "gluten-free"])
   - excluded_ingredients: ingredients to avoid
   - favorite_cuisines, favorite_proteins, kitchen_equipment: arrays

3. **`recipes`** - AI-generated recipes:
   - Document ID = Auto-generated by Firestore
   - user_id: Owner's Firebase Auth UID
   - Basic info: recipe_name, description, prep_time, cook_time, servings
   - Categorization: cuisine_type, difficulty_level, meal_type
   - Content: ingredients (array), instructions (text array)
   - Metadata: detected_ingredients, dietary_tags, allergens
   - User features: is_favorite, rating (1-5), notes
   - Timestamps: created_at, updated_at

4. **`recipe_cache`** - Cached AI-generated recipes:
   - Document ID = `{userId}_{cacheKey}` (e.g., `abc123_chicken-tomatoes-onions`)
   - user_id: Owner's Firebase Auth UID
   - cache_key: Hash of ingredients + preferences
   - cached_recipe: Full recipe object
   - created_at: Timestamp for cache expiration
   - Purpose: Avoid redundant Gemini API calls, save quota

### Firestore Security Rules

**Location**: `firestore.rules`

**Current Rules:**
```firerules
// User can only access their own profile
match /profiles/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// User can only access their own preferences
match /user_preferences/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// User can only access their own recipes
match /recipes/{recipeId} {
  allow create: if request.auth != null && request.resource.data.user_id == request.auth.uid;
  allow read, update, delete: if request.auth != null && resource.data.user_id == request.auth.uid;
}

// User can only access their own recipe cache
match /recipe_cache/{cacheId} {
  allow read, write: if request.auth != null && resource.data.user_id == request.auth.uid;
  allow create: if request.auth != null && request.resource.data.user_id == request.auth.uid;
}
```

**What This Means:**
- ✅ Users can only see/edit their own data
- ✅ No user can access another user's recipes or preferences
- ✅ Authentication is required for all operations
- ✅ Data is automatically scoped to authenticated user

### Verify Setup

**Check Firestore Collections:**
1. Go to **Firebase Console**: https://console.firebase.google.com/project/eternal-water-477911-m6
2. Navigate to **Firestore Database** in left sidebar
3. You should see collections: `profiles`, `user_preferences`, `recipes`, `recipe_cache`
4. Click on each collection to see the document structure

**Test Authentication:**
1. Run the app and sign up with a test email or Google Sign-In
2. Check **Firebase Console** → **Authentication** → Users
3. Check **Firestore Database** → `profiles` - you should see auto-created profile
4. Check **Firestore Database** → `user_preferences` - you should see auto-created preferences

**Test Recipe Creation:**
1. Use camera to scan ingredients in the app
2. Generate a recipe
3. Save the recipe
4. Check **Firebase Console** → **Firestore Database** → `recipes`
5. You should see your saved recipe with all fields

**Test Recipe Caching:**
1. Generate a recipe with specific ingredients
2. Go back and generate again with same ingredients
3. Check **Firestore Database** → `recipe_cache` - should see cached entry
4. Second generation should be instant (loaded from cache)

### Firebase Troubleshooting

**❌ Error: "Permission denied" on Firestore**
- Make sure you're logged in (authenticated) before trying to save/read data
- Firestore rules require `request.auth.uid` to match the user_id in the document
- Test: Check if you can see your user in **Firebase Console** → **Authentication**

**❌ Error: "Firebase not initialized"**
- Ensure `Firebase.initializeApp()` is called in `main.dart` before any Firebase operations
- Check `lib/firebase_options.dart` exists and is up to date
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) are in correct locations

**❌ Error: "Collection does not exist"**
- Firestore creates collections automatically when you write the first document
- Try creating a document first: Sign up → Save a recipe
- If it still fails, check Firestore rules in Firebase Console

**❌ Error: "Field does not exist"**
- Make sure you pulled the latest code: `git pull origin main`
- Check if the field exists in **Firebase Console** → **Firestore Database**
- Field names in Dart code must match snake_case in Firestore (e.g., `user_id` not `userId`)

**❌ Profile/Preferences Not Auto-Created on Signup**
- Check **Firebase Console** → **Authentication** to see if user was created
- Check **Firestore Database** → `profiles` and `user_preferences` for documents with matching UID
- Auto-creation is handled in `AuthRepositoryImpl.signUp()` - check for errors in logs
- Try signing out and signing up again with a new account

**❌ Error: "Quota exceeded" (Firestore)**
- Free tier: 50,000 reads/day, 20,000 writes/day
- Check **Firebase Console** → **Usage** to see current quota
- Wait for quota reset (daily) or optimize queries to use fewer reads/writes

---

## Project Structure

### Overview
```
lib/
├── main.dart                    # App entry point (Firebase initialization)
├── firebase_options.dart        # Auto-generated Firebase config
├── core/
│   ├── constants/
│   │   ├── app_constants.dart  # App-wide settings, Gemini config
│   │   └── prompt_templates.dart # Gemini AI prompts
│   ├── errors/
│   │   └── ai_exceptions.dart  # Custom AI error classes
│   ├── services/
│   │   ├── gemini_ai_service.dart    # Firebase AI with Gemini API
│   │   └── permission_service.dart   # Camera/storage permissions
│   ├── theme/
│   │   └── app_theme.dart      # Colors, fonts, dark/light themes
│   └── utils/                   # Helper functions
├── features/
│   ├── auth/                    # Login, signup, Google Sign-In
│   ├── camera/                  # Camera capture logic
│   ├── ingredient_detection/    # AI ingredient detection from photos
│   ├── recipe_generation/       # AI recipe generation with Gemini
│   ├── recipe_history/          # Saved recipes list
│   ├── recipe_detail/           # Individual recipe view
│   ├── recipe_results/          # Generated recipe results
│   ├── favorites/               # Favorite recipes
│   ├── pantry/                  # Pantry management (manual ingredients)
│   ├── profile/                 # User profile, preferences
│   └── home/                    # Home screen, navigation
└── shared/
    ├── providers/               # Global Riverpod providers
    └── widgets/                 # Reusable UI components
```

### Key Files to Know

| File | Purpose |
|------|---------|
| `lib/main.dart` | App initialization, Firebase setup, runs first |
| `lib/firebase_options.dart` | Auto-generated Firebase configuration |
| `lib/core/services/gemini_ai_service.dart` | Firebase AI with Gemini API service |
| `lib/core/constants/prompt_templates.dart` | Gemini AI prompts for ingredients & recipes |
| `lib/features/home/presentation/screens/home_screen.dart` | Main home screen with navigation |
| `lib/features/auth/domain/entities/profile.dart` | User profile entity |
| `lib/features/auth/domain/entities/user_preferences.dart` | Cooking preferences entity |
| `lib/features/recipe_generation/domain/entities/recipe.dart` | Recipe entity |
| `lib/features/auth/data/repositories/auth_repository_impl.dart` | Firebase Auth implementation |
| `lib/features/recipe_generation/data/repositories/recipe_repository_impl.dart` | Firestore recipe operations |
| `firestore.rules` | Firestore security rules |
| `firebase.json` | Firebase project configuration |
| `pubspec.yaml` | Dependencies list |
| `android/app/google-services.json` | Android Firebase config |

### Where to Add New Features

| Task | Location |
|------|----------|
| Add new screen | `lib/features/<feature>/presentation/screens/` |
| Add new widget | `lib/features/<feature>/presentation/widgets/` or `lib/shared/widgets/` |
| Add new Firebase API call | `lib/features/<feature>/data/repositories/` |
| Add new data model (for Firestore) | `lib/features/<feature>/data/models/` |
| Add new domain entity | `lib/features/<feature>/domain/entities/` |
| Add new Riverpod provider | `lib/features/<feature>/presentation/providers/` |
| Add new constant | `lib/core/constants/app_constants.dart` |
| Modify Gemini AI prompts | `lib/core/constants/prompt_templates.dart` |
| Update Firestore rules | `firestore.rules` (deploy with Firebase CLI) |
| Add custom AI logic | `lib/core/services/gemini_ai_service.dart` |

### Understanding the Data Flow

**How data moves through the app:**

1. **User Action** → (e.g., user saves a recipe)
2. **Presentation Layer** (`screens/`, `widgets/`) → Uses Riverpod provider
3. **Provider** (`providers/`) → Calls repository
4. **Repository** (`data/repositories/`) → Converts entity to model, calls Firebase/Firestore
5. **Firebase/Firestore** → Saves to cloud database
6. **Response** → Comes back through repository
7. **Repository** → Converts Firestore model back to entity
8. **Provider** → Updates state
9. **UI** → Rebuilds with new data

**Example: Saving a Recipe**
```dart
// 1. User taps "Save" button (UI)
// 2. Widget calls provider
ref.read(recipeProvider.notifier).saveRecipe(recipe);

// 3. Provider calls repository
await _recipeRepository.createRecipe(recipe);

// 4. Repository converts to model and saves to Firestore
final model = RecipeModel.fromEntity(recipe);
await _firestore.collection('recipes').add(model.toJson());

// 5. Data saved to Firestore! ✅
```

**Example: AI Recipe Generation**
```dart
// 1. User scans ingredients with camera
// 2. GeminiAIService detects ingredients
final ingredients = await _geminiService.detectIngredients(imageBytes);

// 3. User taps "Generate Recipe"
// 4. GeminiAIService generates recipe (cloud-based)
final recipeData = await _geminiService.generateRecipe(
  ingredients: ingredients,
  dietaryRestrictions: userPrefs.dietaryRestrictions,
  skillLevel: userPrefs.skillLevel,
);

// 5. Repository saves to Firestore
await _recipeRepository.createRecipe(recipe);

// 6. UI updates with new recipe! ✅
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

#### ❌ "Module 'firebase_ai' not found" or similar Firebase errors
```bash
flutter pub get
flutter clean
flutter run

# If on iOS, also do:
cd ios
pod install
cd ..
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

#### ❌ "Firebase connection error" or "Permission denied"
**Problem**: Firebase not initialized or authentication issue.

**Solution:**
```dart
// Check Firebase is initialized in lib/main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Make sure user is signed in before accessing Firestore
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
  // Redirect to login
}
```

**Check Firebase Console:**
- Verify project exists: https://console.firebase.google.com/project/eternal-water-477911-m6
- Check Authentication is enabled
- Verify Firestore is set up
- Review Firestore rules in `firestore.rules`

#### ❌ "AI Model not loading" or "Gemini API error"
**Problem**: Firebase AI not initialized or API quota exceeded.

**Solution:**
1. Check Firebase AI is initialized:
   ```dart
   // GeminiAIService initializes automatically on first use
   // Check logs for: "GeminiAIService: Initialization successful"
   ```

2. Verify Gemini API is enabled:
   - Go to: https://console.firebase.google.com/project/eternal-water-477911-m6/ailogic
   - Check if Gemini API is enabled
   - See [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md) for setup instructions

3. Check API quota:
   - Free tier: 15 requests/minute, 1500 requests/day
   - Check usage: https://console.firebase.google.com/project/eternal-water-477911-m6/usage
   - Wait for quota reset or optimize number of API calls

4. Check internet connection (Gemini runs in the cloud!)

5. Review error logs for specific error messages

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
| Android (Mid-range) | AI: 2-5s, UI: 60fps | Cloud-based AI, depends on internet speed |
| Android (Low-end) | AI: 3-7s, UI: 30-60fps | Slower internet may cause delays |
| iOS (iPhone 12+) | AI: 2-4s, UI: 60fps | Generally fast with good internet |
| Emulator/Simulator | AI: 2-7s, UI: 30fps | Depends on host machine & internet |

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

## Working with Gemini AI

### Overview

The app uses **Firebase AI with Google's Gemini API** for cloud-based generative AI. This means:
- ✅ **No local model downloads** - everything runs in the cloud
- ✅ **Always up-to-date** - Google maintains and improves the model
- ✅ **Multimodal** - Can process both images and text
- ✅ **Fast inference** - Optimized cloud infrastructure
- ❌ **Requires internet** - Won't work offline

### Current Configuration

**Model**: `gemini-2.0-flash-exp` (configured in `lib/core/constants/app_constants.dart`)

**Parameters** (in `AppConstants`):
```dart
static const String geminiModel = 'gemini-2.0-flash-exp';
static const double temperature = 0.7;  // Creativity level (0.0-1.0)
static const int topK = 40;             // Diversity of responses
static const int maxTokens = 4096;      // Max response length
```

**Timeouts**:
- Ingredient detection: 30 seconds
- Recipe generation: 45 seconds

### How It Works

**1. Ingredient Detection** (Image → Text):
```dart
// User takes photo of fridge/pantry
final imageBytes = await camera.takePicture();

// Gemini analyzes image and detects ingredients
final ingredients = await geminiService.detectIngredients(imageBytes);
// Result: ["chicken", "tomatoes", "onions", "garlic", ...]
```

**2. Recipe Generation** (Text → JSON):
```dart
// Gemini generates a complete recipe based on ingredients + preferences
final recipeData = await geminiService.generateRecipe(
  ingredients: ["chicken", "tomatoes", "onions"],
  dietaryRestrictions: "gluten-free",
  skillLevel: "beginner",
  cuisinePreference: "italian",
);
// Result: Structured recipe with name, ingredients, instructions, etc.
```

### Prompts Configuration

**Location**: `lib/core/constants/prompt_templates.dart`

**Ingredient Detection Prompt**:
```dart
static String getIngredientDetectionPrompt() {
  return '''
Analyze this image and list ALL visible food ingredients.
Return ONLY a comma-separated list of ingredients, nothing else.
Example: chicken, tomatoes, onions, garlic, olive oil
''';
}
```

**Recipe Generation Prompt**:
```dart
static String getRecipeGenerationPrompt({
  required List<String> ingredients,
  String? dietaryRestrictions,
  String? skillLevel,
  String? cuisinePreference,
}) {
  return '''
Generate a recipe using these ingredients: ${ingredients.join(", ")}
Dietary restrictions: ${dietaryRestrictions ?? "none"}
Skill level: ${skillLevel ?? "any"}
Cuisine: ${cuisinePreference ?? "any"}

Return a JSON object with this EXACT structure:
{
  "name": "Recipe Name",
  "description": "Brief description",
  "prepTime": 15,
  "cookTime": 30,
  ...
}
''';
}
```

**Customizing Prompts:**
- Edit `lib/core/constants/prompt_templates.dart`
- Modify prompt text to change AI behavior
- Test with `flutter run` to see results
- Fine-tune for better accuracy or different cuisines

### API Quotas & Limits

**Gemini Developer API (Free Tier)**:
- **15 requests per minute (RPM)**
- **1,500 requests per day (RPD)**
- **1 million input tokens per minute**
- **32,000 output tokens per minute**

**What This Means for Users:**
- Each ingredient scan = 1 request
- Each recipe generation = 1 request
- User can scan ~7 times per minute, ~750 times per day
- For a single user, this is more than enough!

**Handling Quota Limits:**
```dart
// The app already implements:
// 1. Recipe caching in Firestore (avoid duplicate API calls)
// 2. Error handling for quota exceeded
// 3. User-friendly error messages

// Check GeminiAIService for implementation details
```

**Checking Usage:**
- Dashboard: https://console.firebase.google.com/project/eternal-water-477911-m6/ailogic
- Monitor daily quota usage
- Set up alerts if approaching limits

### Recipe Caching

**Why Caching?**
- Save Gemini API quota
- Faster response for repeated ingredient combinations
- Better user experience (instant results for cached recipes)

**How It Works:**
1. User scans ingredients: `["chicken", "tomatoes", "onions"]`
2. App creates cache key: hash of ingredients + preferences
3. Check Firestore `recipe_cache` collection for existing recipe
4. **If cached**: Return instantly ✅
5. **If not cached**: Call Gemini API → Save to cache → Return recipe

**Cache Expiration:**
- Cached recipes expire after 7 days (configurable)
- Can be cleared manually in app settings
- Automatically cleaned up by Firestore TTL (if configured)

**Implementation:**
```dart
// Check cache before calling Gemini API
final cachedRecipe = await _recipeCacheRepository.getCachedRecipe(cacheKey);
if (cachedRecipe != null) {
  return cachedRecipe; // Instant result!
}

// No cache, call Gemini API
final recipe = await _geminiService.generateRecipe(...);

// Save to cache for next time
await _recipeCacheRepository.cacheRecipe(cacheKey, recipe);
```

### Testing Gemini AI

**1. Test Ingredient Detection:**
```bash
# Run app
flutter run

# Steps:
# 1. Navigate to camera screen
# 2. Take photo of food items (or select from gallery)
# 3. Wait for AI detection
# 4. Check console for logs:
#    "GeminiAIService: Starting ingredient detection"
#    "GeminiAIService: Detected 5 ingredients"
```

**2. Test Recipe Generation:**
```bash
# Steps:
# 1. Use detected ingredients or add manually
# 2. Set preferences (optional)
# 3. Tap "Generate Recipe"
# 4. Wait for response (2-5 seconds)
# 5. Verify recipe has all fields
```

**3. Test Caching:**
```bash
# Steps:
# 1. Generate a recipe with specific ingredients
# 2. Go back to home
# 3. Generate again with SAME ingredients
# 4. Second generation should be instant (loaded from cache)
# 5. Check Firestore Console → recipe_cache collection
```

### Troubleshooting Gemini AI

**❌ "Gemini API not enabled"**
- Go to Firebase Console → AI Logic
- Enable Gemini Developer API
- See [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md) for detailed setup

**❌ "Quota exceeded"**
- Wait for quota reset (resets every minute/day)
- Check usage: https://console.firebase.google.com/project/eternal-water-477911-m6/usage
- Implement more aggressive caching
- Consider upgrading to paid plan if needed

**❌ "Network error" or timeout**
- Check internet connection
- Verify Firebase project is active
- Check if Firestore rules are blocking requests
- Try again (temporary network issue)

**❌ "Response blocked by safety filters"**
- Gemini blocked the response due to safety concerns
- Modify prompt to be less ambiguous
- Check logs for `FinishReason.safety`
- Retry with different ingredients or wording

**❌ "Empty response" or parsing error**
- Gemini returned unexpected format
- Check `PromptTemplates.parseRecipeResponse()` for parsing logic
- Verify prompt asks for correct JSON structure
- Add fallback handling for malformed responses

**❌ "AI generating weird/wrong recipes"**
- Adjust temperature (lower = more conservative, higher = more creative)
- Modify prompts in `prompt_templates.dart`
- Add more specific instructions
- Test with different ingredient combinations

### Advanced: Customizing AI Behavior

**Change Model:**
```dart
// In lib/core/constants/app_constants.dart
static const String geminiModel = 'gemini-2.0-flash-exp';
// Or try: 'gemini-1.5-pro' for more advanced reasoning
```

**Adjust Creativity:**
```dart
// Lower temperature = more predictable, safer recipes
static const double temperature = 0.3; // Conservative

// Higher temperature = more creative, experimental recipes
static const double temperature = 1.0; // Very creative
```

**Change Response Length:**
```dart
// Shorter recipes
static const int maxTokens = 2048;

// Longer, more detailed recipes
static const int maxTokens = 8192;
```

**Streaming Responses (Future Enhancement):**
```dart
// GeminiAIService already has streaming support!
final stream = geminiService.generateResponseStream(
  prompt: recipePrompt,
  imageData: imageBytes,
);

await for (final chunk in stream) {
  print('Received chunk: $chunk');
  // Update UI progressively as response streams in
}
```

### Cost Management

**Free Tier:**
- Perfect for development and small-scale testing
- No billing required
- Generous limits for most personal projects

**Paid Plans (if needed):**
- **Gemini 2.0 Flash**: ~$0.075 per 1M input tokens, ~$0.30 per 1M output tokens
- Very cost-effective for most use cases
- Example: 1000 recipe generations ≈ $0.50 - $2.00

**Best Practices:**
- ✅ Implement caching (already done!)
- ✅ Optimize prompts to reduce token usage
- ✅ Set reasonable timeouts
- ✅ Handle errors gracefully
- ✅ Monitor usage in Firebase Console

### Resources

- **Firebase AI Docs**: https://firebase.google.com/docs/ai-logic
- **Gemini API Docs**: https://ai.google.dev/gemini-api/docs
- **Gemini API Setup Guide**: [GEMINI_API_SETUP.md](GEMINI_API_SETUP.md)
- **Prompt Engineering Guide**: https://ai.google.dev/gemini-api/docs/prompting-intro

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
- ❌ Commit `google-services.json` with real keys (for private projects)
- ❌ Commit generated files (`*.g.dart`, `*.freezed.dart`, `build/`)
- ❌ Create PR with failing tests or build errors
- ❌ Merge your own PR without review
- ❌ Force push to shared branches (`git push -f`)
- ❌ Commit large files (Firebase config files are OK, but no large assets)

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
- [ ] No hardcoded secrets (Firebase config files are auto-generated, that's OK)
- [ ] No generated files in commit (`*.g.dart`, `build/`)
- [ ] Formatted code: `dart format lib/`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] Wrote clear commit messages
- [ ] Updated documentation if needed
- [ ] PR description explains what and why
- [ ] Tested Firebase features if modified (auth, Firestore, AI)

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
- 📖 [Firebase Flutter Docs](https://firebase.flutter.dev/)
- 📖 [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- 📖 [Gemini API Docs](https://ai.google.dev/gemini-api/docs)
- 📖 [Firebase AI Logic Docs](https://firebase.google.com/docs/ai-logic)
- 📄 [Gemini API Setup Guide](GEMINI_API_SETUP.md) (in this repo)
- 💬 Team chat/Discord

### Debugging Tips
1. **Read error messages carefully** - they usually tell you what's wrong
2. **Google the error** - add "flutter" and "firebase" to your search
3. **Check `flutter doctor`** - fixes 80% of setup issues
4. **Ask teammates** - they might have solved it already
5. **Use `print()` statements** - simple but effective debugging
6. **Check Firebase Console** - many issues are visible in the dashboard
7. **Monitor Firestore rules** - permission errors often come from rules
8. **Watch Gemini API quota** - check if you've hit rate limits

### Firebase-Specific Debugging

**Firebase Console Access:**
- **Project**: https://console.firebase.google.com/project/eternal-water-477911-m6
- **Authentication**: Check signed-in users
- **Firestore**: View/edit database collections
- **AI Logic**: Monitor Gemini API usage
- **Usage & Billing**: Track quotas and costs

**Common Firebase Issues:**

**❌ "Firebase App Check failed"**
- Check `FirebaseAppCheck.instance.activate()` is called in `main.dart`
- For development, debug provider is enabled (see main.dart)
- For production, configure Play Integrity (Android) / App Attest (iOS)
- See: https://firebase.google.com/docs/app-check

**❌ "Firestore permission denied"**
- Ensure user is authenticated: `FirebaseAuth.instance.currentUser != null`
- Check Firestore rules: `firestore.rules`
- Verify `user_id` field matches authenticated user's UID
- Test rules in Firebase Console → Firestore → Rules Playground

**❌ "Firebase initialization failed"**
- Check `google-services.json` (Android) exists in `android/app/`
- Check `GoogleService-Info.plist` (iOS) exists in `ios/Runner/`
- Verify `firebase_options.dart` is up to date
- Re-run `flutterfire configure` if needed (contact team lead)

**❌ "Google Sign-In not working"**
- Ensure SHA-1/SHA-256 fingerprints are registered in Firebase Console
- Get debug SHA-1: `cd android && ./gradlew signingReport`
- Add to Firebase Console → Project Settings → Your App → SHA fingerprints
- Re-download `google-services.json` after adding SHA keys

**Debugging Firestore Queries:**
```dart
// Enable Firestore debug logging
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);

// Log queries
final snapshot = await FirebaseFirestore.instance
    .collection('recipes')
    .where('user_id', isEqualTo: userId)
    .get();
print('Fetched ${snapshot.docs.length} recipes');
```

---

## Next Steps

**After Setup:**
1. ✅ Run app successfully on your device
2. ✅ Create test account and log in
3. ✅ Explore the codebase (start with `lib/main.dart`)
4. ✅ Pick a feature to work on (check issues/tasks)

**Learning Resources:**
- [Flutter Basics (Official)](https://docs.flutter.dev/get-started/codelab)
- [Riverpod Tutorial](https://codewitandrea.com/articles/flutter-state-management-riverpod/)
- [Firebase Flutter Docs](https://firebase.flutter.dev/)
- [Gemini API Setup Guide](GEMINI_API_SETUP.md)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Good luck! 🚀**

If you run into issues not covered here, document the solution and update this guide for the team!
