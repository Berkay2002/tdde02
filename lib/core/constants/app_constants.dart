/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Snapgredient';
  static const String appVersion = '1.0.0';

  // AI Model Configuration - Firebase AI with Gemini API
  static const String geminiModel = 'gemini-3-pro-preview'; // Multimodal model
  static const int maxTokens = 8196; // Increased to prevent truncation
  static const int topK = 40;
  static const double temperature = 1.0; // Recommended for Gemini 3 Pro Preview

  // Image Processing
  static const int imageSize = 512; // 512x512 resolution for Gemma 3n
  static const int imageQuality = 85; // JPEG quality

  // Inference Timeouts
  static const Duration ingredientDetectionTimeout = Duration(seconds: 30);
  static const Duration recipeGenerationTimeout = Duration(seconds: 45);

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

  // Rate Limiting (Production - Meal-based windows)
  // 5-hour windows align with natural meal prep cycles (breakfast → lunch → dinner)
  // This encourages spread usage throughout the day rather than bursts
  static const int rateLimitWindowHours = 5; // Reset every 5 hours
  static const int maxRecipeGenerationsPerWindow =
      5; // 5 recipes per 5-hour window
  static const int maxRecipeGenerationsPerDay =
      15; // ~3 meals × 5 recipe options
  static const int maxIngredientDetectionsPerWindow =
      8; // Allows retries/multiple items
  static const int maxIngredientDetectionsPerDay = 25;
  // With 5 recipes per window, users can explore options for each meal
  // Daily cap of 15 prevents abuse while being generous for genuine use
  // Gemini API free tier: 15 RPM, 1,500 RPD - these limits stay well under

  // Chat Rate Limits (Ask Chef chatbot)
  static const int maxChatMessagesPerWindow =
      20; // 20 messages per 5-hour window
  static const int maxChatMessagesPerDay = 50; // 50 messages per day

  // Pro User Rate Limits (Beta testers & approved users)
  // Very generous limits for trusted users who filled in the form
  static const int proMaxRecipeGenerationsPerWindow = 50;
  static const int proMaxRecipeGenerationsPerDay = 200;
  static const int proMaxIngredientDetectionsPerWindow = 100;
  static const int proMaxIngredientDetectionsPerDay = 300;
  static const int proMaxChatMessagesPerWindow = 200;
  static const int proMaxChatMessagesPerDay = 500;

  // Pro Users List (manually managed - add beta testers here)
  // These users get pro limits. Add emails in lowercase.
  static const List<String> proUserEmails = [
    // App owner/developer
    'berkayorhan@hotmail.se',
    // Beta testers - add emails here after form submission
    // 'tester1@example.com',
    // 'tester2@example.com',
  ];

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
