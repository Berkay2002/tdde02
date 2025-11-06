/// Prompt templates for AI inference
class PromptTemplates {
  /// System prompt for ingredient detection from fridge images
  static const String ingredientDetectionSystem = '''
You are an intelligent kitchen assistant. Analyze the provided image of a refrigerator or food storage area.

Task:
1. Identify all visible food items and ingredients
2. List them in a structured format
3. Be specific (e.g., "red bell pepper" not just "vegetable")

Output Format:
- Ingredient 1
- Ingredient 2
- Ingredient 3
...

Focus on ingredients suitable for cooking. Ignore containers, utensils, or non-food items.
''';

  /// Generate ingredient detection prompt with image context
  static String getIngredientDetectionPrompt() {
    return ingredientDetectionSystem;
  }

  /// System prompt for recipe generation
  static const String recipeGenerationSystem = '''
You are a professional chef assistant. Based on the available ingredients, create a delicious recipe.

Generate ONE complete recipe including:
1. Recipe Name (creative and appetizing)
2. Brief Description (2-3 sentences)
3. Prep Time and Cook Time (in minutes)
4. Servings
5. Full Ingredient List (with quantities)
6. Step-by-step Instructions (numbered)
7. Optional: Cooking tips or variations

Make the recipe practical and achievable for home cooks. Use simple language.
''';

  /// Generate recipe prompt with ingredients and preferences
  static String getRecipeGenerationPrompt({
    required List<String> ingredients,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(recipeGenerationSystem);
    buffer.writeln();
    buffer.writeln('Available Ingredients:');
    for (final ingredient in ingredients) {
      buffer.writeln('- $ingredient');
    }
    buffer.writeln();

    if (dietaryRestrictions != null && dietaryRestrictions.isNotEmpty) {
      buffer.writeln('Dietary Restrictions: $dietaryRestrictions');
    }

    if (skillLevel != null && skillLevel.isNotEmpty) {
      buffer.writeln('Skill Level: $skillLevel');
    }

    if (cuisinePreference != null && cuisinePreference.isNotEmpty) {
      buffer.writeln('Preferred Cuisine: $cuisinePreference');
    }

    buffer.writeln();
    buffer.writeln('Format your response as:');
    buffer.writeln('Recipe Name: [Name]');
    buffer.writeln('Description: [Description]');
    buffer.writeln('Prep Time: [X minutes]');
    buffer.writeln('Cook Time: [Y minutes]');
    buffer.writeln('Servings: [Z]');
    buffer.writeln();
    buffer.writeln('Ingredients:');
    buffer.writeln('- [Quantity] [Ingredient]');
    buffer.writeln('...');
    buffer.writeln();
    buffer.writeln('Instructions:');
    buffer.writeln('1. [Step 1]');
    buffer.writeln('2. [Step 2]');
    buffer.writeln('...');
    buffer.writeln();
    buffer.writeln('Tips: [Optional cooking tips]');

    return buffer.toString();
  }

  /// Parse recipe response from AI
  static Map<String, dynamic> parseRecipeResponse(String response) {
    final lines = response.split('\n');
    final result = <String, dynamic>{};
    final ingredients = <String>[];
    final instructions = <String>[];

    String? currentSection;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('Recipe Name:')) {
        result['name'] = trimmed.replaceFirst('Recipe Name:', '').trim();
      } else if (trimmed.startsWith('Description:')) {
        result['description'] = trimmed.replaceFirst('Description:', '').trim();
      } else if (trimmed.startsWith('Prep Time:')) {
        final timeStr = trimmed.replaceFirst('Prep Time:', '').trim();
        result['prepTime'] = _extractMinutes(timeStr);
      } else if (trimmed.startsWith('Cook Time:')) {
        final timeStr = trimmed.replaceFirst('Cook Time:', '').trim();
        result['cookTime'] = _extractMinutes(timeStr);
      } else if (trimmed.startsWith('Servings:')) {
        final servingsStr = trimmed.replaceFirst('Servings:', '').trim();
        result['servings'] = int.tryParse(servingsStr.split(' ').first) ?? 4;
      } else if (trimmed == 'Ingredients:') {
        currentSection = 'ingredients';
      } else if (trimmed == 'Instructions:') {
        currentSection = 'instructions';
      } else if (trimmed.startsWith('Tips:')) {
        result['tips'] = trimmed.replaceFirst('Tips:', '').trim();
        currentSection = null;
      } else if (currentSection == 'ingredients' && trimmed.startsWith('-')) {
        ingredients.add(trimmed.replaceFirst('-', '').trim());
      } else if (currentSection == 'instructions' &&
          RegExp(r'^\d+\.').hasMatch(trimmed)) {
        instructions.add(trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim());
      }
    }

    result['ingredients'] = ingredients;
    result['instructions'] = instructions;

    return result;
  }

  /// Parse ingredient list from AI response
  static List<String> parseIngredientResponse(String response) {
    final lines = response.split('\n');
    final ingredients = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Remove bullet points and numbering
      var ingredient = trimmed
          .replaceFirst(RegExp(r'^[-*•]\s*'), '')
          .replaceFirst(RegExp(r'^\d+\.\s*'), '')
          .trim();

      if (ingredient.isNotEmpty) {
        ingredients.add(ingredient);
      }
    }

    return ingredients;
  }

  /// Extract minutes from time string (e.g., "30 minutes" -> 30)
  static int _extractMinutes(String timeStr) {
    final match = RegExp(r'(\d+)').firstMatch(timeStr);
    return match != null ? int.parse(match.group(1)!) : 0;
  }
}
