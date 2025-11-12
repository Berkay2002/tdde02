import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/services_provider.dart';
import '../../../recipe_generation/data/repositories/recipe_repository_impl.dart';
import '../../../recipe_detail/presentation/screens/recipe_detail_screen.dart';
import '../../../../core/constants/recipe_categories.dart';
import '../widgets/recipe_card.dart';
import '../widgets/empty_recipes_widget.dart';
import '../widgets/recipe_search_bar.dart';
import '../widgets/recipe_filter_chips.dart';

/// Provider for recipe generation state
final recipeGenerationProvider =
    StateNotifierProvider<RecipeGenerationNotifier, AsyncValue<List<Recipe>>>((
      ref,
    ) {
      return RecipeGenerationNotifier(ref);
    });

class RecipeGenerationNotifier extends StateNotifier<AsyncValue<List<Recipe>>> {
  final Ref ref;
  final RecipeRepositoryImpl _repository = RecipeRepositoryImpl(
    FirebaseFirestore.instance,
  );

  // Track last ingredients used to avoid unnecessary regeneration
  List<String> _lastIngredients = [];
  DietaryProfile? _lastProfile;

  RecipeGenerationNotifier(this.ref) : super(const AsyncValue.data([]));

  Future<void> generateRecipes(
    List<String> ingredients,
    DietaryProfile profile,
  ) async {
    if (ingredients.isEmpty) {
      state = const AsyncValue.data([]);
      _lastIngredients = [];
      _lastProfile = null;
      return;
    }

    // Check if ingredients or profile have changed
    final ingredientsChanged = !_listEquals(_lastIngredients, ingredients);
    final profileChanged =
        _lastProfile == null ||
        !_listEquals(_lastProfile!.restrictions, profile.restrictions) ||
        !_listEquals(_lastProfile!.skillLevels, profile.skillLevels) ||
        !_listEquals(
          _lastProfile!.cuisinePreferences,
          profile.cuisinePreferences,
        );

    // Skip regeneration if nothing changed and we have existing recipes
    if (!ingredientsChanged &&
        !profileChanged &&
        state.hasValue &&
        state.value!.isNotEmpty) {
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
        profile.skillLevels.isNotEmpty ? profile.skillLevels.first : 'beginner',
        profile.cuisinePreferences.isNotEmpty
            ? profile.cuisinePreferences.first
            : null,
      );

      if (cachedRecipes != null && cachedRecipes.isNotEmpty) {
        // Use cached recipes
        final recipes = cachedRecipes.map((recipeData) {
          return Recipe(
            id:
                recipeData['id'] as String? ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            name: recipeData['name'] as String? ?? 'Untitled Recipe',
            description: recipeData['description'] as String? ?? '',
            ingredients:
                (recipeData['ingredients'] as List?)?.cast<String>() ??
                ingredients,
            instructions:
                (recipeData['instructions'] as List?)?.cast<String>() ?? [],
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
            skillLevel: profile.skillLevels.isNotEmpty
                ? profile.skillLevels.first
                : 'beginner',
            cuisinePreference: profile.cuisinePreferences.isNotEmpty
                ? profile.cuisinePreferences.first
                : null,
            measurementSystem: profile.measurementSystem,
          );

          final recipe = Recipe(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            name: recipeData['name'] as String? ?? 'Untitled Recipe',
            description: recipeData['description'] as String? ?? '',
            ingredients:
                (recipeData['ingredients'] as List?)?.cast<String>() ??
                ingredients,
            instructions:
                (recipeData['instructions'] as List?)?.cast<String>() ?? [],
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
            throw Exception(
              'Failed to generate any recipes. Please try again.',
            );
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
          profile.skillLevels.isNotEmpty
              ? profile.skillLevels.first
              : 'beginner',
          profile.cuisinePreferences.isNotEmpty
              ? profile.cuisinePreferences.first
              : null,
        );
      }

      // Update tracking variables
      _lastIngredients = List.from(ingredients);
      _lastProfile = profile;

      print(
        'Recipe generation complete: $successCount succeeded, $failCount failed',
      );

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
  ConsumerState<RecipeResultsScreen> createState() =>
      _RecipeResultsScreenState();
}

class _RecipeResultsScreenState extends ConsumerState<RecipeResultsScreen> {
  String _searchQuery = '';
  Set<String> _selectedFilters = {};

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
      ref
          .read(recipeGenerationProvider.notifier)
          .generateRecipes(ingredients, profile);
    }
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes) {
    var filtered = recipes;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            recipe.description.toLowerCase().contains(query) ||
            recipe.ingredients.any(
              (ing) => ing.toLowerCase().contains(query),
            ) ||
            recipe.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    // Apply category filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((recipe) {
        // Check difficulty
        if (_selectedFilters.contains('easy') &&
            recipe.difficulty.toLowerCase() != 'easy') {
          return false;
        }

        // Check time
        if (_selectedFilters.contains('quick')) {
          final totalTime = recipe.prepTime + recipe.cookTime;
          if (totalTime >= 30) return false;
        }

        // Check cuisines using the helper's detection logic
        final cuisines = ['italian', 'asian', 'mexican', 'american', 'french'];
        final selectedCuisines = _selectedFilters.intersection(
          cuisines.toSet(),
        );
        if (selectedCuisines.isNotEmpty) {
          // Use RecipeCategoryHelper to detect the recipe's cuisine
          final detectedCuisine = RecipeCategoryHelper.detectCuisine(
            recipe.name,
            recipe.tags,
          );
          final detectedCuisineName = RecipeCategoryHelper.getCuisineName(
            detectedCuisine,
          ).toLowerCase();

          // Check if the detected cuisine matches any selected filter
          if (!selectedCuisines.contains(detectedCuisineName)) {
            return false;
          }
        }

        return true;
      }).toList();
    }

    return filtered;
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
          ? EmptyRecipesWidget(
              reason: EmptyRecipesReason.noIngredients,
              onAction: () {
                // Navigate to home tab to add ingredients
                DefaultTabController.of(context).animateTo(0);
              },
            )
          : Column(
              children: [
                // Search bar
                RecipeSearchBar(
                  query: _searchQuery,
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  onClear: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),

                // Filter chips
                RecipeFilterChips(
                  selectedFilters: _selectedFilters,
                  onFiltersChanged: (filters) {
                    setState(() {
                      _selectedFilters = filters;
                    });
                  },
                ),

                // Ingredients being used
                _buildIngredientsChips(activeIngredients, isQuickSearch, theme),

                // Recipe results
                Expanded(
                  child: recipesAsync.when(
                    data: (recipes) {
                      if (recipes.isEmpty) {
                        return EmptyRecipesWidget(
                          reason: EmptyRecipesReason.generationFailed,
                          onAction: _generateRecipes,
                        );
                      }

                      final filteredRecipes = _filterRecipes(recipes);

                      if (filteredRecipes.isEmpty) {
                        return EmptyRecipesWidget(
                          reason: EmptyRecipesReason.noMatchingFilters,
                          onAction: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedFilters = {};
                            });
                          },
                        );
                      }

                      return _buildRecipesList(filteredRecipes);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => EmptyRecipesWidget(
                      reason: EmptyRecipesReason.generationFailed,
                      onAction: _generateRecipes,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildIngredientsChips(
    List<String> ingredients,
    bool isQuickSearch,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
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

        return RecipeCard(
          recipe: recipe,
          isFavorite: isFavorite,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          onFavorite: () {
            ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isFavorite ? 'Removed from favorites' : 'Added to favorites',
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}
