import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../features/pantry/domain/entities/pantry_item.dart';

/// Model for dietary profile/preferences
class DietaryProfile {
  final List<String> restrictions; // e.g., ['vegetarian', 'gluten-free']
  final String skillLevel; // 'beginner', 'intermediate', 'advanced'
  final String? cuisinePreference; // e.g., 'italian', 'asian', 'mexican'

  const DietaryProfile({
    this.restrictions = const [],
    this.skillLevel = 'beginner',
    this.cuisinePreference,
  });

  DietaryProfile copyWith({
    List<String>? restrictions,
    String? skillLevel,
    String? cuisinePreference,
  }) {
    return DietaryProfile(
      restrictions: restrictions ?? this.restrictions,
      skillLevel: skillLevel ?? this.skillLevel,
      cuisinePreference: cuisinePreference ?? this.cuisinePreference,
    );
  }

  Map<String, dynamic> toJson() => {
    'restrictions': restrictions,
    'skillLevel': skillLevel,
    'cuisinePreference': cuisinePreference,
  };

  factory DietaryProfile.fromJson(Map<String, dynamic> json) {
    return DietaryProfile(
      restrictions: (json['restrictions'] as List?)?.cast<String>() ?? [],
      skillLevel: json['skillLevel'] as String? ?? 'beginner',
      cuisinePreference: json['cuisinePreference'] as String?,
    );
  }
}

