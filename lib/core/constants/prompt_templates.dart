/// Prompt templates for AI inference
class PromptTemplates {
  /// System prompt for ingredient detection from fridge images
  static const String ingredientDetectionSystem = '''
Analyze the image and identify all visible food items and ingredients.

Rules:
- Be specific (e.g., "red bell pepper" not "vegetable")
- Only list actual ingredients suitable for cooking
- Ignore containers, utensils, or non-food items
- Output ONLY the ingredient names, one per line
- Do NOT include explanatory text, headers, or conclusions
- Do NOT start with phrases like "Here are" or "I can see"
- Each line should be a single ingredient name

Example output:
Chicken breast
Red bell pepper
Onion
Garlic
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
    print('=== RAW RECIPE RESPONSE ===');
    print(response);
    print('=========================');

    final lines = response.split('\n');
    final result = <String, dynamic>{};
    final ingredients = <String>[];
    final instructions = <String>[];

    String? currentSection;

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Strip markdown formatting from line for parsing
      final cleanLine = _stripMarkdown(trimmed);

      if (cleanLine.startsWith('Recipe Name:') ||
          (trimmed.startsWith('**') && !result.containsKey('name'))) {
        // Handle both "Recipe Name: X" and "**Recipe Name**" formats
        String name = cleanLine
            .replaceFirst('Recipe Name:', '')
            .replaceFirst(RegExp(r'^\*\*|\*\*$'), '')
            .trim();
        result['name'] = name;
        print('Parsed name: $name');
      } else if (cleanLine.startsWith('Description:')) {
        result['description'] = cleanLine
            .replaceFirst('Description:', '')
            .trim();
      } else if (cleanLine.startsWith('Prep Time:')) {
        final timeStr = cleanLine.replaceFirst('Prep Time:', '').trim();
        result['prepTime'] = _extractMinutes(timeStr);
      } else if (cleanLine.startsWith('Cook Time:')) {
        final timeStr = cleanLine.replaceFirst('Cook Time:', '').trim();
        result['cookTime'] = _extractMinutes(timeStr);
      } else if (cleanLine.startsWith('Servings:')) {
        final servingsStr = cleanLine.replaceFirst('Servings:', '').trim();
        result['servings'] = int.tryParse(servingsStr.split(' ').first) ?? 4;
      } else if (cleanLine.toLowerCase().contains('ingredient')) {
        currentSection = 'ingredients';
        print('Switched to ingredients section');
      } else if (cleanLine.toLowerCase().contains('instruction')) {
        currentSection = 'instructions';
        print(
          'Switched to instructions section. Found ${ingredients.length} ingredients.',
        );
      } else if (cleanLine.startsWith('Tips:')) {
        result['tips'] = cleanLine.replaceFirst('Tips:', '').trim();
        currentSection = null;
      } else if (currentSection == 'ingredients') {
        // Handle various ingredient formats
        String? ingredient;

        if (trimmed.startsWith('-') ||
            trimmed.startsWith('*') ||
            trimmed.startsWith('•')) {
          ingredient = trimmed.replaceFirst(RegExp(r'^[-*•]\s*'), '').trim();
        } else if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          ingredient = trimmed.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        } else if (trimmed.isNotEmpty && !trimmed.endsWith(':')) {
          // Plain text line in ingredients section
          ingredient = trimmed;
        }

        if (ingredient != null &&
            ingredient.isNotEmpty &&
            ingredient.length < 200) {
          ingredients.add(_stripMarkdown(ingredient));
          print('Added ingredient: $ingredient');
        }
      } else if (currentSection == 'instructions' &&
          RegExp(r'^\d+\.').hasMatch(trimmed)) {
        final instruction = trimmed
            .replaceFirst(RegExp(r'^\d+\.\s*'), '')
            .trim();
        instructions.add(instruction);
        print(
          'Added instruction ${instructions.length}: ${instruction.substring(0, instruction.length > 50 ? 50 : instruction.length)}...',
        );
      }
    }

    result['ingredients'] = ingredients;
    result['instructions'] = instructions;

    print(
      'Final parsed: ${ingredients.length} ingredients, ${instructions.length} instructions',
    );

    return result;
  }

  /// Strip markdown formatting from text
  static String _stripMarkdown(String text) {
    return text
        .replaceAllMapped(RegExp(r'\*\*(.+?)\*\*'), (m) => m.group(1)!) // Bold
        .replaceAllMapped(RegExp(r'\*(.+?)\*'), (m) => m.group(1)!) // Italic
        .replaceAllMapped(RegExp(r'__(.+?)__'), (m) => m.group(1)!) // Bold alt
        .replaceAllMapped(RegExp(r'_(.+?)_'), (m) => m.group(1)!) // Italic alt
        .replaceAllMapped(RegExp(r'`(.+?)`'), (m) => m.group(1)!) // Code
        .trim();
  }

  /// Parse ingredient list from AI response
  static List<String> parseIngredientResponse(String response) {
    final lines = response.split('\n');
    final ingredients = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip common preamble/conclusion phrases
      final lowerLine = trimmed.toLowerCase();
      if (lowerLine.contains('here are') ||
          lowerLine.contains('visible food') ||
          lowerLine.contains('i can see') ||
          lowerLine.contains('i found') ||
          lowerLine.contains('ingredients:') ||
          lowerLine.contains('items:') ||
          lowerLine.endsWith(':')) {
        continue;
      }

      // Remove bullet points and numbering
      var ingredient = trimmed
          .replaceFirst(RegExp(r'^[-*•]\s*'), '')
          .replaceFirst(RegExp(r'^\d+\.\s*'), '')
          .trim();

      // Only add if it looks like an actual ingredient (not too long, not empty)
      if (ingredient.isNotEmpty && ingredient.length < 100) {
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
