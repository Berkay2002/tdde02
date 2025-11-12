import 'package:flutter/material.dart';

enum RecipeCuisine {
  italian,
  asian,
  mexican,
  american,
  french,
  indian,
  mediterranean,
  healthy,
  dessert,
  onePot,
  other,
}

enum MealType { breakfast, lunch, dinner, snack, dessert, beverage }

enum RecipeDifficulty { easy, medium, hard }

class RecipeCategoryHelper {
  // Cuisine icons
  static IconData getCuisineIcon(RecipeCuisine cuisine) {
    switch (cuisine) {
      case RecipeCuisine.italian:
        return Icons.local_pizza;
      case RecipeCuisine.asian:
        return Icons.ramen_dining;
      case RecipeCuisine.mexican:
        return Icons.lunch_dining;
      case RecipeCuisine.american:
        return Icons.fastfood;
      case RecipeCuisine.french:
        return Icons.bakery_dining;
      case RecipeCuisine.indian:
        return Icons.restaurant;
      case RecipeCuisine.mediterranean:
        return Icons.set_meal;
      case RecipeCuisine.healthy:
        return Icons.spa;
      case RecipeCuisine.dessert:
        return Icons.cake;
      case RecipeCuisine.onePot:
        return Icons.soup_kitchen;
      case RecipeCuisine.other:
        return Icons.restaurant_menu;
    }
  }

  // Cuisine colors
  static Color getCuisineColor(RecipeCuisine cuisine) {
    switch (cuisine) {
      case RecipeCuisine.italian:
        return const Color(0xFFC62828);
      case RecipeCuisine.asian:
        return const Color(0xFFD32F2F);
      case RecipeCuisine.mexican:
        return const Color(0xFF388E3C);
      case RecipeCuisine.american:
        return const Color(0xFF1976D2);
      case RecipeCuisine.french:
        return const Color(0xFF303F9F);
      case RecipeCuisine.indian:
        return const Color(0xFFF57C00);
      case RecipeCuisine.mediterranean:
        return const Color(0xFF0277BD);
      case RecipeCuisine.healthy:
        return const Color(0xFF689F38);
      case RecipeCuisine.dessert:
        return const Color(0xFFE91E63);
      case RecipeCuisine.onePot:
        return const Color(0xFF5D4037);
      case RecipeCuisine.other:
        return const Color(0xFF757575);
    }
  }

  // Cuisine gradient colors
  static List<Color> getCuisineGradient(RecipeCuisine cuisine) {
    switch (cuisine) {
      case RecipeCuisine.italian:
        return [const Color(0xFFC62828), const Color(0xFFFF5722)];
      case RecipeCuisine.asian:
        return [const Color(0xFFD32F2F), const Color(0xFFFFEB3B)];
      case RecipeCuisine.mexican:
        return [const Color(0xFF388E3C), const Color(0xFFFF5252)];
      case RecipeCuisine.american:
        return [const Color(0xFF1976D2), const Color(0xFFE53935)];
      case RecipeCuisine.french:
        return [const Color(0xFF303F9F), const Color(0xFF9FA8DA)];
      case RecipeCuisine.indian:
        return [const Color(0xFFF57C00), const Color(0xFF66BB6A)];
      case RecipeCuisine.mediterranean:
        return [const Color(0xFF0277BD), const Color(0xFF81D4FA)];
      case RecipeCuisine.healthy:
        return [const Color(0xFF689F38), const Color(0xFFAED581)];
      case RecipeCuisine.dessert:
        return [const Color(0xFFE91E63), const Color(0xFFBA68C8)];
      case RecipeCuisine.onePot:
        return [const Color(0xFF5D4037), const Color(0xFFA1887F)];
      case RecipeCuisine.other:
        return [const Color(0xFF757575), const Color(0xFFBDBDBD)];
    }
  }

