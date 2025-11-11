import '../entities/recipe.dart';

/// Abstract recipe repository interface
abstract class RecipeRepository {
  /// Get all recipes for a user
  Future<List<Recipe>> getUserRecipes(String userId);

  /// Get a single recipe by ID
  Future<Recipe?> getRecipeById(String recipeId);

  /// Get favorite recipes for a user
  Future<List<Recipe>> getFavoriteRecipes(String userId);

  /// Create a new recipe
  Future<Recipe> createRecipe(Recipe recipe);

  /// Update an existing recipe
  Future<Recipe> updateRecipe(Recipe recipe);

  /// Delete a recipe
  Future<void> deleteRecipe(String recipeId);

  /// Toggle favorite status
  Future<Recipe> toggleFavorite(String recipeId, bool isFavorite);

  /// Rate a recipe
  Future<Recipe> rateRecipe(String recipeId, int rating);

  /// Get cached generated recipes for ingredients
  Future<List<Map<String, dynamic>>?> getCachedRecipes(
    String userId,
    List<String> ingredients,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
  );

  /// Save generated recipes to cache
  Future<void> saveCachedRecipes(
    String userId,
    List<String> ingredients,
    List<Map<String, dynamic>> recipes,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
  );
}

