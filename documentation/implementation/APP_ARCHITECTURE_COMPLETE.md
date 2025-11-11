# App Architecture Implementation Summary

## Overview
This document describes the complete architecture of your ingredient scanning and recipe generation app, following the specifications you provided.

## The Two Main Components

### 1. The App Shell (The "Container")
**Location:** `lib/shared/widgets/app_shell.dart`

The `AppShell` is the main navigation container that holds the bottom navigation bar and switches between the 5 main screens. It has **no data logic** - just navigation.

- **5 Main Tabs:**
  1. **Home** - Quick scan or manual search
  2. **My Pantry** - Manage persistent pantry ingredients
  3. **Recipes** - View recipe results
  4. **Favorites** - Saved favorite recipes
  5. **Profile** - Dietary preferences and settings

- **Global Navigation:** Helper functions allow any screen to switch tabs programmatically:
  - `switchToRecipeTab(context)`
  - `switchToHomeTab(context)`
  - `switchToPantryTab(context)`
  - etc.

### 2. The App State (The "Brain")
**Location:** `lib/shared/providers/app_state_provider.dart`

This is the invisible layer that holds all important data using **Riverpod** state management:

#### Four Main State Providers:

1. **`sessionIngredientsProvider`** (Temporary)
   - Holds ingredients for quick recipe searches
   - Not persisted - cleared when app restarts
   - Used by HomeScreen → RecipeResultsScreen flow

2. **`pantryIngredientsProvider`** (Persistent)
   - Holds all ingredients the user has at home
   - Saved to local storage (Hive)
   - Used by MyPantryScreen and as fallback for RecipeResultsScreen

3. **`favoriteRecipesProvider`** (Persistent)
   - Holds all saved favorite recipes
   - Saved to local storage (Hive)
   - Used by FavoritesScreen and RecipeDetailScreen

4. **`dietaryProfileProvider`** (Persistent)
   - Holds user's dietary preferences:
     - Dietary restrictions (vegetarian, vegan, gluten-free, etc.)
     - Skill level (beginner, intermediate, advanced)
     - Cuisine preference (Italian, Asian, etc.)
   - Saved to local storage (Hive)
   - Used by ProfileScreen and RecipeResultsScreen

## Screen-by-Screen Breakdown

### HomeScreen (Tab 1)
**Location:** `lib/features/home/presentation/screens/home_screen.dart`

**Purpose:** Quick scan or manual entry for session-based recipe search

**Actions:**
- **Camera Scan Button:** 
  - Launches `CameraScreen` in `quickScan` mode
  - Receives detected ingredients
  - Writes to `sessionIngredientsProvider`
  - Switches to Recipes tab

- **Manual Entry Button:**
  - Opens `QuickManualInputSheet` modal
  - See modal details below

**Data Flow:**
- **Reads:** `sessionIngredientsProvider` (to display current session)
- **Writes:** None directly (modals handle writes)

---

### QuickManualInputSheet (Modal)
**Location:** `lib/features/home/presentation/widgets/quick_manual_input_sheet.dart`

**Purpose:** Dual-action manual ingredient entry

**Features:**
- Text input for adding ingredients
- Local temporary list of ingredients
- Two action buttons:

1. **"Save to Pantry"** Button:
   - Writes ingredients to `pantryIngredientsProvider`
   - Shows success message
   - Clears local list
   - **Modal stays open** for more entries

2. **"Find Recipes"** Button:
   - Writes ingredients to `sessionIngredientsProvider`
   - Closes modal
   - Switches to Recipes tab

---

### MyPantryScreen (Tab 2)
**Location:** `lib/features/pantry/presentation/screens/my_pantry_screen.dart`

**Purpose:** Manage persistent pantry ingredients

**Actions:**
- **Scan to Add:** Launches `CameraScreen` in `pantryAdd` mode
- **Type to Add:** Toggle manual input field
- **Remove:** Delete individual ingredients
- **Clear All:** Remove all pantry items

**Data Flow:**
- **Reads:** `pantryIngredientsProvider`
- **Writes:** `pantryIngredientsProvider`

---

### RecipeResultsScreen (Tab 3)
**Location:** `lib/features/recipe_results/presentation/screens/recipe_results_screen.dart`

**Purpose:** Display AI-generated recipe suggestions

