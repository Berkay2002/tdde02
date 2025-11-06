/// Recipe entity - Pure business logic model
/// 
/// This represents a recipe in the domain layer.
class Recipe {
  final String id;
  final String userId;
  final String recipeName;
  final String? description;
  final int? prepTime;
  final int? cookTime;
  final int? servings;
  final String? cuisineType;
  final String? difficultyLevel;
  final String? mealType;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String>? detectedIngredients;
  final List<String> dietaryTags;
  final List<String> allergens;
  final int? caloriesPerServing;
  final bool isFavorite;
  final int? rating;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Recipe({
    required this.id,
    required this.userId,
    required this.recipeName,
    this.description,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.cuisineType,
    this.difficultyLevel,
    this.mealType,
    required this.ingredients,
    required this.instructions,
    this.detectedIngredients,
    this.dietaryTags = const [],
    this.allergens = const [],
    this.caloriesPerServing,
    this.isFavorite = false,
    this.rating,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Recipe copyWith({
    String? id,
    String? userId,
    String? recipeName,
    String? description,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? cuisineType,
    String? difficultyLevel,
    String? mealType,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<String>? detectedIngredients,
    List<String>? dietaryTags,
    List<String>? allergens,
    int? caloriesPerServing,
    bool? isFavorite,
    int? rating,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipeName: recipeName ?? this.recipeName,
      description: description ?? this.description,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      cuisineType: cuisineType ?? this.cuisineType,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      mealType: mealType ?? this.mealType,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      allergens: allergens ?? this.allergens,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Total cooking time (prep + cook)
  int? get totalTime {
    if (prepTime == null || cookTime == null) return null;
    return prepTime! + cookTime!;
  }
}

/// Ingredient entity
class Ingredient {
  final String name;
  final String? quantity;
  final String? unit;
  final String? notes;

  const Ingredient({
    required this.name,
    this.quantity,
    this.unit,
    this.notes,
  });

  Ingredient copyWith({
    String? name,
    String? quantity,
    String? unit,
    String? notes,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
    );
  }
}
