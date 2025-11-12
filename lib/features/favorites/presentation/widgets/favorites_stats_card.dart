import 'package:flutter/material.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../core/constants/recipe_categories.dart';

/// Statistics card showing insights about favorite recipes
class FavoritesStatsCard extends StatefulWidget {
  final List<Recipe> recipes;

  const FavoritesStatsCard({
    super.key,
    required this.recipes,
  });

  @override
  State<FavoritesStatsCard> createState() => _FavoritesStatsCardState();
}

class _FavoritesStatsCardState extends State<FavoritesStatsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateStats(widget.recipes);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Icon(
              Icons.bar_chart,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              '${widget.recipes.length} Favorite ${widget.recipes.length == 1 ? 'Recipe' : 'Recipes'}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onExpansionChanged: (expanded) {
              setState(() => _isExpanded = expanded);
            },
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    _buildStatRow(
                      context,
                      icon: Icons.public,
                      label: 'Most loved cuisine',
                      value: stats.topCuisine,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      icon: Icons.schedule,
                      label: 'Average cooking time',
                      value: '${stats.avgTime} min',
                    ),
                    const SizedBox(height: 12),
                    _buildDifficultyRow(
                      context,
                      stats: stats,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      context,
                      icon: Icons.restaurant,
                      label: 'Total ingredients',
                      value: '${stats.totalIngredients} unique',
                    ),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyRow(
    BuildContext context, {
    required _FavoritesStats stats,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.signal_cellular_alt,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Difficulty breakdown',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stats.difficultyBreakdown,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _FavoritesStats _calculateStats(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return _FavoritesStats(
        topCuisine: 'N/A',
        avgTime: 0,
        difficultyBreakdown: 'N/A',
        totalIngredients: 0,
      );
    }

    // Calculate most common cuisine
    final cuisineCounts = <String, int>{};
    for (final recipe in recipes) {
      final cuisine = RecipeCategoryHelper.detectCuisine(
        recipe.name,
        recipe.tags,
      );
      final cuisineName = RecipeCategoryHelper.getCuisineName(cuisine);
      cuisineCounts[cuisineName] = (cuisineCounts[cuisineName] ?? 0) + 1;
    }

    final topCuisineEntry = cuisineCounts.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    final topCuisine = '${topCuisineEntry.key} (${topCuisineEntry.value})';

    // Calculate average time
    final totalTime = recipes.fold<int>(
      0,
      (sum, recipe) => sum + recipe.prepTime + recipe.cookTime,
    );
    final avgTime = (totalTime / recipes.length).round();

    // Calculate difficulty breakdown
    final difficultyCounts = <RecipeDifficulty, int>{};
    for (final recipe in recipes) {
      final difficulty = RecipeCategoryHelper.parseDifficulty(recipe.difficulty);
      difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1;
    }

    final easyCount = difficultyCounts[RecipeDifficulty.easy] ?? 0;
    final mediumCount = difficultyCounts[RecipeDifficulty.medium] ?? 0;
    final hardCount = difficultyCounts[RecipeDifficulty.hard] ?? 0;

    final easyPct = ((easyCount / recipes.length) * 100).round();
    final mediumPct = ((mediumCount / recipes.length) * 100).round();
    final hardPct = ((hardCount / recipes.length) * 100).round();

    final difficultyBreakdown =
        '${easyPct}% easy, ${mediumPct}% medium, ${hardPct}% hard';

    // Calculate total unique ingredients
    final allIngredients = <String>{};
    for (final recipe in recipes) {
      allIngredients.addAll(recipe.ingredients);
    }

    return _FavoritesStats(
      topCuisine: topCuisine,
      avgTime: avgTime,
      difficultyBreakdown: difficultyBreakdown,
      totalIngredients: allIngredients.length,
    );
  }
}

class _FavoritesStats {
  final String topCuisine;
  final int avgTime;
  final String difficultyBreakdown;
  final int totalIngredients;

  _FavoritesStats({
    required this.topCuisine,
    required this.avgTime,
    required this.difficultyBreakdown,
    required this.totalIngredients,
  });
}
