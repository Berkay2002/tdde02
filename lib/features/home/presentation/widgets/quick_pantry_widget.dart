import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';

/// Quick pantry widget showing pantry preview with actions
class QuickPantryWidget extends ConsumerWidget {
  const QuickPantryWidget({super.key});

  // Simple category detection
  IconData _getIngredientIcon(String name) {
    final lower = name.toLowerCase();

    // Vegetables
    if (lower.contains('tomato') ||
        lower.contains('onion') ||
        lower.contains('pepper') ||
        lower.contains('lettuce') ||
        lower.contains('carrot') ||
        lower.contains('broccoli') ||
        lower.contains('spinach')) {
      return Icons.eco;
    }

    // Proteins
    if (lower.contains('chicken') ||
        lower.contains('beef') ||
        lower.contains('pork') ||
        lower.contains('fish') ||
        lower.contains('egg') ||
        lower.contains('tofu')) {
      return Icons.restaurant;
    }

    // Dairy
    if (lower.contains('milk') ||
        lower.contains('cheese') ||
        lower.contains('yogurt') ||
        lower.contains('butter') ||
        lower.contains('cream')) {
      return Icons.water_drop;
    }

    // Grains
    if (lower.contains('rice') ||
        lower.contains('pasta') ||
        lower.contains('bread') ||
        lower.contains('noodle')) {
      return Icons.grain;
    }

    // Herbs & spices
    if (lower.contains('basil') ||
        lower.contains('garlic') ||
        lower.contains('ginger') ||
        lower.contains('herb') ||
        lower.contains('spice')) {
      return Icons.spa;
    }

    // Fruits
    if (lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('berry') ||
        lower.contains('orange') ||
        lower.contains('lemon')) {
      return Icons.apple;
    }

    // Default
    return Icons.fastfood;
  }

  Color _getIngredientColor(String name) {
    final lower = name.toLowerCase();

    // Vegetables - green
    if (lower.contains('tomato') ||
        lower.contains('onion') ||
        lower.contains('pepper') ||
        lower.contains('lettuce') ||
        lower.contains('carrot') ||
        lower.contains('broccoli') ||
        lower.contains('spinach')) {
      return const Color(0xFF4CAF50);
    }

    // Proteins - red
    if (lower.contains('chicken') ||
        lower.contains('beef') ||
        lower.contains('pork') ||
        lower.contains('fish') ||
        lower.contains('egg') ||
        lower.contains('tofu')) {
      return const Color(0xFFF44336);
    }

    // Dairy - blue
    if (lower.contains('milk') ||
        lower.contains('cheese') ||
        lower.contains('yogurt') ||
        lower.contains('butter') ||
        lower.contains('cream')) {
      return const Color(0xFF2196F3);
    }

    // Grains - orange
    if (lower.contains('rice') ||
        lower.contains('pasta') ||
        lower.contains('bread') ||
        lower.contains('noodle')) {
      return const Color(0xFFFF9800);
    }

    // Herbs - teal
    if (lower.contains('basil') ||
        lower.contains('garlic') ||
        lower.contains('ginger') ||
        lower.contains('herb') ||
        lower.contains('spice')) {
      return const Color(0xFF009688);
    }

    // Fruits - purple
    if (lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('berry') ||
        lower.contains('orange') ||
        lower.contains('lemon')) {
      return const Color(0xFF9C27B0);
    }

    // Default - gray
    return const Color(0xFF757575);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pantryItems = ref.watch(pantryIngredientsProvider);

    if (pantryItems.isEmpty) {
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(
                Icons.kitchen_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Your pantry is empty',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add ingredients to get started',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => switchToPantryTab(context),
                icon: const Icon(Icons.add),
                label: const Text('Go to Pantry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show up to 5 items
    final displayItems = pantryItems.take(5).toList();

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Pantry',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => switchToPantryTab(context),
                  child: const Text('View All'),
                ),
              ],
            ),

            Text(
              '${pantryItems.length} ${pantryItems.length == 1 ? 'item' : 'items'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 16),

            // Items grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: displayItems.map((item) {
                final icon = _getIngredientIcon(item.name);
                final color = _getIngredientColor(item.name);

                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(width: 6),
                      Text(
                        item.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (pantryItems.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                '+${pantryItems.length - 5} more',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action button
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  // Set pantry ingredients as session ingredients
                  final pantryNames = pantryItems.map((e) => e.name).toList();
                  ref
                      .read(sessionIngredientsProvider.notifier)
                      .setIngredients(pantryNames);

                  // Navigate to recipes tab
                  switchToRecipeTab(context);
                },
                icon: const Icon(Icons.search),
                label: const Text('Use These in Recipe'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
