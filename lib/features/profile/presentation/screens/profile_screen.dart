import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/cooking_stats_card.dart';
import '../widgets/dietary_restrictions_card.dart';
import '../widgets/skill_level_card.dart';
import '../widgets/cuisine_preference_card.dart';
import '../widgets/account_info_card.dart';

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
          // Profile header with stats
          const ProfileHeaderCard(),
          const SizedBox(height: 16),

          // Cooking stats
          const CookingStatsCard(),
          const SizedBox(height: 24),

          // Section: Account
          _buildSectionHeader('Account', Icons.account_circle, theme),
          const SizedBox(height: 12),

          // Account information
          const AccountInfoCard(),
          const SizedBox(height: 24),

          // Section: Preferences
          _buildSectionHeader('Preferences', Icons.tune, theme),
          const SizedBox(height: 12),

          // Dietary Restrictions
          DietaryRestrictionsCard(
            selectedRestrictions: profile.restrictions,
            onChanged: (restrictions) {
              ref
                  .read(dietaryProfileProvider.notifier)
                  .updateRestrictions(restrictions);
            },
          ),
          const SizedBox(height: 16),

          // Skill Level
          SkillLevelCard(
            selectedLevels: profile.skillLevels,
            onChanged: (levels) {
              ref.read(dietaryProfileProvider.notifier).updateSkillLevels(levels);
            },
          ),
          const SizedBox(height: 16),

          // Cuisine Preference
          CuisinePreferenceCard(
            selectedCuisines: profile.cuisinePreferences,
            onChanged: (cuisines) {
              ref
                  .read(dietaryProfileProvider.notifier)
                  .updateCuisinePreferences(cuisines);
            },
          ),
          const SizedBox(height: 24),

          // Section: Appearance
          _buildSectionHeader('Appearance', Icons.palette, theme),
          const SizedBox(height: 12),

          // Theme Mode
          Card(
            child: ListTile(
              leading: Icon(
                themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
              title: const Text('Theme'),
              subtitle: Text(
                themeMode == ThemeMode.dark ? 'Dark mode' : 'Light mode',
              ),
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

          // Section: Actions
          _buildSectionHeader('Actions', Icons.settings, theme),
          const SizedBox(height: 12),

          // Reset button
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset to Defaults'),
              subtitle: const Text('Reset all preferences to default values'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _resetProfile(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
        ],
      ),
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