  // Detect cuisine from recipe name and tags
  static RecipeCuisine detectCuisine(String recipeName, List<String> tags) {
    final lowerName = recipeName.toLowerCase();
    final lowerTags = tags.map((t) => t.toLowerCase()).toList();
    final allText = '$lowerName ${lowerTags.join(' ')}';

    if (allText.contains('pasta') ||
        allText.contains('pizza') ||
        allText.contains('risotto') ||
        allText.contains('italian') ||
        allText.contains('parmesan') ||
        allText.contains('mozzarella') ||
        allText.contains('tuscan') ||
        allText.contains('marinara')) {
      return RecipeCuisine.italian;
    }

    if (allText.contains('asian') ||
        allText.contains('chinese') ||
        allText.contains('japanese') ||
        allText.contains('thai') ||
        allText.contains('korean') ||
        allText.contains('ramen') ||
        allText.contains('stir fry') ||
        allText.contains('sushi') ||
        allText.contains('teriyaki') ||
        allText.contains('wok')) {
      return RecipeCuisine.asian;
    }

    if (allText.contains('taco') ||
        allText.contains('burrito') ||
        allText.contains('enchilada') ||
        allText.contains('mexican') ||
        allText.contains('salsa') ||
        allText.contains('guacamole') ||
        allText.contains('fajita') ||
        allText.contains('quesadilla')) {
      return RecipeCuisine.mexican;
    }

    if (allText.contains('burger') ||
        allText.contains('bbq') ||
        allText.contains('american') ||
        allText.contains('hot dog') ||
        allText.contains('mac and cheese') ||
        allText.contains('fried chicken')) {
      return RecipeCuisine.american;
    }

    if (allText.contains('french') ||
        allText.contains('croissant') ||
        allText.contains('crepe') ||
        allText.contains('baguette') ||
        allText.contains('quiche') ||
        allText.contains('ratatouille')) {
      return RecipeCuisine.french;
    }

    if (allText.contains('curry') ||
        allText.contains('indian') ||
        allText.contains('tandoori') ||
        allText.contains('biryani') ||
        allText.contains('masala') ||
        allText.contains('naan') ||
        allText.contains('tikka')) {
      return RecipeCuisine.indian;
    }

    if (allText.contains('mediterranean') ||
        allText.contains('greek') ||
        allText.contains('hummus') ||
        allText.contains('falafel') ||
        allText.contains('gyro') ||
        allText.contains('shawarma')) {
      return RecipeCuisine.mediterranean;
    }

    if (allText.contains('salad') ||
        allText.contains('healthy') ||
        allText.contains('bowl') ||
        allText.contains('smoothie') ||
        allText.contains('grain') ||
        allText.contains('quinoa')) {
      return RecipeCuisine.healthy;
    }

    if (allText.contains('cake') ||
        allText.contains('cookie') ||
        allText.contains('brownie') ||
        allText.contains('pie') ||
        allText.contains('dessert') ||
        allText.contains('sweet') ||
        allText.contains('chocolate')) {
      return RecipeCuisine.dessert;
    }

    if (allText.contains('one pot') ||
        allText.contains('slow cooker') ||
        allText.contains('instant pot') ||
        allText.contains('casserole') ||
        allText.contains('dutch oven')) {
      return RecipeCuisine.onePot;
    }

    return RecipeCuisine.other;
  }

  // Meal type icons
  static IconData getMealTypeIcon(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return Icons.free_breakfast;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.fastfood;
      case MealType.dessert:
        return Icons.cake;
      case MealType.beverage:
        return Icons.local_cafe;
    }
  }

  // Meal type colors
  static Color getMealTypeColor(MealType mealType) {
    switch (mealType) {
      case MealType.breakfast:
        return const Color(0xFFFFA726);
      case MealType.lunch:
        return const Color(0xFF66BB6A);
      case MealType.dinner:
        return const Color(0xFF42A5F5);
      case MealType.snack:
        return const Color(0xFFFFEE58);
      case MealType.dessert:
        return const Color(0xFFEC407A);
      case MealType.beverage:
        return const Color(0xFF8D6E63);
    }
  }

  // Difficulty colors
  static Color getDifficultyColor(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return const Color(0xFF4CAF50);
      case RecipeDifficulty.medium:
        return const Color(0xFFFF9800);
      case RecipeDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }

  // Difficulty icon
  static IconData getDifficultyIcon(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return Icons.sentiment_satisfied;
      case RecipeDifficulty.medium:
        return Icons.sentiment_neutral;
      case RecipeDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  // Parse difficulty from string
  static RecipeDifficulty parseDifficulty(String difficulty) {
    final lower = difficulty.toLowerCase();
    if (lower.contains('easy') || lower.contains('beginner')) {
      return RecipeDifficulty.easy;
    } else if (lower.contains('hard') ||
        lower.contains('advanced') ||
        lower.contains('difficult')) {
      return RecipeDifficulty.hard;
    }
    return RecipeDifficulty.medium;
  }

  // Get cuisine display name
  static String getCuisineName(RecipeCuisine cuisine) {
    switch (cuisine) {
      case RecipeCuisine.italian:
        return 'Italian';
      case RecipeCuisine.asian:
        return 'Asian';
      case RecipeCuisine.mexican:
        return 'Mexican';
      case RecipeCuisine.american:
        return 'American';
      case RecipeCuisine.french:
        return 'French';
      case RecipeCuisine.indian:
        return 'Indian';
      case RecipeCuisine.mediterranean:
        return 'Mediterranean';
      case RecipeCuisine.healthy:
        return 'Healthy';
      case RecipeCuisine.dessert:
        return 'Dessert';
      case RecipeCuisine.onePot:
        return 'One-Pot';
      case RecipeCuisine.other:
        return 'Other';
    }
  }

  // Get difficulty display name
  static String getDifficultyName(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return 'Easy';
      case RecipeDifficulty.medium:
        return 'Medium';
      case RecipeDifficulty.hard:
        return 'Hard';
    }
  }
}