/// Model for a recipe (used in favorites and results)
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final String? imageUrl;
  final int prepTime; // in minutes
  final int cookTime; // in minutes
  final String difficulty;
  final List<String> tags;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    required this.prepTime,
    required this.cookTime,
    required this.difficulty,
    this.tags = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'ingredients': ingredients,
    'instructions': instructions,
    'imageUrl': imageUrl,
    'prepTime': prepTime,
    'cookTime': cookTime,
    'difficulty': difficulty,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List?)?.cast<String>() ?? [],
      instructions: (json['instructions'] as List?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      prepTime: json['prepTime'] as int? ?? 0,
      cookTime: json['cookTime'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'medium',
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// State notifier for session ingredients (quick search)
class SessionIngredientsNotifier extends StateNotifier<List<String>> {
  SessionIngredientsNotifier() : super([]);

  void setIngredients(List<String> ingredients) {
    state = List.from(ingredients);
  }

  void addIngredient(String ingredient) {
    if (!state.contains(ingredient)) {
      state = [...state, ingredient];
    }
  }

  void removeIngredient(String ingredient) {
    state = state.where((item) => item != ingredient).toList();
  }

  void clear() {
    state = [];
  }
}

/// State notifier for pantry ingredients (persistent)
class PantryIngredientsNotifier extends StateNotifier<List<PantryItem>> {
  final Box prefsBox;
  String _searchQuery = '';

  PantryIngredientsNotifier(this.prefsBox) : super(const []) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final stored = prefsBox.get('pantryIngredients', defaultValue: <dynamic>[]);
    final loaded = <PantryItem>[];
    for (final raw in stored as List) {
      if (raw is String) {
        loaded.add(PantryItem.fromLegacy(raw));
      } else if (raw is Map) {
        loaded.add(PantryItem.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    state = loaded;
  }

  void _saveToStorage() {
    final serialized = state.map((e) => e.toJson()).toList();
    prefsBox.put('pantryIngredients', serialized);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // Trigger rebuild by reassigning same list
    state = [...state];
  }

  String get searchQuery => _searchQuery;

  List<PantryItem> get filteredItems {
    if (_searchQuery.isEmpty) return state;
    final q = _searchQuery.toLowerCase();
    return state.where((e) => e.name.toLowerCase().contains(q)).toList();
  }

  void setIngredients(List<String> ingredients) {
    final converted = ingredients.map(PantryItem.fromLegacy).toList();
    state = converted;
    _saveToStorage();
  }

  void addIngredients(List<String> ingredients) {
    final newState = [...state];
    for (final ingredient in ingredients) {
      if (!newState.any(
        (e) => e.name.toLowerCase() == ingredient.toLowerCase(),
      )) {
        newState.add(PantryItem.fromLegacy(ingredient));
      }
    }
    state = newState;
    _saveToStorage();
  }

  void addIngredient(String ingredient) {
    if (!state.any((e) => e.name.toLowerCase() == ingredient.toLowerCase())) {
      state = [...state, PantryItem.fromLegacy(ingredient)];
      _saveToStorage();
    }
  }

  void removeIngredient(String ingredient) {
    state = state.where((item) => item.name != ingredient).toList();
    _saveToStorage();
  }

  void clear() {
    state = const [];
    _saveToStorage();
  }
}

/// State notifier for favorite recipes (persistent)
class FavoriteRecipesNotifier extends StateNotifier<List<Recipe>> {
  final Box recipeBox;

  FavoriteRecipesNotifier(this.recipeBox) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final stored = recipeBox.get('favoriteRecipes', defaultValue: []);
    state = (stored as List)
        .map((json) => Recipe.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  void _saveToStorage() {
    final jsonList = state.map((recipe) => recipe.toJson()).toList();
    recipeBox.put('favoriteRecipes', jsonList);
  }

  void addRecipe(Recipe recipe) {
    if (!state.any((r) => r.id == recipe.id)) {
      state = [...state, recipe];
      _saveToStorage();
    }
  }

  void removeRecipe(String recipeId) {
    state = state.where((recipe) => recipe.id != recipeId).toList();
    _saveToStorage();
  }

  bool isFavorite(String recipeId) {
    return state.any((recipe) => recipe.id == recipeId);
  }

  void toggleFavorite(Recipe recipe) {
    if (isFavorite(recipe.id)) {
      removeRecipe(recipe.id);
    } else {
      addRecipe(recipe);
    }
  }

  void clear() {
    state = [];
    _saveToStorage();
  }
}

/// State notifier for dietary profile (persistent)
class DietaryProfileNotifier extends StateNotifier<DietaryProfile> {
  final Box prefsBox;

  DietaryProfileNotifier(this.prefsBox) : super(const DietaryProfile()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final stored = prefsBox.get('dietaryProfile');
    if (stored != null) {
      state = DietaryProfile.fromJson(Map<String, dynamic>.from(stored));
    }
  }

  void _saveToStorage() {
    prefsBox.put('dietaryProfile', state.toJson());
  }

  void updateProfile(DietaryProfile profile) {
    state = profile;
    _saveToStorage();
  }

  void updateRestrictions(List<String> restrictions) {
    state = state.copyWith(restrictions: restrictions);
    _saveToStorage();
  }

  void updateSkillLevel(String skillLevel) {
    state = state.copyWith(skillLevel: skillLevel);
    _saveToStorage();
  }

  void updateCuisinePreference(String? preference) {
    state = state.copyWith(cuisinePreference: preference);
    _saveToStorage();
  }

  void reset() {
    state = const DietaryProfile();
    _saveToStorage();
  }
}

// ============================================================================
// Providers (The "Brain" - Global State Access Points)
// ============================================================================

/// Provider for session ingredients (temporary, for quick searches)
final sessionIngredientsProvider =
    StateNotifierProvider<SessionIngredientsNotifier, List<String>>((ref) {
      return SessionIngredientsNotifier();
    });

/// Provider for pantry ingredients (persistent)
final pantryIngredientsProvider =
    StateNotifierProvider<PantryIngredientsNotifier, List<PantryItem>>((ref) {
      final prefsBox = Hive.box(AppConstants.hivePreferencesBox);
      return PantryIngredientsNotifier(prefsBox);
    });

/// Provider for favorite recipes (persistent)
final favoriteRecipesProvider =
    StateNotifierProvider<FavoriteRecipesNotifier, List<Recipe>>((ref) {
      final recipeBox = Hive.box(AppConstants.hiveRecipeBox);
      return FavoriteRecipesNotifier(recipeBox);
    });

/// Provider for dietary profile (persistent)
final dietaryProfileProvider =
    StateNotifierProvider<DietaryProfileNotifier, DietaryProfile>((ref) {
      final prefsBox = Hive.box(AppConstants.hivePreferencesBox);
      return DietaryProfileNotifier(prefsBox);
    });
