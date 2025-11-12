import 'package:flutter/material.dart';

/// Filter chips widget for filtering favorite recipes by cuisine, difficulty, and time
class FavoritesFilterChips extends StatelessWidget {
  final Set<String> selectedFilters;
  final ValueChanged<Set<String>> onFiltersChanged;

  const FavoritesFilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filters = [
      _FilterOption(
        label: 'All',
        value: 'all',
        icon: Icons.grid_view,
      ),
      _FilterOption(
        label: 'Italian',
        value: 'italian',
        icon: Icons.local_pizza,
      ),
      _FilterOption(
        label: 'Asian',
        value: 'asian',
        icon: Icons.ramen_dining,
      ),
      _FilterOption(
        label: 'Mexican',
        value: 'mexican',
        icon: Icons.lunch_dining,
      ),
      _FilterOption(
        label: 'Mediterranean',
        value: 'mediterranean',
        icon: Icons.water_drop,
      ),
      _FilterOption(
        label: 'American',
        value: 'american',
        icon: Icons.fastfood,
      ),
      _FilterOption(
        label: 'Easy',
        value: 'easy',
        icon: Icons.sentiment_satisfied,
      ),
      _FilterOption(
        label: '< 30 min',
        value: '< 30 min',
        icon: Icons.timer,
      ),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isAll = filter.value == 'all';
          final isSelected = isAll
              ? selectedFilters.isEmpty
              : selectedFilters.contains(filter.value);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter.icon, size: 18),
                  const SizedBox(width: 6),
                  Text(filter.label),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newFilters = Set<String>.from(selectedFilters);

                if (isAll) {
                  // Clear all filters
                  onFiltersChanged({});
                } else {
                  if (selected) {
                    newFilters.add(filter.value);
                  } else {
                    newFilters.remove(filter.value);
                  }
                  onFiltersChanged(newFilters);
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final String value;
  final IconData icon;

  const _FilterOption({
    required this.label,
    required this.value,
    required this.icon,
  });
}
