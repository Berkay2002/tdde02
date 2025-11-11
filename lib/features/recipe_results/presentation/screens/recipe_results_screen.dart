import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../core/services/gemini_ai_service.dart';
import '../../../recipe_detail/presentation/screens/recipe_detail_screen.dart';

/// Provider for recipe generation state
final recipeGenerationProvider = StateNotifierProvider<RecipeGenerationNotifier, AsyncValue<List<Recipe>>>((ref) {
  return RecipeGenerationNotifier(ref);
});

class RecipeGenerationNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final Ref ref;
  final GeminiAIService _aiService = GeminiAIService();

  RecipeGenerationNotifier(this.ref) : super(const AsyncValue.data([]));

  Future<void> generateRecipes(List<String> ingredients, DietaryProfile profile) async {
    if (ingredients.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Initialize AI service if needed
      if (!_aiService.isInitialized) {
        await _aiService.initialize();
      }

      // Generate 3 recipe suggestions
      final recipes = <Recipe>[];
      for (int i = 0; i < 3; i++) {
        final recipeData = await _aiService.generateRecipe(
          ingredients: ingredients,
          dietaryRestrictions: profile.restrictions.join(', '),
          skillLevel: profile.skillLevel,
          cuisinePreference: profile.cuisinePreference,
        );

        final recipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
          name: recipeData['name'] as String? ?? 'Untitled Recipe',
          description: recipeData['description'] as String? ?? '',
          ingredients: (recipeData['ingredients'] as List?)?.cast<String>() ?? ingredients,
          instructions: (recipeData['instructions'] as List?)?.cast<String>() ?? [],
          prepTime: recipeData['prepTime'] as int? ?? 15,
          cookTime: recipeData['cookTime'] as int? ?? 30,
          difficulty: recipeData['difficulty'] as String? ?? 'medium',
          tags: (recipeData['tags'] as List?)?.cast<String>() ?? [],
          createdAt: DateTime.now(),
        );

        recipes.add(recipe);
      }

      state = AsyncValue.data(recipes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

/// RecipeResultsScreen - Tab 3
/// 
/// Displays recipe results based on sessionIngredients (quick search)
/// or pantryIngredients (full pantry search) if session is empty.
class RecipeResultsScreen extends ConsumerStatefulWidget {
  const RecipeResultsScreen({super.key});

  @override
  ConsumerState<RecipeResultsScreen> createState() => _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends ConsumerState<RecipeResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Generate recipes on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateRecipes();
    });
  }

  void _generateRecipes() {
    final sessionIngredients = ref.read(sessionIngredientsProvider);
    final pantryIngredients = ref.read(pantryIngredientsProvider);
    final profile = ref.read(dietaryProfileProvider);

    // Use sessionIngredients if available, otherwise use pantryIngredients
    final ingredients = sessionIngredients.isNotEmpty 
        ? sessionIngredients 
        : pantryIngredients;

    if (ingredients.isNotEmpty) {
      ref.read(recipeGenerationProvider.notifier).generateRecipes(ingredients, profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionIngredients = ref.watch(sessionIngredientsProvider);
    final pantryIngredients = ref.watch(pantryIngredientsProvider);
    final recipesAsync = ref.watch(recipeGenerationProvider);

    // Determine which ingredients are being used
    final activeIngredients = sessionIngredients.isNotEmpty 
        ? sessionIngredients 
        : pantryIngredients;
    final isQuickSearch = sessionIngredients.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isQuickSearch ? 'Recipe Suggestions' : 'Pantry Recipes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Regenerate recipes',
            onPressed: _generateRecipes,
          ),
        ],
      ),
      body: activeIngredients.isEmpty
          ? _buildEmptyState(theme)
          : Column(
              children: [
                // Ingredients being used
                _buildIngredientsChips(activeIngredients, isQuickSearch, theme),
                
                // Recipe results
                Expanded(
                  child: recipesAsync.when(
                    data: (recipes) => recipes.isEmpty
                        ? _buildNoRecipesState(theme)
                        : _buildRecipesList(recipes),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _buildErrorState(error, theme),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIngredientsChips(List<String> ingredients, bool isQuickSearch, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isQuickSearch ? Icons.search : Icons.kitchen,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                isQuickSearch ? 'Quick Search' : 'From Your Pantry',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ingredients.map((ingredient) {
              return Chip(
                label: Text(ingredient),
                backgroundColor: theme.colorScheme.secondaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesList(List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        final isFavorite = ref.watch(favoriteRecipesProvider.notifier).isFavorite(recipe.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recipe header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (recipe.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                recipe.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
                        },
                      ),
                    ],
                  ),
                ),

                // Recipe meta info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildMetaChip(Icons.schedule, '${recipe.prepTime + recipe.cookTime} min'),
                      const SizedBox(width: 8),
                      _buildMetaChip(Icons.signal_cellular_alt, recipe.difficulty),
                      const SizedBox(width: 8),
                      _buildMetaChip(Icons.restaurant, '${recipe.ingredients.length} items'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ingredients selected',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scan or add ingredients to find recipes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRecipesState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No recipes found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try different ingredients or preferences',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to generate recipes',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _generateRecipes,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
