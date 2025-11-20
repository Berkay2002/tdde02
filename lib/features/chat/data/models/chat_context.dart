import 'recipe_reference.dart';

/// Enumeration of screens where chat can be accessed
enum ChatScreen {
  home,
  pantry,
  recipes,
  recipeDetail,
  favorites,
  profile,
  unknown;

  String get displayName {
    switch (this) {
      case ChatScreen.home:
        return 'Home';
      case ChatScreen.pantry:
        return 'Pantry';
      case ChatScreen.recipes:
        return 'Recipes';
      case ChatScreen.recipeDetail:
        return 'Recipe Detail';
      case ChatScreen.favorites:
        return 'Favorites';
      case ChatScreen.profile:
        return 'Profile';
      case ChatScreen.unknown:
        return 'App';
    }
  }
}

/// Contextual information available to the chat
class ChatContext {
  final ChatScreen currentScreen;
  final List<String>? sessionIngredients; // Quick scan ingredients
  final List<Map<String, dynamic>>? pantryItems; // Pantry ingredients
  final List<RecipeReference>? attachedRecipes; // @recipe references
  final Map<String, dynamic>? userProfile; // Dietary preferences, skill level
  final String? currentRecipeId; // If on recipe detail screen

  const ChatContext({
    this.currentScreen = ChatScreen.unknown,
    this.sessionIngredients,
    this.pantryItems,
    this.attachedRecipes,
    this.userProfile,
    this.currentRecipeId,
  });

  /// Create empty context
  factory ChatContext.empty() {
    return const ChatContext();
  }

  /// Create context for home screen
  factory ChatContext.home({List<String>? sessionIngredients}) {
    return ChatContext(
      currentScreen: ChatScreen.home,
      sessionIngredients: sessionIngredients,
    );
  }

  /// Create context for pantry screen
  factory ChatContext.pantry({List<Map<String, dynamic>>? pantryItems}) {
    return ChatContext(
      currentScreen: ChatScreen.pantry,
      pantryItems: pantryItems,
    );
  }

  /// Create context for recipe detail screen
  factory ChatContext.recipeDetail({
    required String recipeId,
    RecipeReference? currentRecipe,
  }) {
    return ChatContext(
      currentScreen: ChatScreen.recipeDetail,
      currentRecipeId: recipeId,
      attachedRecipes: currentRecipe != null ? [currentRecipe] : null,
    );
  }

  /// Convert to map for AI prompt
  Map<String, dynamic> toContextMap() {
    final context = <String, dynamic>{
      'current_screen': currentScreen.displayName,
    };

    if (sessionIngredients != null && sessionIngredients!.isNotEmpty) {
      context['session_ingredients'] = sessionIngredients!.join(', ');
    }

    if (pantryItems != null && pantryItems!.isNotEmpty) {
      final pantryNames = pantryItems!
          .map((item) => item['name'] as String? ?? 'Unknown')
          .toList();
      context['pantry_items'] = pantryNames.join(', ');
      context['pantry_count'] = pantryItems!.length;
    }

    if (attachedRecipes != null && attachedRecipes!.isNotEmpty) {
      context['attached_recipes'] = attachedRecipes!
          .map((recipe) => recipe.toContextString())
          .join('\n---\n');
      context['attached_recipe_count'] = attachedRecipes!.length;
    }

    if (userProfile != null) {
      if (userProfile!.containsKey('dietary_restrictions')) {
        context['dietary_restrictions'] = userProfile!['dietary_restrictions'];
      }
      if (userProfile!.containsKey('skill_level')) {
        context['skill_level'] = userProfile!['skill_level'];
      }
      if (userProfile!.containsKey('cuisine_preferences')) {
        context['cuisine_preferences'] = userProfile!['cuisine_preferences'];
      }
    }

    if (currentRecipeId != null) {
      context['current_recipe_id'] = currentRecipeId;
    }

    return context;
  }

  /// Get a system prompt based on current context
  String getSystemPrompt() {
    final basePrompt = '''
You are a helpful AI cooking assistant. You help users with recipes, cooking techniques, ingredient substitutions, and meal planning.

Guidelines:
- Be friendly, conversational, and encouraging
- Provide practical, actionable advice
- When discussing recipes, be specific with measurements and techniques
- If asked about a recipe the user has referenced, focus on that specific recipe
- Keep responses concise but informative
- Use clear, simple language suitable for home cooks
''';

    final contextPrompt = StringBuffer();
    contextPrompt.writeln(basePrompt);
    contextPrompt.writeln();

    // Add screen-specific context
    switch (currentScreen) {
      case ChatScreen.home:
        contextPrompt.writeln(
          'The user is on the Home screen. They may want help with quick recipe ideas.',
        );
        if (sessionIngredients != null && sessionIngredients!.isNotEmpty) {
          contextPrompt.writeln(
            'They have scanned these ingredients: ${sessionIngredients!.join(", ")}',
          );
        }
        break;
      case ChatScreen.pantry:
        contextPrompt.writeln(
          'The user is viewing their Pantry. They may want help organizing ingredients, understanding shelf life, or finding recipes.',
        );
        break;
      case ChatScreen.recipes:
        contextPrompt.writeln(
          'The user is browsing recipe suggestions. They may want modifications, alternatives, or cooking tips.',
        );
        break;
      case ChatScreen.recipeDetail:
        contextPrompt.writeln(
          'The user is viewing a specific recipe. Help them with cooking techniques, substitutions, scaling, or troubleshooting.',
        );
        break;
      case ChatScreen.favorites:
        contextPrompt.writeln(
          'The user is viewing their saved recipes. They may want meal planning help or variations.',
        );
        break;
      default:
        break;
    }

    return contextPrompt.toString();
  }

  /// Copy with updated fields
  ChatContext copyWith({
    ChatScreen? currentScreen,
    List<String>? sessionIngredients,
    List<Map<String, dynamic>>? pantryItems,
    List<RecipeReference>? attachedRecipes,
    Map<String, dynamic>? userProfile,
    String? currentRecipeId,
  }) {
    return ChatContext(
      currentScreen: currentScreen ?? this.currentScreen,
      sessionIngredients: sessionIngredients ?? this.sessionIngredients,
      pantryItems: pantryItems ?? this.pantryItems,
      attachedRecipes: attachedRecipes ?? this.attachedRecipes,
      userProfile: userProfile ?? this.userProfile,
      currentRecipeId: currentRecipeId ?? this.currentRecipeId,
    );
  }

  /// Add a recipe reference to context
  ChatContext addRecipeReference(RecipeReference recipe) {
    final currentRecipes = attachedRecipes ?? [];
    // Max 3 recipes to avoid context overflow
    if (currentRecipes.length >= 3) {
      return this;
    }
    return copyWith(attachedRecipes: [...currentRecipes, recipe]);
  }

  /// Remove a recipe reference from context
  ChatContext removeRecipeReference(String recipeId) {
    if (attachedRecipes == null) return this;
    return copyWith(
      attachedRecipes: attachedRecipes!
          .where((recipe) => recipe.id != recipeId)
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ChatContext(screen: ${currentScreen.displayName}, ingredients: ${sessionIngredients?.length ?? 0}, recipes: ${attachedRecipes?.length ?? 0})';
  }
}
