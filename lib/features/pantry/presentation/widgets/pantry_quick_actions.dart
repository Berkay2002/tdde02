import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';

/// Quick actions banner for pantry screen
class PantryQuickActions extends ConsumerWidget {
  const PantryQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _QuickActionCard(
                    icon: Icons.shuffle,
                    label: 'Cook Random',
                    color: Colors.purple,
                    onTap: () => _cookRandom(context, ref),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionCard(
                    icon: Icons.search,
                    label: 'Find Recipes',
                    color: Colors.blue,
                    onTap: () => _findRecipes(context, ref),
                  ),
                  const SizedBox(width: 12),
                  _QuickActionCard(
                    icon: Icons.share,
                    label: 'Share List',
                    color: Colors.green,
                    onTap: () => _shareList(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cookRandom(BuildContext context, WidgetRef ref) {
    final pantryItems = ref.read(pantryIngredientsProvider);
    if (pantryItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add ingredients first')));
      return;
    }

    // Set pantry ingredients as session ingredients
    final pantryNames = pantryItems.map((e) => e.name).toList();
    ref.read(sessionIngredientsProvider.notifier).setIngredients(pantryNames);

    // Navigate to recipes tab
    switchToRecipeTab(context);
  }

  void _findRecipes(BuildContext context, WidgetRef ref) {
    final pantryItems = ref.read(pantryIngredientsProvider);
    if (pantryItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add ingredients first')));
      return;
    }

    // Set pantry ingredients as session ingredients
    final pantryNames = pantryItems.map((e) => e.name).toList();
    ref.read(sessionIngredientsProvider.notifier).setIngredients(pantryNames);

    // Navigate to recipes tab
    switchToRecipeTab(context);
  }

  void _shareList(BuildContext context, WidgetRef ref) {
    final pantryItems = ref.read(pantryIngredientsProvider);
    if (pantryItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your pantry is empty')));
      return;
    }

    // TODO: Use share_plus package when added
    // final text = 'My Pantry:\n${pantryItems.map((item) => '• ${item.name}').join('\n')}';
    // Share.share(text, subject: 'My Pantry List');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
