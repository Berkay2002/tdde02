import 'package:flutter/material.dart';

/// Cuisine preference selector with search and multi-select grid layout
class CuisinePreferenceCard extends StatefulWidget {
  final List<String> selectedCuisines;
  final ValueChanged<List<String>> onChanged;

  const CuisinePreferenceCard({
    required this.selectedCuisines,
    required this.onChanged,
    super.key,
  });

  @override
  State<CuisinePreferenceCard> createState() => _CuisinePreferenceCardState();
}

class _CuisinePreferenceCardState extends State<CuisinePreferenceCard> {
  String _searchQuery = '';

  static const _cuisinesWithIcons = {
    'Italian': '🍝',
    'Asian': '🍜',
    'Mexican': '🌮',
    'Mediterranean': '🌍',
    'American': '🍔',
    'Indian': '🍛',
    'French': '🥖',
    'Thai': '🌶️',
    'Japanese': '🍱',
    'Middle Eastern': '🥙',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCuisines = _searchQuery.isEmpty
        ? _cuisinesWithIcons.entries.toList()
        : _cuisinesWithIcons.entries
              .where(
                (e) => e.key.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Preferred Cuisines',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select one or more cuisines (tap to toggle)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search cuisines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),

            // Clear all button (if any selected)
            if (widget.selectedCuisines.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () => widget.onChanged([]),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear all'),
                ),
              ),

            // Cuisine grid
            if (filteredCuisines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'No cuisines found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filteredCuisines.map((entry) {
                  final isSelected = widget.selectedCuisines.contains(
                    entry.key,
                  );
                  return FilterChip(
                    avatar: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 18),
                    ),
                    label: Text(entry.key),
                    selected: isSelected,
                    onSelected: (_) {
                      final newSelection = List<String>.from(
                        widget.selectedCuisines,
                      );
                      if (isSelected) {
                        newSelection.remove(entry.key);
                      } else {
                        newSelection.add(entry.key);
                      }
                      widget.onChanged(newSelection);
                    },
                    showCheckmark: true,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
