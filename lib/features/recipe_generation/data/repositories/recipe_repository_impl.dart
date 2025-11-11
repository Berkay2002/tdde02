import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

/// Firestore implementation of RecipeRepository
class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseFirestore _firestore;

  RecipeRepositoryImpl(this._firestore);

  @override
  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user recipes: $e');
    }
  }

  @override
  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final doc = await _firestore
          .collection('recipes')
          .doc(recipeId)
          .get();

      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      return RecipeModel.fromJson(data).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('recipes')
          .where('user_id', isEqualTo: userId)
          .where('is_favorite', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RecipeModel.fromJson(doc.data()).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite recipes: $e');
    }
  }

  @override
  Future<Recipe> createRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);

      // Convert ingredients to map format
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

      final docRef = _firestore.collection('recipes').doc();
      
      final data = {
        'id': docRef.id,
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
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(data);

      final createdRecipe = await getRecipeById(docRef.id);
      if (createdRecipe == null) {
        throw Exception('Failed to retrieve created recipe');
      }

      return createdRecipe;
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  @override
  Future<Recipe> updateRecipe(Recipe recipe) async {
    try {
      final model = RecipeModel.fromEntity(recipe);

      // Convert ingredients to map format
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
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('recipes')
          .doc(recipe.id)
          .update(data);

      final updatedRecipe = await getRecipeById(recipe.id);
      if (updatedRecipe == null) {
        throw Exception('Failed to retrieve updated recipe');
      }

      return updatedRecipe;
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      await _firestore.collection('recipes').doc(recipeId).delete();
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  @override
  Future<Recipe> toggleFavorite(String recipeId, bool isFavorite) async {
    try {
      await _firestore
          .collection('recipes')
          .doc(recipeId)
          .update({
            'is_favorite': isFavorite,
            'updated_at': FieldValue.serverTimestamp(),
          });

      final recipe = await getRecipeById(recipeId);
      if (recipe == null) {
        throw Exception('Failed to retrieve updated recipe');
      }

      return recipe;
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

      await _firestore
          .collection('recipes')
          .doc(recipeId)
          .update({
            'rating': rating,
            'updated_at': FieldValue.serverTimestamp(),
          });

      final recipe = await getRecipeById(recipeId);
      if (recipe == null) {
        throw Exception('Failed to retrieve updated recipe');
      }

      return recipe;
    } catch (e) {
      throw Exception('Failed to rate recipe: $e');
    }
  }
}
