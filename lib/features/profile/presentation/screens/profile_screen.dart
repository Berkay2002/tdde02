import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/theme_provider.dart';

/// ProfileScreen - Tab 5
///
/// Manages dietary profile and user preferences.
/// Users can set dietary restrictions, skill level, and cuisine preferences.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(dietaryProfileProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Customize your cooking preferences',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Dietary Restrictions
          _buildSectionTitle('Dietary Restrictions', theme),
          const SizedBox(height: 8),
          _DietaryRestrictionsSelector(
            selectedRestrictions: profile.restrictions,
            onChanged: (restrictions) {
              ref
                  .read(dietaryProfileProvider.notifier)
                  .updateRestrictions(restrictions);
            },
          ),
          const SizedBox(height: 24),

          // Skill Level
          _buildSectionTitle('Cooking Skill Level', theme),
          const SizedBox(height: 8),
          _SkillLevelSelector(
            selectedLevel: profile.skillLevel,
            onChanged: (level) {
              ref.read(dietaryProfileProvider.notifier).updateSkillLevel(level);
            },
          ),
          const SizedBox(height: 24),

          // Cuisine Preference
          _buildSectionTitle('Preferred Cuisine', theme),
          const SizedBox(height: 8),
          _CuisinePreferenceSelector(
            selectedCuisine: profile.cuisinePreference,
            onChanged: (cuisine) {
              ref
                  .read(dietaryProfileProvider.notifier)
                  .updateCuisinePreference(cuisine);
            },
          ),
          const SizedBox(height: 24),

          // Theme Mode
          _buildSectionTitle('Appearance', theme),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Theme'),
              trailing: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode, size: 16),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode, size: 16),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selected) {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(selected.first);
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Reset button
          OutlinedButton.icon(
            onPressed: () => _resetProfile(context, ref),
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _resetProfile(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile?'),
        content: const Text(
          'This will reset all your preferences to defaults.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(dietaryProfileProvider.notifier).reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// Dietary Restrictions Selector
class _DietaryRestrictionsSelector extends StatelessWidget {
  final List<String> selectedRestrictions;
  final ValueChanged<List<String>> onChanged;

  const _DietaryRestrictionsSelector({
    required this.selectedRestrictions,
    required this.onChanged,
  });

  static const _restrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Dairy-Free',
    'Nut-Free',
    'Halal',
    'Kosher',
    'Low-Carb',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _restrictions.map((restriction) {
            final isSelected = selectedRestrictions.contains(restriction);
            return FilterChip(
              label: Text(restriction),
              selected: isSelected,
              onSelected: (selected) {
                final newRestrictions = List<String>.from(selectedRestrictions);
                if (selected) {
                  newRestrictions.add(restriction);
                } else {
                  newRestrictions.remove(restriction);
                }
                onChanged(newRestrictions);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Skill Level Selector
class _SkillLevelSelector extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onChanged;

  const _SkillLevelSelector({
    required this.selectedLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Beginner'),
            subtitle: const Text('Simple recipes with basic techniques'),
            value: 'beginner',
            groupValue: selectedLevel,
            onChanged: (value) => onChanged(value!),
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Intermediate'),
            subtitle: const Text('Moderate complexity and cooking time'),
            value: 'intermediate',
            groupValue: selectedLevel,
            onChanged: (value) => onChanged(value!),
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: const Text('Advanced'),
            subtitle: const Text('Complex recipes and techniques'),
            value: 'advanced',
            groupValue: selectedLevel,
            onChanged: (value) => onChanged(value!),
          ),
        ],
      ),
    );
  }
}

// Cuisine Preference Selector
class _CuisinePreferenceSelector extends StatelessWidget {
  final String? selectedCuisine;
  final ValueChanged<String?> onChanged;

  const _CuisinePreferenceSelector({
    required this.selectedCuisine,
    required this.onChanged,
  });

  static const _cuisines = [
    'Italian',
    'Asian',
    'Mexican',
    'Mediterranean',
    'American',
    'Indian',
    'French',
    'Thai',
    'Japanese',
    'Middle Eastern',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('No Preference'),
            trailing: Radio<String?>(
              value: null,
              groupValue: selectedCuisine,
              onChanged: onChanged,
            ),
            onTap: () => onChanged(null),
          ),
          ..._cuisines.map((cuisine) {
            return ListTile(
              title: Text(cuisine),
              trailing: Radio<String?>(
                value: cuisine,
                groupValue: selectedCuisine,
                onChanged: onChanged,
              ),
              onTap: () => onChanged(cuisine),
            );
          }),
        ],
      ),
    );
  }
}
