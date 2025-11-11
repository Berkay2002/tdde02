import 'package:flutter/material.dart';
import '../../../../core/constants/ingredient_categories.dart';

/// Categories for pantry ingredients.
enum IngredientCategory {
  vegetables,
  proteins,
  dairy,
  grains,
  herbs,
  fruits,
  canned,
  condiments,
  unknown,
}

class IngredientCategoryHelper {
  static IconData getIcon(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.vegetables:
        return Icons.eco;
      case IngredientCategory.proteins:
        return Icons.set_meal;
      case IngredientCategory.dairy:
        return Icons.icecream;
      case IngredientCategory.grains:
        return Icons.rice_bowl;
      case IngredientCategory.herbs:
        return Icons.spa;
      case IngredientCategory.fruits:
        return Icons.apple;
      case IngredientCategory.canned:
        return Icons.inventory_2;
      case IngredientCategory.condiments:
        return Icons.oil_barrel;
      case IngredientCategory.unknown:
        return Icons.category_outlined;
    }
  }

  static Color getColor(IngredientCategory category) {
    switch (category) {
      case IngredientCategory.vegetables:
        return IngredientCategoriesColors.vegetables;
      case IngredientCategory.proteins:
        return IngredientCategoriesColors.proteins;
      case IngredientCategory.dairy:
        return IngredientCategoriesColors.dairy;
      case IngredientCategory.grains:
        return IngredientCategoriesColors.grains;
      case IngredientCategory.herbs:
        return IngredientCategoriesColors.herbs;
      case IngredientCategory.fruits:
        return IngredientCategoriesColors.fruits;
      case IngredientCategory.canned:
        return IngredientCategoriesColors.canned;
      case IngredientCategory.condiments:
        return IngredientCategoriesColors.condiments;
      case IngredientCategory.unknown:
        return Colors.grey;
    }
  }

  /// Naive category detection based on keyword lookup.
  static IngredientCategory detectCategory(String name) {
    final lower = name.toLowerCase();
    bool matches(List<String> list) => list.any((e) => lower.contains(e));

    if (matches(IngredientCategoriesLists.vegetables)) return IngredientCategory.vegetables;
    if (matches(IngredientCategoriesLists.proteins)) return IngredientCategory.proteins;
    if (matches(IngredientCategoriesLists.dairy)) return IngredientCategory.dairy;
    if (matches(IngredientCategoriesLists.grains)) return IngredientCategory.grains;
    if (matches(IngredientCategoriesLists.herbs)) return IngredientCategory.herbs;
    if (matches(IngredientCategoriesLists.fruits)) return IngredientCategory.fruits;
    if (matches(IngredientCategoriesLists.canned)) return IngredientCategory.canned;
    if (matches(IngredientCategoriesLists.condiments)) return IngredientCategory.condiments;
    return IngredientCategory.unknown;
  }
}
