import 'package:flutter/material.dart';

/// Skill level data model
class SkillLevelData {
  final String value;
  final String label;
  final String description;
  final IconData icon;

  const SkillLevelData({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
  });
}

/// Visual skill level selector with multi-select support
class SkillLevelCard extends StatelessWidget {
  final List<String> selectedLevels;
  final ValueChanged<List<String>> onChanged;

  const SkillLevelCard({
    required this.selectedLevels,
    required this.onChanged,
    super.key,
  });

  static const _levels = [
    SkillLevelData(
      value: 'beginner',
      label: 'Beginner',
      description: 'Simple recipes with basic techniques',
      icon: Icons.egg,
    ),
    SkillLevelData(
      value: 'intermediate',
      label: 'Intermediate',
      description: 'Moderate complexity and cooking time',
      icon: Icons.restaurant,
    ),
    SkillLevelData(
      value: 'advanced',
      label: 'Advanced',
      description: 'Complex recipes and techniques',
      icon: Icons.whatshot,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cooking Skill Levels',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select all skill levels you\'re comfortable with',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Clear all button (if any selected)
            if (selectedLevels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () => onChanged([]),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear all'),
                ),
              ),

            // Skill level chips in a row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _levels.map((level) {
                final isSelected = selectedLevels.contains(level.value);

                return FilterChip(
                  avatar: Icon(level.icon, size: 20),
                  label: Text(level.label),
                  selected: isSelected,
                  onSelected: (_) {
                    final newSelection = List<String>.from(selectedLevels);
                    if (isSelected) {
                      newSelection.remove(level.value);
                    } else {
                      newSelection.add(level.value);
                    }
                    onChanged(newSelection);
                  },
                  showCheckmark: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Descriptions of selected levels
            if (selectedLevels.isNotEmpty)
              ...selectedLevels.map((value) {
                final level = _levels.firstWhere((l) => l.value == value);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          level.icon,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                level.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Select at least one skill level to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
