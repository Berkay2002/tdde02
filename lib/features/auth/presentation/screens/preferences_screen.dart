import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_dialogs.dart';
import '../../domain/entities/user_preferences.dart';
import '../providers/user_preferences_provider.dart';

/// Screen for managing user cooking preferences
class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final _dietaryRestrictionsController = TextEditingController();
  final _excludedIngredientsController = TextEditingController();
  final _favoriteCuisinesController = TextEditingController();

  String _selectedSkillLevel = 'beginner';
  String _selectedSpiceTolerance = 'medium';
  String _selectedCookingTime = 'moderate';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _dietaryRestrictionsController.dispose();
    _excludedIngredientsController.dispose();
    _favoriteCuisinesController.dispose();
    super.dispose();
  }

  void _loadPreferences() {
    final prefsAsync = ref.read(userPreferencesNotifierProvider);
    prefsAsync.whenData((prefs) {
      if (prefs != null) {
        setState(() {
          _selectedSkillLevel = prefs.skillLevel;
          _selectedSpiceTolerance = prefs.spiceTolerance;
          _selectedCookingTime = prefs.cookingTimePreference;
          _dietaryRestrictionsController.text = prefs.dietaryRestrictions.join(
            ', ',
          );
          _excludedIngredientsController.text = prefs.excludedIngredients.join(
            ', ',
          );
          _favoriteCuisinesController.text = prefs.favoriteCuisines.join(', ');
        });
      }
    });
  }

  Future<void> _savePreferences() async {
    final currentPrefs = await ref.read(userPreferencesNotifierProvider.future);

    if (currentPrefs == null) return;

    final updatedPrefs = UserPreferences(
      userId: currentPrefs.userId,
      skillLevel: _selectedSkillLevel,
      spiceTolerance: _selectedSpiceTolerance,
      cookingTimePreference: _selectedCookingTime,
      dietaryRestrictions: _dietaryRestrictionsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      excludedIngredients: _excludedIngredientsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      favoriteCuisines: _favoriteCuisinesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      favoriteProteins: currentPrefs.favoriteProteins,
      kitchenEquipment: currentPrefs.kitchenEquipment,
      servingSizePreference: currentPrefs.servingSizePreference,
      createdAt: currentPrefs.createdAt,
      updatedAt: DateTime.now(),
    );

    await ref
        .read(userPreferencesNotifierProvider.notifier)
        .updatePreferences(updatedPrefs);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences saved successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(userPreferencesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooking Preferences'),
        actions: [
          TextButton(onPressed: _savePreferences, child: const Text('Save')),
        ],
      ),
      body: prefsAsync.when(
        data: (prefs) => _buildPreferencesForm(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Error loading preferences: $error')),
      ),
    );
  }

  Widget _buildPreferencesForm() {
    return ListView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      children: [
        _buildSection(
          title: 'Skill Level',
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'beginner',
                label: Text('Beginner'),
                icon: Icon(Icons.sentiment_satisfied),
              ),
              ButtonSegment(
                value: 'intermediate',
                label: Text('Intermediate'),
                icon: Icon(Icons.sentiment_neutral),
              ),
              ButtonSegment(
                value: 'advanced',
                label: Text('Advanced'),
                icon: Icon(Icons.emoji_events),
              ),
            ],
            selected: {_selectedSkillLevel},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _selectedSkillLevel = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),

        _buildSection(
          title: 'Spice Tolerance',
          subtitle: 'How spicy do you like your food?',
          child: InkWell(
            onTap: () => _showSpiceToleranceDialog(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      _getSpiceToleranceLabel(_selectedSpiceTolerance),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),

        _buildSection(
          title: 'Cooking Time Preference',
          subtitle: 'How much time do you typically have?',
          child: InkWell(
            onTap: () => _showCookingTimeDialog(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      _getCookingTimeLabel(_selectedCookingTime),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),

        _buildSection(
          title: 'Dietary Restrictions',
          subtitle: 'Separate multiple items with commas',
          child: TextField(
            controller: _dietaryRestrictionsController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., Vegetarian, Gluten-free, Dairy-free',
              prefixIcon: Icon(Icons.no_meals),
            ),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),

        _buildSection(
          title: 'Excluded Ingredients',
          subtitle: 'Ingredients you want to avoid',
          child: TextField(
            controller: _excludedIngredientsController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., Nuts, Shellfish, Mushrooms',
              prefixIcon: Icon(Icons.block),
            ),
            maxLines: 2,
          ),
        ),
        const SizedBox(height: AppConstants.largePadding),

        _buildSection(
          title: 'Favorite Cuisines',
          subtitle: 'Cuisines you enjoy most',
          child: TextField(
            controller: _favoriteCuisinesController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'e.g., Italian, Japanese, Mexican',
              prefixIcon: Icon(Icons.public),
            ),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  void _showSpiceToleranceDialog() {
    showDialog(
      context: context,
      builder: (context) => OptionSelectionDialog<String>(
        title: 'Spice Tolerance',
        subtitle: 'How spicy do you like your food?',
        icon: Icons.local_fire_department,
        selectedValue: _selectedSpiceTolerance,
        options: const [
          OptionItem(
            value: 'none',
            title: 'None',
            subtitle: 'No spice at all',
            icon: Icons.block,
          ),
          OptionItem(
            value: 'mild',
            title: 'Mild',
            subtitle: 'Just a hint of spice',
            icon: Icons.whatshot,
          ),
          OptionItem(
            value: 'medium',
            title: 'Medium',
            subtitle: 'Balanced heat level',
            icon: Icons.local_fire_department,
          ),
          OptionItem(
            value: 'hot',
            title: 'Hot',
            subtitle: 'Bring on the heat!',
            icon: Icons.local_fire_department,
          ),
          OptionItem(
            value: 'very_hot',
            title: 'Very Hot',
            subtitle: 'Extra spicy challenge',
            icon: Icons.whatshot,
          ),
        ],
        onSelected: (value) {
          setState(() {
            _selectedSpiceTolerance = value;
          });
        },
      ),
    );
  }

  void _showCookingTimeDialog() {
    showDialog(
      context: context,
      builder: (context) => OptionSelectionDialog<String>(
        title: 'Cooking Time Preference',
        subtitle: 'How much time do you typically have?',
        icon: Icons.schedule,
        selectedValue: _selectedCookingTime,
        options: const [
          OptionItem(
            value: 'quick',
            title: 'Quick',
            subtitle: 'Under 30 minutes',
            icon: Icons.flash_on,
          ),
          OptionItem(
            value: 'moderate',
            title: 'Moderate',
            subtitle: '30-60 minutes',
            icon: Icons.schedule,
          ),
          OptionItem(
            value: 'long',
            title: 'Long',
            subtitle: 'Over 60 minutes',
            icon: Icons.timer,
          ),
        ],
        onSelected: (value) {
          setState(() {
            _selectedCookingTime = value;
          });
        },
      ),
    );
  }

  String _getSpiceToleranceLabel(String value) {
    switch (value) {
      case 'none':
        return 'None - No spice';
      case 'mild':
        return 'Mild';
      case 'medium':
        return 'Medium';
      case 'hot':
        return 'Hot';
      case 'very_hot':
        return 'Very Hot';
      default:
        return 'Medium';
    }
  }

  String _getCookingTimeLabel(String value) {
    switch (value) {
      case 'quick':
        return 'Quick (< 30 min)';
      case 'moderate':
        return 'Moderate (30-60 min)';
      case 'long':
        return 'Long (> 60 min)';
      default:
        return 'Moderate (30-60 min)';
    }
  }
}
