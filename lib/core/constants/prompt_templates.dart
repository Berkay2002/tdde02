import 'dart:convert';

/// Prompt templates for AI inference
class PromptTemplates {
  /// System prompt for ingredient detection from fridge images
  static const String ingredientDetectionSystem = '''
Analyze the image and identify all visible food items and ingredients.

Output a JSON array where each ingredient is an object with:
- "name": specific ingredient name (e.g., "red bell pepper" not "vegetable")
- "quantity": estimated quantity if visible (e.g., "2", "1", "500g") or null
- "unit": unit of measurement if applicable (e.g., "pieces", "g", "ml", "kg") or null
- "quantityConfidence": confidence in quantity estimate [high, medium, low, none]
  * high: you can clearly count/see exact amount
  * medium: you can estimate approximate amount but not exact
  * low: quantity is partially obscured or very uncertain
  * none: no quantity information available
- "category": one of [vegetables, fruits, proteins, dairy, grains, herbs, canned, condiments, unknown]
- "freshness": estimated freshness [fresh, good, questionable] based on appearance

Quantity Confidence Guidelines:
- Only provide quantity with "high" confidence if you can clearly see and count items
- Use "medium" confidence for reasonable estimates (e.g., can see most of the items)
- Use "low" confidence when items are stacked, in bags, or partially visible
- Use "none" if no quantity can be estimated at all

Rules:
- Only list actual ingredients suitable for cooking
- Ignore containers, utensils, or non-food items
- Be specific with ingredient names
- DO NOT guess quantities - be honest about confidence level
- Use singular form for ingredient names (e.g., "tomato" not "tomatoes")

Example output:
```json
[
  {"name": "chicken breast", "quantity": "2", "unit": "pieces", "quantityConfidence": "high", "category": "proteins", "freshness": "fresh"},
  {"name": "red bell pepper", "quantity": "3", "unit": "pieces", "quantityConfidence": "medium", "category": "vegetables", "freshness": "fresh"},
  {"name": "onion", "quantity": "5", "unit": "pieces", "quantityConfidence": "low", "category": "vegetables", "freshness": "good"},
  {"name": "garlic", "quantity": null, "unit": null, "quantityConfidence": "none", "category": "herbs", "freshness": "fresh"}
]
```

Output only the JSON array, no additional text.
''';

  /// Generate ingredient detection prompt with image context
  static String getIngredientDetectionPrompt() {
    return ingredientDetectionSystem;
  }

  /// System prompt for recipe generation
  static const String recipeGenerationSystem = '''
You are a professional chef assistant. Create a delicious recipe based on the available ingredients.

Output a complete recipe as a JSON object with this exact structure:
{
  "name": "Recipe name (creative and appetizing)",
  "description": "Brief description (2-3 sentences)",
  "prepTime": 15,  // prep time in minutes
  "cookTime": 30,  // cook time in minutes
  "servings": 4,
  "cuisineType": "Italian/Asian/Mexican/etc or null",
  "difficultyLevel": "beginner/intermediate/advanced",
  "mealType": "breakfast/lunch/dinner/snack/dessert or null",
  "ingredients": [
    {"name": "ingredient name", "quantity": "2", "unit": "cups", "notes": "optional preparation notes"},
    {"name": "ingredient name", "quantity": "1", "unit": "tablespoon", "notes": null}
  ],
  "instructions": [
    "Step 1 description",
    "Step 2 description"
  ],
  "dietaryTags": ["vegetarian", "gluten-free", etc],
  "allergens": ["dairy", "nuts", "gluten", etc],
  "caloriesPerServing": 350,  // estimated calories or null
  "tips": "Optional cooking tips and variations"
}

Make recipes practical for home cooks. Use clear, simple language.
''';

