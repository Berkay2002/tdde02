import 'package:flutter/material.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/ingredient_category.dart';

/// Statistics card showing pantry overview
class PantryStatsCard extends StatelessWidget {
  final List<PantryItem> items;

  const PantryStatsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _calculateStats(items);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Pantry Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatColumn(
                  icon: Icons.inventory_2_outlined,
                  count: items.length,
                  label: 'Total Items',
                  color: theme.colorScheme.primary,
                ),
                _StatColumn(
                  icon: Icons.category_outlined,
                  count: stats.categoriesCount,
                  label: 'Categories',
                  color: Colors.orange,
                ),
                _StatColumn(
                  icon: Icons.fiber_new_outlined,
                  count: stats.freshCount,
                  label: 'Fresh',
                  color: Colors.green,
                ),
              ],
            ),
            if (stats.mostCommonCategory != null) ...[
              const Divider(height: 24),
              _buildInfoRow(
                theme,
                Icons.star_outline,
                'Most common: ${stats.mostCommonCategory}',
              ),
            ],
            if (stats.urgentCount > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                Icons.warning_amber_outlined,
                '${stats.urgentCount} items need attention',
                color: theme.colorScheme.error,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String text, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  _PantryStats _calculateStats(List<PantryItem> items) {
    if (items.isEmpty) {
      return _PantryStats(
        categoriesCount: 0,
        freshCount: 0,
        urgentCount: 0,
        mostCommonCategory: null,
      );
    }

    final categories = <IngredientCategory, int>{};
    var freshCount = 0;
    var urgentCount = 0;

    for (final item in items) {
      categories[item.category] = (categories[item.category] ?? 0) + 1;

      if (item.freshnessStatus == FreshnessStatus.fresh) {
        freshCount++;
      } else if (item.freshnessStatus == FreshnessStatus.urgent) {
        urgentCount++;
      }
    }

    String? mostCommonCategory;
    if (categories.isNotEmpty) {
      final sorted = categories.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostCommonCategory = IngredientCategoryHelper.getName(sorted.first.key);
    }

    return _PantryStats(
      categoriesCount: categories.length,
      freshCount: freshCount,
      urgentCount: urgentCount,
      mostCommonCategory: mostCommonCategory,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;
  final Color color;

  const _StatColumn({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
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

class _PantryStats {
  final int categoriesCount;
  final int freshCount;
  final int urgentCount;
  final String? mostCommonCategory;

  _PantryStats({
    required this.categoriesCount,
    required this.freshCount,
    required this.urgentCount,
    required this.mostCommonCategory,
  });
}
