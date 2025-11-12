import 'package:flutter/material.dart';
import '../../../../core/constants/recipe_categories.dart';

class RecipeFilterChips extends StatelessWidget {
  final Set<String> selectedFilters;
  final ValueChanged<Set<String>> onFiltersChanged;

  const RecipeFilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  void _toggleFilter(String filter) {
    final newFilters = Set<String>.from(selectedFilters);
    if (newFilters.contains(filter)) {
      newFilters.remove(filter);
    } else {
      newFilters.add(filter);
    }
    onFiltersChanged(newFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All filter (clear all)
          _buildFilterChip(
            label: 'All',
            isSelected: selectedFilters.isEmpty,
            onTap: () => onFiltersChanged({}),
            theme: theme,
          ),
          const SizedBox(width: 8),

          // Difficulty filters
          _buildFilterChip(
            label: 'Easy',
            icon: Icons.sentiment_satisfied,
            color: RecipeCategoryHelper.getDifficultyColor(
              RecipeDifficulty.easy,
            ),
            isSelected: selectedFilters.contains('easy'),
            onTap: () => _toggleFilter('easy'),
            theme: theme,
          ),
          const SizedBox(width: 8),

          // Time filters
          _buildFilterChip(
            label: '< 30 min',
            icon: Icons.schedule,
            isSelected: selectedFilters.contains('quick'),
            onTap: () => _toggleFilter('quick'),
            theme: theme,
          ),
          const SizedBox(width: 8),

          // Cuisine filters
          ...RecipeCuisine.values
              .where((c) => c != RecipeCuisine.other)
              .take(5)
              .map((cuisine) {
                final cuisineName = RecipeCategoryHelper.getCuisineName(
                  cuisine,
                ).toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    label: RecipeCategoryHelper.getCuisineName(cuisine),
                    icon: RecipeCategoryHelper.getCuisineIcon(cuisine),
                    color: RecipeCategoryHelper.getCuisineColor(cuisine),
                    isSelected: selectedFilters.contains(cuisineName),
                    onTap: () => _toggleFilter(cuisineName),
                    theme: theme,
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    IconData? icon,
    Color? color,
  }) {
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      selectedColor: chipColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      visualDensity: VisualDensity.compact,
    );
  }
}