  /// Generate recipe prompt with ingredients and preferences
  static String getRecipeGenerationPrompt({
    required List<String> ingredients,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
    String measurementSystem = 'metric',
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
      buffer.writeln('Include these in the dietaryTags field.');
    }

    if (skillLevel != null && skillLevel.isNotEmpty) {
      buffer.writeln('Skill Level: $skillLevel');
      buffer.writeln('Set difficultyLevel appropriately.');
    }

    if (cuisinePreference != null && cuisinePreference.isNotEmpty) {
      buffer.writeln('Preferred Cuisine: $cuisinePreference');
      buffer.writeln('Set cuisineType field if applicable.');
    }

    buffer.writeln();
    buffer.writeln('Measurement System: $measurementSystem');
    buffer.writeln(
      'Use ${measurementSystem == "metric" ? "grams, ml, liters" : "cups, tablespoons, ounces"} for quantities.',
    );
    buffer.writeln();
    buffer.writeln(
      'Output only the JSON object, no additional text before or after.',
    );

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

  /// Parse ingredient list from AI JSON response
  static List<Map<String, dynamic>> parseIngredientResponseStructured(
    String response,
  ) {
    try {
      // Extract JSON from response (may be wrapped in markdown code blocks)
      final jsonStr = _extractJson(response);

      final dynamic parsed = jsonDecode(jsonStr);

      if (parsed is List) {
        return parsed.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return <String, dynamic>{};
        }).toList();
      }

      print('Expected JSON array, got: ${parsed.runtimeType}');
      return [];
    } catch (e) {
      print('Failed to parse structured ingredient response: $e');
      print('Response was: $response');
      // Fallback to simple list
      return [];
    }
  }

  /// Parse ingredient list from AI response (legacy text format)
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

  /// Extract JSON from response (handles markdown code blocks)
  static String _extractJson(String response) {
    // Try to find JSON within markdown code blocks
    final codeBlockMatch = RegExp(
      r'```(?:json)?\s*(\{[\s\S]*?\}|\[[\s\S]*?\])\s*```',
      multiLine: true,
    ).firstMatch(response);

    if (codeBlockMatch != null) {
      return codeBlockMatch.group(1)!.trim();
    }

    // Try to find raw JSON object or array
    final jsonMatch = RegExp(
      r'(\{[\s\S]*\}|\[[\s\S]*\])',
      multiLine: true,
    ).firstMatch(response.trim());

    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }

    return response.trim();
  }

  /// Parse recipe response from AI JSON
  static Map<String, dynamic> parseRecipeResponseStructured(String response) {
    try {
      print('=== RAW RECIPE RESPONSE ===');
      print(response);
      print('=========================');

      final jsonStr = _extractJson(response);
      final dynamic parsed = jsonDecode(jsonStr);

      if (parsed is! Map<String, dynamic>) {
        print('Expected JSON object, got: ${parsed.runtimeType}');
        return _fallbackParseRecipe(response);
      }

      // Normalize the structure
      final result = <String, dynamic>{
        'name': parsed['name'] ?? 'Untitled Recipe',
        'description': parsed['description'] ?? '',
        'prepTime': parsed['prepTime'] ?? 0,
        'cookTime': parsed['cookTime'] ?? 0,
        'servings': parsed['servings'] ?? 4,
        'cuisineType': parsed['cuisineType'],
        'difficultyLevel': parsed['difficultyLevel'] ?? 'intermediate',
        'mealType': parsed['mealType'],
        'tips': parsed['tips'],
      };

      // Parse ingredients array
      if (parsed['ingredients'] is List) {
        final ingredients = <String>[];
        final ingredientObjects = <Map<String, dynamic>>[];

        for (final item in parsed['ingredients'] as List) {
          if (item is Map<String, dynamic>) {
            ingredientObjects.add(item);
            // Create formatted string for backward compatibility
            final name = item['name'] ?? '';
            final quantity = item['quantity'] ?? '';
            final unit = item['unit'] ?? '';
            final notes = item['notes'];

            String ingredientStr = '';
            if (quantity.toString().isNotEmpty && unit.toString().isNotEmpty) {
              ingredientStr = '$quantity $unit $name';
            } else if (quantity.toString().isNotEmpty) {
              ingredientStr = '$quantity $name';
            } else {
              ingredientStr = name;
            }

            if (notes != null && notes.toString().isNotEmpty) {
              ingredientStr += ' ($notes)';
            }

            ingredients.add(ingredientStr.trim());
          } else if (item is String) {
            ingredients.add(item);
          }
        }

        result['ingredients'] = ingredients;
        result['ingredientObjects'] = ingredientObjects;
      } else {
        result['ingredients'] = <String>[];
        result['ingredientObjects'] = <Map<String, dynamic>>[];
      }

      // Parse instructions
      if (parsed['instructions'] is List) {
        result['instructions'] = (parsed['instructions'] as List)
            .map((e) => e.toString())
            .toList();
      } else {
        result['instructions'] = <String>[];
      }

      // Parse dietary tags and allergens
      if (parsed['dietaryTags'] is List) {
        result['dietaryTags'] = (parsed['dietaryTags'] as List)
            .map((e) => e.toString())
            .toList();
      } else {
        result['dietaryTags'] = <String>[];
      }

      if (parsed['allergens'] is List) {
        result['allergens'] = (parsed['allergens'] as List)
            .map((e) => e.toString())
            .toList();
      } else {
        result['allergens'] = <String>[];
      }

      result['caloriesPerServing'] = parsed['caloriesPerServing'];

      print('Successfully parsed structured recipe: ${result['name']}');
      return result;
    } catch (e) {
      print('Failed to parse structured recipe response: $e');
      print('Falling back to legacy parser');
      return _fallbackParseRecipe(response);
    }
  }

  /// Fallback parser for non-JSON responses (legacy format)
  static Map<String, dynamic> _fallbackParseRecipe(String response) {
    return parseRecipeResponse(response);
  }
}
