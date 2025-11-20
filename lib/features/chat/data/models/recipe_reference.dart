/// Reference to a recipe in chat context (for @recipe mentions)
class RecipeReference {
  final String id;
  final String name;
  final String? description;
  final List<String>? ingredients;
  final int? prepTime;
  final int? cookTime;
  final String? difficulty;

  const RecipeReference({
    required this.id,
    required this.name,
    this.description,
    this.ingredients,
    this.prepTime,
    this.cookTime,
    this.difficulty,
  });

  /// Create from full recipe model
  factory RecipeReference.fromRecipe(Map<String, dynamic> recipe) {
    return RecipeReference(
      id: recipe['id'] as String,
      name: recipe['name'] as String,
      description: recipe['description'] as String?,
      ingredients: (recipe['ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      prepTime: recipe['prepTime'] as int?,
      cookTime: recipe['cookTime'] as int?,
      difficulty: recipe['difficulty'] as String?,
    );
  }

  /// Convert to JSON for API context
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'difficulty': difficulty,
    };
  }

  /// Create from JSON
  factory RecipeReference.fromJson(Map<String, dynamic> json) {
    return RecipeReference(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      prepTime: json['prepTime'] as int?,
      cookTime: json['cookTime'] as int?,
      difficulty: json['difficulty'] as String?,
    );
  }

  /// Get a concise summary for context (to avoid token bloat)
  String toContextString() {
    final buffer = StringBuffer();
    buffer.writeln('Recipe: $name');
    if (description != null) {
      buffer.writeln('Description: $description');
    }
    if (ingredients != null && ingredients!.isNotEmpty) {
      buffer.writeln(
        'Ingredients: ${ingredients!.take(10).join(", ")}${ingredients!.length > 10 ? "..." : ""}',
      );
    }
    if (prepTime != null || cookTime != null) {
      final total = (prepTime ?? 0) + (cookTime ?? 0);
      buffer.writeln('Total Time: $total minutes');
    }
    if (difficulty != null) {
      buffer.writeln('Difficulty: $difficulty');
    }
    return buffer.toString();
  }

  @override
  String toString() {
    return 'RecipeReference(id: $id, name: $name)';
  }
}
