import 'package:flutter/material.dart';

/// Empty state widget when no favorites exist
class EmptyFavoritesWidget extends StatelessWidget {
  final VoidCallback onBrowseRecipes;
  final VoidCallback onGenerateRecipes;

  const EmptyFavoritesWidget({
    super.key,
    required this.onBrowseRecipes,
    required this.onGenerateRecipes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 120,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorites Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start saving recipes you love\nto find them quickly here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onBrowseRecipes,
              icon: const Icon(Icons.explore),
              label: const Text('Browse Recipes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGenerateRecipes,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate New Recipes'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
