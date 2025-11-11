import 'package:flutter/material.dart';

/// Color palette for ingredient categories.
class IngredientCategoriesColors {
  static const vegetables = Color(0xFF4CAF50);
  static const proteins = Color(0xFFF44336);
  static const dairy = Color(0xFF2196F3);
  static const grains = Color(0xFFFF9800);
  static const herbs = Color(0xFF009688);
  static const fruits = Color(0xFF9C27B0);
  static const canned = Color(0xFF795548);
  static const condiments = Color(0xFFFFC107);
}

/// Keyword lists used for simple category detection.
class IngredientCategoriesLists {
  static const vegetables = [
    'tomato','onion','pepper','lettuce','carrot','broccoli','cucumber','spinach','potato'
  ];
  static const proteins = [
    'chicken','beef','pork','fish','salmon','tuna','egg','eggs','tofu','turkey','shrimp'
  ];
  static const dairy = [
    'milk','cheese','yogurt','butter','cream'
  ];
  static const grains = [
    'rice','pasta','bread','noodle','oats','quinoa','couscous','potato'
  ];
  static const herbs = [
    'basil','rosemary','thyme','parsley','cilantro','garlic','ginger','mint'
  ];
  static const fruits = [
    'apple','banana','berry','orange','grape','lemon','lime','mango','pear','peach'
  ];
  static const canned = [
    'canned','beans','tomatoes','peas','corn','sardine'
  ];
  static const condiments = [
    'oil','olive oil','soy','sauce','vinegar','ketchup','mustard','mayo','mayonnaise','salt','pepper'
  ];
}
