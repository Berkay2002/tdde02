/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'AI Recipe Generator';
  static const String appVersion = '1.0.0';

  // AI Model Configuration - Firebase AI with Gemini API
  // Cloud-based AI, no local model downloads required
  static const String geminiModel = 'gemini-2.5-flash'; // Multimodal model
  static const int maxTokens = 2048; // Increased for better recipe generation
  static const int topK = 40;
  static const double temperature = 0.7; // Slightly lower for more consistent results

  // Image Processing
  static const int imageSize = 512; // 512x512 resolution for Gemma 3n
  static const int imageQuality = 85; // JPEG quality

  // Inference Timeouts
  static const Duration ingredientDetectionTimeout = Duration(seconds: 10);
  static const Duration recipeGenerationTimeout = Duration(seconds: 15);

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
