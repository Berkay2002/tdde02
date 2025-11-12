/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'AI Recipe Generator';
  static const String appVersion = '1.0.0';

  // AI Model Configuration - Firebase AI with Gemini API
  static const String geminiModel = 'gemini-2.5-flash'; // Multimodal model
  static const int maxTokens = 8196; // Increased to prevent truncation
  static const int topK = 40;
  static const double temperature =
      0.7; // Slightly lower for more consistent results

  // Image Processing
  static const int imageSize = 512; // 512x512 resolution for Gemma 3n
  static const int imageQuality = 85; // JPEG quality

  // Inference Timeouts
  static const Duration ingredientDetectionTimeout = Duration(seconds: 15);
  static const Duration recipeGenerationTimeout = Duration(seconds: 30);

  // Retry Configuration
  static const int maxRetries = 2;
  static const Duration initialRetryDelay = Duration(seconds: 2);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Settings
  static const int maxCachedRecipes = 50;
  static const String hiveRecipeBox = 'recipes_box';
  static const String hivePreferencesBox = 'preferences_box';
  static const int cacheTtlDays = 7; // Recipe cache time-to-live

  // Rate Limiting (Beta - Generous limits for select testers)
  // These limits prevent abuse while allowing genuine exploration
  static const int maxRecipeGenerationsPerHour = 20; // ~1 every 3 minutes
  static const int maxRecipeGenerationsPerDay = 100; // ~4 per hour sustained
  static const int maxIngredientDetectionsPerHour =
      30; // Higher for camera retries
  static const int maxIngredientDetectionsPerDay = 150;
  // Gemini API free tier: 15 RPM, 1,500 RPD
  // With ~50 beta users: 100 recipes/day/user = 5,000 potential (over limit)
  // Caching reduces actual API calls by ~30%, so 3,500 calls
  // This is manageable with staggered usage patterns

  // Dietary Restrictions
  static const List<String> dietaryRestrictions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Kosher',
  ];

  // Skill Levels
  static const List<String> skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  // Firestore Collections
  static const String profilesCollection = 'profiles';
  static const String userPreferencesCollection = 'user_preferences';
  static const String recipesCollection = 'recipes';
  static const String recipeCacheCollection = 'recipe_cache';
  static const String userUsageCollection =
      'user_usage'; // Rate limiting tracking

  // Cuisine Types
  static const List<String> cuisineTypes = [
    'Italian',
    'Chinese',
    'Mexican',
    'Indian',
    'Japanese',
    'Thai',
    'French',
    'Mediterranean',
    'American',
    'Korean',
  ];
}
