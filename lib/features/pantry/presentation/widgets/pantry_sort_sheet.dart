import 'package:flutter/material.dart';

enum PantrySortOption {
  alphabeticalAZ,
  alphabeticalZA,
  recentlyAdded,
  byCategory,
  byFreshness,
}

class PantrySortSheet extends StatelessWidget {
  final PantrySortOption currentSort;
  final ValueChanged<PantrySortOption> onSortChanged;

  const PantrySortSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Sort by',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          _buildSortOption(
            context,
            PantrySortOption.alphabeticalAZ,
            Icons.sort_by_alpha,
            'A to Z',
          ),
          _buildSortOption(
            context,
            PantrySortOption.alphabeticalZA,
            Icons.sort_by_alpha,
            'Z to A',
          ),
          _buildSortOption(
            context,
            PantrySortOption.recentlyAdded,
            Icons.access_time,
            'Recently Added',
          ),
          _buildSortOption(
            context,
            PantrySortOption.byCategory,
            Icons.category,
            'By Category',
          ),
          _buildSortOption(
            context,
            PantrySortOption.byFreshness,
            Icons.fiber_new,
            'By Freshness',
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    PantrySortOption option,
    IconData icon,
    String label,
  ) {
    final isSelected = currentSort == option;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        onSortChanged(option);
        Navigator.pop(context);
      },
    );
  }
}

extension PantrySortOptionExtension on PantrySortOption {
  String get displayName {
    switch (this) {
      case PantrySortOption.alphabeticalAZ:
        return 'A-Z';
      case PantrySortOption.alphabeticalZA:
        return 'Z-A';
      case PantrySortOption.recentlyAdded:
        return 'Recent';
      case PantrySortOption.byCategory:
        return 'Category';
      case PantrySortOption.byFreshness:
        return 'Freshness';
    }
  }
}
