import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/providers/app_state_provider.dart';

/// Personalized greeting card showing welcome message and quick stats
class PersonalizedGreetingCard extends ConsumerWidget {
  const PersonalizedGreetingCard({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);

    // For recipes generated stat, we use favorites as proxy
    final recipesCount = favoriteRecipes.length;
    final favoritesCount = favoriteRecipes.length;
    final pantryCount = pantryItems.length;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              '${_getGreeting()}!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),

            // User email
            if (user?.email != null)
              Text(
                user!.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

            const SizedBox(height: 20),

            // Quick stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  count: recipesCount,
                  label: 'Recipes',
                  icon: Icons.restaurant_menu,
                  color: theme.colorScheme.primary,
                ),
                _StatColumn(
                  count: favoritesCount,
                  label: 'Favorites',
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                _StatColumn(
                  count: pantryCount,
                  label: 'Pantry',
                  icon: Icons.kitchen,
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$count',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
