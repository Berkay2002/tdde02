import 'package:flutter/material.dart';

/// Enhanced dietary restrictions selector with icons and visual feedback
class DietaryRestrictionsCard extends StatelessWidget {
  final List<String> selectedRestrictions;
  final ValueChanged<List<String>> onChanged;

  const DietaryRestrictionsCard({
    required this.selectedRestrictions,
    required this.onChanged,
    super.key,
  });

  static const _restrictionsWithIcons = {
    'Vegetarian': '🥗',
    'Vegan': '🌱',
    'Gluten-Free': '🌾',
    'Dairy-Free': '🥛',
    'Nut-Free': '🥜',
    'Halal': '☪️',
    'Kosher': '✡️',
    'Low-Carb': '🔻',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dietary Restrictions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedRestrictions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedRestrictions.length} selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Customize recipes to fit your dietary needs',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Quick actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: () =>
                      onChanged(_restrictionsWithIcons.keys.toList()),
                  icon: const Icon(Icons.check_box, size: 18),
                  label: const Text('Select All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => onChanged([]),
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chips with icons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _restrictionsWithIcons.entries.map((entry) {
                final isSelected = selectedRestrictions.contains(entry.key);
                return FilterChip(
                  avatar: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 18),
                  ),
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (selected) {
                    final updated = List<String>.from(selectedRestrictions);
                    if (selected) {
                      updated.add(entry.key);
                    } else {
                      updated.remove(entry.key);
                    }
                    onChanged(updated);
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
