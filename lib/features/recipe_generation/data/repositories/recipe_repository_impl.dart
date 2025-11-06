import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Supabase implementation of RecipeRepository
class RecipeRepositoryImpl implements RecipeRepository {
  final SupabaseClient _supabase;

  RecipeRepositoryImpl(this._supabase);

  @override
  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecipeModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user recipes: $e');
    }
  }

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('id', recipeId)
          .single();

      return RecipeModel.fromJson(response).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RecipeModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite recipes: $e');
    }
  }

  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);

      // Convert ingredients to JSONB format
      final ingredientsJson = model.ingredients
          .map(
            (i) => {
              'name': i.name,
              'quantity': i.quantity,
              'unit': i.unit,
              'notes': i.notes,
            },
          )
          .toList();

      final data = {
        'user_id': recipe.userId,
        'recipe_name': recipe.recipeName,
        'description': recipe.description,
        'prep_time': recipe.prepTime,
        'cook_time': recipe.cookTime,
        'servings': recipe.servings,
        'cuisine_type': recipe.cuisineType,
        'difficulty_level': recipe.difficultyLevel,
        'meal_type': recipe.mealType,
        'ingredients': ingredientsJson,
        'instructions': recipe.instructions,
        'detected_ingredients': recipe.detectedIngredients,
        'dietary_tags': recipe.dietaryTags,
        'allergens': recipe.allergens,
        'calories_per_serving': recipe.caloriesPerServing,
        'is_favorite': recipe.isFavorite,
        'rating': recipe.rating,
        'notes': recipe.notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('recipes')
          .insert(data)
          .select()
          .single();

      return RecipeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  @override
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);

      // Convert ingredients to JSONB format
      final ingredientsJson = model.ingredients
          .map(
            (i) => {
              'name': i.name,
              'quantity': i.quantity,
              'unit': i.unit,
              'notes': i.notes,
            },
          )
          .toList();

      final data = {
        'recipe_name': recipe.recipeName,
        'description': recipe.description,
        'prep_time': recipe.prepTime,
        'cook_time': recipe.cookTime,
        'servings': recipe.servings,
        'cuisine_type': recipe.cuisineType,
        'difficulty_level': recipe.difficultyLevel,
        'meal_type': recipe.mealType,
        'ingredients': ingredientsJson,
        'instructions': recipe.instructions,
        'detected_ingredients': recipe.detectedIngredients,
        'dietary_tags': recipe.dietaryTags,
        'allergens': recipe.allergens,
        'calories_per_serving': recipe.caloriesPerServing,
        'is_favorite': recipe.isFavorite,
        'rating': recipe.rating,
        'notes': recipe.notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('recipes')
          .update(data)
          .eq('id', recipe.id)
          .select()
          .single();

      return RecipeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _supabase.from('recipes').delete().eq('id', recipeId);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  @override
  Future<Recipe> toggleFavorite(String recipeId, bool isFavorite) async {
    try {
      final response = await _supabase
          .from('recipes')
          .update({
            'is_favorite': isFavorite,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recipeId)
          .select()
          .single();

      return RecipeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<Recipe> rateRecipe(String recipeId, int rating) async {
    try {
      if (rating < 1 || rating > 5) {
        throw Exception('Rating must be between 1 and 5');
      }

      final response = await _supabase
          .from('recipes')
          .update({
            'rating': rating,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', recipeId)
          .select()
          .single();

      return RecipeModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to rate recipe: $e');
    }
  }
}