**Smart Ingredient Selection:**
```dart
final ingredients = sessionIngredients.isNotEmpty 
    ? sessionIngredients  // Use quick search if available
    : pantryIngredients;  // Otherwise use full pantry
```

**Features:**
- Shows which ingredients are being used (session vs pantry)
- Generates 3 recipes using `GeminiAIService`
- Recipe cards with:
  - Name, description
  - Prep/cook time
  - Difficulty level
  - Favorite toggle button
- Tap card to open `RecipeDetailScreen`
- Refresh button to regenerate recipes

**Data Flow:**
- **Reads:** `sessionIngredientsProvider`, `pantryIngredientsProvider`, `dietaryProfileProvider`
- **Writes:** None (but recipe cards toggle favorites)

---

### FavoritesScreen (Tab 4)
**Location:** `lib/features/favorites/presentation/screens/favorites_screen.dart`

**Purpose:** Display and manage saved favorite recipes

**Features:**
- List of all favorited recipes
- Tap to view details
- Remove from favorites (with undo)
- Clear all favorites

**Data Flow:**
- **Reads:** `favoriteRecipesProvider`
- **Writes:** `favoriteRecipesProvider` (remove/clear)

---

### ProfileScreen (Tab 5)
**Location:** `lib/features/profile/presentation/screens/profile_screen.dart`

**Purpose:** Manage dietary preferences and app settings

**Sections:**
1. **Dietary Restrictions** - Multi-select chips (Vegetarian, Vegan, Gluten-Free, etc.)
2. **Skill Level** - Radio buttons (Beginner, Intermediate, Advanced)
3. **Cuisine Preference** - Radio buttons (Italian, Asian, Mexican, etc.)
4. **Appearance** - Theme toggle (Light/Dark)
5. **Reset to Defaults** button

**Data Flow:**
- **Reads:** `dietaryProfileProvider`, `themeNotifierProvider`
- **Writes:** `dietaryProfileProvider`, `themeNotifierProvider`

---

### CameraScreen (Modal)
**Location:** `lib/features/camera/presentation/screens/camera_screen.dart`

**Purpose:** Capture photos and detect ingredients using AI

**Dual Context Mode:**
```dart
enum CameraMode {
  quickScan,  // From HomeScreen
  pantryAdd,  // From MyPantryScreen
}
```

**Flow:**
1. User takes photo or selects from gallery
2. Shows preview screen
3. On confirm, processes image:
   - Preprocesses image using `ImageProcessor`
   - Calls `GeminiAIService.detectIngredients()`
   - Returns `List<String>` of detected ingredients
4. Caller (HomeScreen or MyPantryScreen) receives the list

**Data Flow:**
- **Reads:** None
- **Writes:** None (returns data to caller)

---

### RecipeDetailScreen
**Location:** `lib/features/recipe_detail/presentation/screens/recipe_detail_screen.dart`

**Purpose:** Show full recipe details

**Features:**
- Recipe title and description
- Prep time, cook time, difficulty
- Tags
- Full ingredients list with checkmarks
- Numbered step-by-step instructions
- Favorite toggle button (top-right)

**Data Flow:**
- **Reads:** `favoriteRecipesProvider` (to check if favorited)
- **Writes:** `favoriteRecipesProvider` (toggle favorite)

---

## Complete User Flows

### Flow 1: Quick Scan → Recipe Search
1. User opens app → **HomeScreen** (Tab 1)
2. Taps "Scan Ingredients"
3. **CameraScreen** (quickScan mode) opens
4. Takes photo → AI detects `['chicken', 'broccoli']`
5. CameraScreen closes, returns ingredients to HomeScreen
6. HomeScreen writes `['chicken', 'broccoli']` to `sessionIngredientsProvider`
7. HomeScreen calls `switchToRecipeTab()`
8. **RecipeResultsScreen** (Tab 3) appears
9. Reads `sessionIngredientsProvider`
10. Generates 3 recipes for chicken & broccoli
11. User taps a recipe → **RecipeDetailScreen** opens
12. User taps favorite button → Added to `favoriteRecipesProvider`

