import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../core/constants/recipe_categories.dart';
import '../../../recipe_detail/presentation/screens/recipe_detail_screen.dart';
import '../../../recipe_results/presentation/widgets/recipe_card.dart';
import '../widgets/favorites_search_bar.dart';
import '../widgets/favorites_filter_chips.dart';
import '../widgets/empty_favorites_widget.dart';
import '../widgets/favorites_stats_card.dart';

/// FavoritesScreen - Tab 4
///
/// Displays all saved favorite recipes with search, filter, and sort functionality.
/// Users can view, remove, organize, and navigate to recipe details.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

enum FavoritesSortOption {
  recentlyAdded,
  alphabeticalAZ,
  alphabeticalZA,
  quickestFirst,
  easiestFirst,
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String _searchQuery = '';
  Set<String> _selectedFilters = {};
  FavoritesSortOption _currentSort = FavoritesSortOption.recentlyAdded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allFavorites = ref.watch(favoriteRecipesProvider);
    final filteredRecipes = _applyFiltersAndSort(allFavorites);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: [
          if (allFavorites.isNotEmpty)
            PopupMenuButton<FavoritesSortOption>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onSelected: (option) => setState(() => _currentSort = option),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: FavoritesSortOption.recentlyAdded,
                  child: Text('Recently Added'),
                ),
                const PopupMenuItem(
                  value: FavoritesSortOption.alphabeticalAZ,
                  child: Text('Alphabetical (A-Z)'),
                ),
                const PopupMenuItem(
                  value: FavoritesSortOption.alphabeticalZA,
                  child: Text('Alphabetical (Z-A)'),
                ),
                const PopupMenuItem(
                  value: FavoritesSortOption.quickestFirst,
                  child: Text('Quickest First'),
                ),
                const PopupMenuItem(
                  value: FavoritesSortOption.easiestFirst,
                  child: Text('Easiest First'),
                ),
              ],
            ),
          if (allFavorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all favorites',
              onPressed: () => _clearFavorites(context, ref),
            ),
        ],
      ),
      body: allFavorites.isEmpty
          ? EmptyFavoritesWidget(
              onBrowseRecipes: () => _navigateToTab(2),
              onGenerateRecipes: () => _navigateToTab(0),
            )
          : Column(
              children: [
                // Search bar
                FavoritesSearchBar(
                  query: _searchQuery,
                  onQueryChanged: (query) =>
                      setState(() => _searchQuery = query),
                  onClear: () => setState(() => _searchQuery = ''),
                ),

                // Filter chips
                if (allFavorites.isNotEmpty)
                  FavoritesFilterChips(
                    selectedFilters: _selectedFilters,
                    onFiltersChanged: (filters) =>
                        setState(() => _selectedFilters = filters),
                  ),

                // Stats card
                if (allFavorites.isNotEmpty &&
                    _searchQuery.isEmpty &&
                    _selectedFilters.isEmpty)
                  FavoritesStatsCard(recipes: allFavorites),

                // Recipe list
                Expanded(
                  child: filteredRecipes.isEmpty
                      ? _buildEmptyFilterState(theme)
                      : _buildFavoritesList(filteredRecipes),
                ),
              ],
            ),
    );
  }

  void _navigateToTab(int tabIndex) {
    // Find the AppShell ancestor and switch tabs
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          tabIndex == 0
              ? 'Navigate to Home to generate recipes'
              : 'Navigate to Recipes to browse',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Recipe> _applyFiltersAndSort(List<Recipe> recipes) {
    var filtered = recipes;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((recipe) {
        return recipe.name.toLowerCase().contains(query) ||
            recipe.description.toLowerCase().contains(query) ||
            recipe.ingredients.any((i) => i.toLowerCase().contains(query)) ||
            recipe.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    // Apply filters
    if (_selectedFilters.isNotEmpty) {
      filtered = filtered.where((recipe) {
        // Cuisine filters
        final selectedCuisines = _selectedFilters.where(
          (f) => [
            'italian',
            'asian',
            'mexican',
            'mediterranean',
            'american',
          ].contains(f),
        );

        if (selectedCuisines.isNotEmpty) {
          final cuisine = RecipeCategoryHelper.detectCuisine(
            recipe.name,
            recipe.tags,
          );
          final cuisineName = RecipeCategoryHelper.getCuisineName(
            cuisine,
          ).toLowerCase();
          if (!selectedCuisines.contains(cuisineName)) return false;
        }

        // Difficulty filter
        if (_selectedFilters.contains('easy')) {
          final difficulty = RecipeCategoryHelper.parseDifficulty(
            recipe.difficulty,
          );
          if (difficulty != RecipeDifficulty.easy) return false;
        }

        // Time filter
        if (_selectedFilters.contains('< 30 min')) {
          final totalTime = recipe.prepTime + recipe.cookTime;
          if (totalTime >= 30) return false;
        }

        return true;
      }).toList();
    }

    // Apply sort
    return _sortRecipes(filtered);
  }

  List<Recipe> _sortRecipes(List<Recipe> recipes) {
    final sorted = List<Recipe>.from(recipes);

    switch (_currentSort) {
      case FavoritesSortOption.recentlyAdded:
        // Keep original order (most recent first)
        break;
      case FavoritesSortOption.alphabeticalAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case FavoritesSortOption.alphabeticalZA:
        sorted.sort((a, b) => b.name.compareTo(a.name));
      case FavoritesSortOption.quickestFirst:
        sorted.sort(
          (a, b) =>
              (a.prepTime + a.cookTime).compareTo(b.prepTime + b.cookTime),
        );
      case FavoritesSortOption.easiestFirst:
        sorted.sort((a, b) {
          final diffA = RecipeCategoryHelper.parseDifficulty(a.difficulty);
          final diffB = RecipeCategoryHelper.parseDifficulty(b.difficulty);
          return diffA.index.compareTo(diffB.index);
        });
    }

    return sorted;
  }

  Widget _buildEmptyFilterState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text('No recipes found', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try different search terms'
                  : 'Try adjusting your filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilters.clear();
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList(List<Recipe> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];

        return RecipeCard(
          recipe: recipe,
          isFavorite: true, // Always true in favorites screen
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailScreen(recipe: recipe),
              ),
            );
          },
          onFavorite: () {
            ref.read(favoriteRecipesProvider.notifier).removeRecipe(recipe.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${recipe.name} removed from favorites'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    ref
                        .read(favoriteRecipesProvider.notifier)
                        .addRecipe(recipe);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _clearFavorites(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites?'),
        content: const Text(
          'This will remove all saved recipes from your favorites.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(favoriteRecipesProvider.notifier).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All favorites cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
