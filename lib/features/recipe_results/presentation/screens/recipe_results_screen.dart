import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/services_provider.dart';
import '../../../recipe_generation/data/repositories/recipe_repository_impl.dart';
import '../../../recipe_detail/presentation/screens/recipe_detail_screen.dart';

/// Provider for recipe generation state
final recipeGenerationProvider = StateNotifierProvider<RecipeGenerationNotifier, AsyncValue<List<Recipe>>>((ref) {
  return RecipeGenerationNotifier(ref);
});

class RecipeGenerationNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final Ref ref;
  final RecipeRepositoryImpl _repository = RecipeRepositoryImpl(FirebaseFirestore.instance);
  
  // Track last ingredients used to avoid unnecessary regeneration
  List<String> _lastIngredients = [];
  DietaryProfile? _lastProfile;

  RecipeGenerationNotifier(this.ref) : super(const AsyncValue.data([]));

  Future<void> generateRecipes(List<String> ingredients, DietaryProfile profile) async {
    if (ingredients.isEmpty) {
      state = const AsyncValue.data([]);
      _lastIngredients = [];
      _lastProfile = null;
      return;
    }

    // Check if ingredients or profile have changed
    final ingredientsChanged = !_listEquals(_lastIngredients, ingredients);
    final profileChanged = _lastProfile == null || 
                          _lastProfile!.restrictions != profile.restrictions ||
                          _lastProfile!.skillLevel != profile.skillLevel ||
                          _lastProfile!.cuisinePreference != profile.cuisinePreference;

    // Skip regeneration if nothing changed and we have existing recipes
    if (!ingredientsChanged && !profileChanged && state.hasValue && state.value!.isNotEmpty) {
      return;
    }

    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Try to get cached recipes from Firestore first
      final cachedRecipes = await _repository.getCachedRecipes(
        userId,
        ingredients,
        profile.restrictions.join(', '),
        profile.skillLevel,
        profile.cuisinePreference,
      );

      if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
        // Use cached recipes
        final recipes = cachedRecipes.map((recipeData) {
          return Recipe(
            id: recipeData['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
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
        }).toList();

        _lastIngredients = List.from(ingredients);
        _lastProfile = profile;
        state = AsyncValue.data(recipes);
        return;
      }

      // No cache found - generate new recipes
      final aiService = ref.read(geminiAIServiceProvider);
      if (!aiService.isInitialized) {
        await aiService.initialize();
      }

      // Generate 3 recipe suggestions with graceful failure handling
      final recipes = <Recipe>[];
      final recipesData = <Map<String, dynamic>>[];
      int successCount = 0;
      int failCount = 0;
      
      for (int i = 0; i < 3; i++) {
        try {
          final recipeData = await aiService.generateRecipe(
            ingredients: ingredients,
            userId: userId,
            dietaryRestrictions: profile.restrictions.join(', '),
            skillLevel: profile.skillLevel,
            cuisinePreference: profile.cuisinePreference,
          );

          final recipe = Recipe(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
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
          successCount++;
          
          // Store recipe data for caching
          recipesData.add({
            'id': recipe.id,
            'name': recipe.name,
            'description': recipe.description,
            'ingredients': recipe.ingredients,
            'instructions': recipe.instructions,
            'prepTime': recipe.prepTime,
            'cookTime': recipe.cookTime,
            'difficulty': recipe.difficulty,
            'tags': recipe.tags,
          });
        } catch (e) {
          failCount++;
          print('Failed to generate recipe ${i + 1}/3: $e');
          
          // Continue with other recipes - only fail if we get zero recipes
          if (successCount == 0 && i == 2) {
            // All attempts failed
            throw Exception('Failed to generate any recipes. Please try again.');
          }
          // Otherwise continue to next recipe
        }
      }

      // Save successful recipes to Firestore cache (fire and forget)
      if (recipesData.isNotEmpty) {
        _repository.saveCachedRecipes(
          userId,
          ingredients,
          recipesData,
          profile.restrictions.join(', '),
          profile.skillLevel,
          profile.cuisinePreference,
        );
      }

      // Update tracking variables
      _lastIngredients = List.from(ingredients);
      _lastProfile = profile;
      
      print('Recipe generation complete: $successCount succeeded, $failCount failed');

      state = AsyncValue.data(recipes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Helper to compare lists
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = List<String>.from(a)..sort();
    final sortedB = List<String>.from(b)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }

  void clear() {
    state = const AsyncValue.data([]);
    _lastIngredients = [];
    _lastProfile = null;
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
    final pantryItems = ref.read(pantryIngredientsProvider);
    final profile = ref.read(dietaryProfileProvider);

    // Use sessionIngredients if available, otherwise use pantryIngredients
    final pantryNames = pantryItems.map((e) => e.name).toList();
    final ingredients = sessionIngredients.isNotEmpty 
      ? sessionIngredients 
      : pantryNames;

    if (ingredients.isNotEmpty) {
      ref.read(recipeGenerationProvider.notifier).generateRecipes(ingredients, profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionIngredients = ref.watch(sessionIngredientsProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);
    final recipesAsync = ref.watch(recipeGenerationProvider);

    // Determine which ingredients are being used
    final pantryNames = pantryItems.map((e) => e.name).toList();
    final activeIngredients = sessionIngredients.isNotEmpty 
      ? sessionIngredients 
      : pantryNames;
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
        final favoriteRecipes = ref.watch(favoriteRecipesProvider);
        final isFavorite = favoriteRecipes.any((r) => r.id == recipe.id);

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
                      Flexible(
                        child: _buildMetaChip(Icons.schedule, '${recipe.prepTime + recipe.cookTime} min'),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _buildMetaChip(Icons.signal_cellular_alt, recipe.difficulty),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: _buildMetaChip(Icons.restaurant, '${recipe.ingredients.length} items'),
                      ),
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