### Flow 2: Quick Manual + Save to Pantry
1. User opens app → **HomeScreen**
2. Taps "Enter Manually"
3. **QuickManualInputSheet** modal opens
4. User types "Onions", "Beef", "Carrots"
5. User taps **"Save to Pantry"**
6. Modal writes `['Onions', 'Beef', 'Carrots']` to `pantryIngredientsProvider`
7. Shows "Saved!" message
8. Modal clears its local list
9. **Modal stays open**
10. User re-adds "Onions", "Beef" (not carrots)
11. User taps **"Find Recipes"**
12. Modal writes `['Onions', 'Beef']` to `sessionIngredientsProvider`
13. Modal closes
14. Calls `switchToRecipeTab()`
15. **RecipeResultsScreen** appears with onion & beef recipes
16. **MyPantryScreen** (in background) now shows all 3 ingredients

### Flow 3: Pantry Management → Browse Recipes
1. User taps **MyPantryScreen** (Tab 2)
2. Taps "Scan to Add"
3. **CameraScreen** (pantryAdd mode) opens
4. Scans and detects `['Flour', 'Sugar']`
5. Returns to MyPantryScreen
6. MyPantryScreen writes to `pantryIngredientsProvider`
7. List updates immediately
8. User taps **RecipeResultsScreen** (Tab 3)
9. RecipeResultsScreen checks:
   - `sessionIngredients` is empty
   - Falls back to `pantryIngredients`
10. Shows recipes using ALL pantry items (including Flour & Sugar)

## Technology Stack

### State Management
- **Riverpod** - For global state and dependency injection
- **StateNotifier** - For complex state logic
- **Hive** - For local persistence

### AI/Backend
- **Firebase Core** - App initialization
- **Firebase AI (Gemini API)** - Cloud-based recipe generation and ingredient detection
- **GeminiAIService** - Wrapper service for AI operations

### Camera & Images
- **camera** - Camera capture
- **image_picker** - Gallery selection
- **image** - Image preprocessing

### UI
- **Material 3** - Modern Material Design
- **NavigationBar** - Bottom navigation
- **ModalBottomSheet** - Modal dialogs

## Data Models

### Recipe
```dart
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int prepTime;
  final int cookTime;
  final String difficulty;
  final List<String> tags;
  final DateTime createdAt;
}
```

### DietaryProfile
```dart
class DietaryProfile {
  final List<String> restrictions;  // ['vegetarian', 'gluten-free']
  final String skillLevel;          // 'beginner', 'intermediate', 'advanced'
  final String? cuisinePreference;  // 'italian', 'asian', etc.
}
```

## Key Architecture Principles

1. **Separation of Concerns:**
   - Navigation logic in `AppShell`
   - Data logic in providers
   - UI logic in screens

2. **Single Source of Truth:**
   - All state lives in providers
   - Screens read/write to providers, not each other

3. **Persistent vs Temporary:**
   - `sessionIngredients` = temporary (quick searches)
   - `pantryIngredients` = persistent (long-term storage)

4. **Smart Fallbacks:**
   - RecipeResultsScreen uses session OR pantry ingredients
   - Graceful handling of empty states

5. **Context-Aware Components:**
   - CameraScreen adapts based on mode (quickScan vs pantryAdd)
   - QuickManualInputSheet has dual actions

## Next Steps for Development

1. **Firebase Authentication:**
   - Already set up, integrate with user profiles
   - Sync favorites to Firestore

2. **Enhanced AI:**
   - Image-based recipe suggestions
   - Nutrition information
   - Cooking tips

3. **Social Features:**
   - Share recipes
   - Recipe ratings
   - Community favorites

4. **Shopping List:**
   - Generate from recipe ingredients
   - Check against pantry
   - Integration with grocery stores

## Testing the App

**To run the app:**
```bash
flutter run
```

**Test Scenarios:**

1. **Quick Scan Flow:**
   - Home → Scan → Recipes → Detail → Favorite

2. **Manual Entry Flow:**
   - Home → Manual → Save to Pantry → Find Recipes

3. **Pantry Flow:**
   - My Pantry → Add → View in Recipes

4. **Profile Flow:**
   - Profile → Set restrictions → View filtered recipes

5. **Favorites Flow:**
   - Add favorites → View Favorites tab → Remove

---

**Implementation Complete!** ✓

All 12 tasks completed:
- ✓ Android SHA configured
- ✓ State management architecture
- ✓ AppShell navigation
- ✓ All 5 screens implemented
- ✓ QuickManualInputSheet modal
- ✓ Dual-context CameraScreen
- ✓ RecipeDetailScreen
- ✓ Complete navigation flows
