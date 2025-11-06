import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/recipe.dart';

part 'recipe_model.freezed.dart';
part 'recipe_model.g.dart';

/// Recipe model for data layer with JSON serialization
@freezed
class RecipeModel with _$RecipeModel {
  const RecipeModel._();

  const factory RecipeModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'recipe_name') required String recipeName,
    String? description,
    @JsonKey(name: 'prep_time') int? prepTime,
    @JsonKey(name: 'cook_time') int? cookTime,
    int? servings,
    @JsonKey(name: 'cuisine_type') String? cuisineType,
    @JsonKey(name: 'difficulty_level') String? difficultyLevel,
    @JsonKey(name: 'meal_type') String? mealType,
    required List<IngredientModel> ingredients,
    required List<String> instructions,
    @JsonKey(name: 'detected_ingredients') List<String>? detectedIngredients,
    @JsonKey(name: 'dietary_tags') @Default([]) List<String> dietaryTags,
    @Default([]) List<String> allergens,
    @JsonKey(name: 'calories_per_serving') int? caloriesPerServing,
    @JsonKey(name: 'is_favorite') @Default(false) bool isFavorite,
    int? rating,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _RecipeModel;

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);

  /// Convert model to domain entity
  Recipe toEntity() {
    return Recipe(
      id: id,
      userId: userId,
      recipeName: recipeName,
      description: description,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      cuisineType: cuisineType,
      difficultyLevel: difficultyLevel,
      mealType: mealType,
      ingredients: ingredients.map((i) => i.toEntity()).toList(),
      instructions: instructions,
      detectedIngredients: detectedIngredients,
      dietaryTags: dietaryTags,
      allergens: allergens,
      caloriesPerServing: caloriesPerServing,
      isFavorite: isFavorite,
      rating: rating,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from domain entity
  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      userId: entity.userId,
      recipeName: entity.recipeName,
      description: entity.description,
      prepTime: entity.prepTime,
      cookTime: entity.cookTime,
      servings: entity.servings,
      cuisineType: entity.cuisineType,
      difficultyLevel: entity.difficultyLevel,
      mealType: entity.mealType,
      ingredients: entity.ingredients
          .map((i) => IngredientModel.fromEntity(i))
          .toList(),
      instructions: entity.instructions,
      detectedIngredients: entity.detectedIngredients,
      dietaryTags: entity.dietaryTags,
      allergens: entity.allergens,
      caloriesPerServing: entity.caloriesPerServing,
      isFavorite: entity.isFavorite,
      rating: entity.rating,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Ingredient model for JSON serialization
@freezed
class IngredientModel with _$IngredientModel {
  const IngredientModel._();

  const factory IngredientModel({
    required String name,
    String? quantity,
    String? unit,
    String? notes,
  }) = _IngredientModel;

  factory IngredientModel.fromJson(Map<String, dynamic> json) =>
      _$IngredientModelFromJson(json);

  /// Convert model to domain entity
  Ingredient toEntity() {
    return Ingredient(name: name, quantity: quantity, unit: unit, notes: notes);
  }

  /// Create model from domain entity
  factory IngredientModel.fromEntity(Ingredient entity) {
    return IngredientModel(
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      notes: entity.notes,
    );
  }
}
