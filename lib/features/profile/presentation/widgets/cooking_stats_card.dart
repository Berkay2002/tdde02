import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';

/// Cooking stats card showing user's cooking journey metrics
class CookingStatsCard extends ConsumerWidget {
  const CookingStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoriteRecipesProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);
    final profile = ref.watch(dietaryProfileProvider);

    // Calculate stats
    final recipesThisWeek = _countRecentRecipes(favorites, days: 7);
    final mostLovedCuisine = profile.cuisinePreferences.isNotEmpty 
        ? profile.cuisinePreferences.join(', ') 
        : 'All Cuisines';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Cooking Journey',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Stats
            _StatRow(
              icon: Icons.book_outlined,
              text: '${favorites.length} recipes discovered',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.favorite,
              text: '${favorites.length} favorites saved',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.eco,
              text: '${pantryItems.length} pantry items tracked',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.restaurant_menu,
              text: 'Most loved: $mostLovedCuisine',
              theme: theme,
            ),
            const SizedBox(height: 12),
            _StatRow(
              icon: Icons.calendar_today,
              text: '$recipesThisWeek recipes this week',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  int _countRecentRecipes(List<Recipe> recipes, {required int days}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return recipes.where((r) => r.createdAt.isAfter(cutoff)).length;
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeData theme;

  const _StatRow({
    required this.icon,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
