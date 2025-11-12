import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../core/constants/recipe_categories.dart';
import '../../../recipe_detail/presentation/screens/recipe_detail_screen.dart';

/// Recent recipes widget showing horizontal scrollable list of favorites
class RecentRecipesWidget extends ConsumerWidget {
  const RecentRecipesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);

    if (favoriteRecipes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show up to 5 recent favorites
    final recentRecipes = favoriteRecipes.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Favorites',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => switchToFavoritesTab(context),
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal scrollable list
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentRecipes.length,
            itemBuilder: (context, index) {
              final recipe = recentRecipes[index];
              return _RecentRecipeCard(recipe: recipe);
            },
          ),
        ),
      ],
    );
  }
}

class _RecentRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecentRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Detect cuisine and get colors
    final cuisine = RecipeCategoryHelper.detectCuisine(
      recipe.name,
      recipe.tags,
    );
    final gradientColors = RecipeCategoryHelper.getCuisineGradient(cuisine);
    final cuisineName = RecipeCategoryHelper.getCuisineName(cuisine);
    final cuisineIcon = RecipeCategoryHelper.getCuisineIcon(cuisine);

    // Difficulty color
    final difficultyEnum = RecipeCategoryHelper.parseDifficulty(
      recipe.difficulty,
    );
    final difficultyColor = RecipeCategoryHelper.getDifficultyColor(
      difficultyEnum,
    );

    final totalTime = recipe.prepTime + recipe.cookTime;

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
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
              // Gradient header
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Cuisine icon (large, semi-transparent)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Icon(
                        cuisineIcon,
                        size: 48,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),

                    // Cuisine badge
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              cuisineIcon,
                              size: 14,
                              color: gradientColors[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              cuisineName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: gradientColors[0],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Recipe info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe name
                      Text(
                        recipe.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const Spacer(),

                      // Meta info
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${totalTime}min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: difficultyColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              recipe.difficulty,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: difficultyColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
