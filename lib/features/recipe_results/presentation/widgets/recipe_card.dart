import 'package:flutter/material.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../core/constants/recipe_categories.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cuisine = RecipeCategoryHelper.detectCuisine(
      recipe.name,
      recipe.tags,
    );
    final difficulty = RecipeCategoryHelper.parseDifficulty(recipe.difficulty);
    final totalTime = recipe.prepTime + recipe.cookTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with gradient
            _buildImageHeader(cuisine, theme),

            // Recipe content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description
                  if (recipe.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      recipe.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Meta chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetaChip(
                        icon: Icons.schedule,
                        label: '$totalTime min',
                        color: theme.colorScheme.primary,
                        theme: theme,
                      ),
                      _buildMetaChip(
                        icon: RecipeCategoryHelper.getDifficultyIcon(
                          difficulty,
                        ),
                        label: recipe.difficulty,
                        color: RecipeCategoryHelper.getDifficultyColor(
                          difficulty,
                        ),
                        theme: theme,
                      ),
                      _buildMetaChip(
                        icon: Icons.restaurant,
                        label: '${recipe.ingredients.length} items',
                        color: theme.colorScheme.secondary,
                        theme: theme,
                      ),
                    ],
                  ),

                  // Tags
                  if (recipe.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: recipe.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader(RecipeCuisine cuisine, ThemeData theme) {
    final gradientColors = RecipeCategoryHelper.getCuisineGradient(cuisine);
    final cuisineIcon = RecipeCategoryHelper.getCuisineIcon(cuisine);
    final cuisineName = RecipeCategoryHelper.getCuisineName(cuisine);

    return Stack(
      children: [
        // Gradient background
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(
              cuisineIcon,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),

        // Overlay gradient for better text readability
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Cuisine badge and favorite button
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Cuisine badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cuisineIcon, size: 16, color: gradientColors.first),
                    const SizedBox(width: 6),
                    Text(
                      cuisineName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: gradientColors.first,
                      ),
                    ),
                  ],
                ),
              ),

              // Favorite button
              Material(
                color: Colors.white.withOpacity(0.9),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onFavorite,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[700],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
