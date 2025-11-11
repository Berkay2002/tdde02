import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/firebase_provider.dart';
import '../../domain/entities/user_preferences.dart';
import '../providers/user_preferences_provider.dart';
import '../../../recipe_history/presentation/screens/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Essential preferences collected during onboarding
  String _skillLevel = 'intermediate';
  String _spiceTolerance = 'medium';
  final Set<String> _dietaryRestrictions = {};
  final Set<String> _favoriteCuisines = {};
  final Set<String> _excludedIngredients = {};

  // Default values for preferences not collected in onboarding
  final String _cookingTimePreference = 'moderate';
  final List<String> _favoriteProteins = [];
  final List<String> _kitchenEquipment = [];
  final int _servingSizePreference = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _skipOnboarding() async {
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Setup?'),
        content: const Text(
          'We\'ll use smart defaults for your preferences. You can customize them anytime in Settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Setup'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Skip'),
          ),
        ],
      ),
    );

    if (shouldSkip == true && mounted) {
      await _finishOnboarding(useDefaults: true);
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding({bool useDefaults = false}) async {
    setState(() => _isLoading = true);

    try {
      final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found. Please sign in again.')),
          );
        }
        return;
      }

      final preferences = UserPreferences(
        userId: userId,
        skillLevel: useDefaults ? 'intermediate' : _skillLevel,
        spiceTolerance: useDefaults ? 'medium' : _spiceTolerance,
        cookingTimePreference: _cookingTimePreference,
        dietaryRestrictions: useDefaults ? [] : _dietaryRestrictions.toList(),
        excludedIngredients: useDefaults ? [] : _excludedIngredients.toList(),
        favoriteCuisines: useDefaults ? [] : _favoriteCuisines.toList(),
        favoriteProteins: _favoriteProteins,
        kitchenEquipment: _kitchenEquipment,
        servingSizePreference: _servingSizePreference,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref
          .read(userPreferencesNotifierProvider.notifier)
          .updatePreferences(preferences);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress and skip
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _isLoading ? null : _previousPage,
                    ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                          Text(
                            'Step ${_currentPage + 1} of 5',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                            TextButton.icon(
                              onPressed: _isLoading ? null : _skipOnboarding,
                              icon: const Icon(Icons.skip_next, size: 18),
                              label: const Text('Skip'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / 5,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildSkillLevelPage(),
                  _buildDietaryRestrictionsPage(),
                  _buildSpiceTolerancePage(),
                  _buildFavoriteCuisinesPage(),
                  _buildExcludedIngredientsPage(),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _currentPage == 4 ? 'Get Cooking!' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 1: Skill Level
  Widget _buildSkillLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: Icon(
              Icons.restaurant_menu,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'What\'s your cooking skill level?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'This helps us suggest recipes that match your experience',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          _buildOptionCard(
            'Beginner',
            'Just starting out with simple recipes',
            Icons.star_outline,
            _skillLevel == 'beginner',
            () => setState(() => _skillLevel = 'beginner'),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildOptionCard(
            'Intermediate',
            'Comfortable with most cooking techniques',
            Icons.star_half,
            _skillLevel == 'intermediate',
            () => setState(() => _skillLevel = 'intermediate'),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildOptionCard(
            'Advanced',
            'Experienced and adventurous chef',
            Icons.star,
            _skillLevel == 'advanced',
            () => setState(() => _skillLevel = 'advanced'),
          ),
        ],
      ),
    );
  }

  // Page 2: Dietary Restrictions
  Widget _buildDietaryRestrictionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: Icon(
              Icons.set_meal,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Any dietary restrictions?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Select all that apply. We\'ll only suggest compatible recipes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              'Vegetarian',
              'Vegan',
              'Gluten-Free',
              'Dairy-Free',
              'Nut-Free',
              'Halal',
              'Kosher',
              'None',
            ].map((restriction) {
              final isSelected = restriction == 'None'
                  ? _dietaryRestrictions.isEmpty
                  : _dietaryRestrictions.contains(restriction);
              return FilterChip(
                label: Text(restriction),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (restriction == 'None') {
                      _dietaryRestrictions.clear();
                    } else {
                      if (selected) {
                        _dietaryRestrictions.add(restriction);
                      } else {
                        _dietaryRestrictions.remove(restriction);
                      }
                    }
                  });
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          if (_dietaryRestrictions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      '${_dietaryRestrictions.length} restriction${_dietaryRestrictions.length > 1 ? 's' : ''} selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Page 3: Spice Tolerance
  Widget _buildSpiceTolerancePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: Icon(
              Icons.local_fire_department,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'How spicy do you like it?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'We\'ll adjust recipe suggestions based on your preference',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          _buildSpiceOption(
            'None',
            'No spice for me, thanks',
            '😊',
            'none',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSpiceOption(
            'Mild',
            'Just a hint of spice',
            '🌶️',
            'mild',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSpiceOption(
            'Medium',
            'I like a good kick',
            '🌶️🌶️',
            'medium',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSpiceOption(
            'Hot',
            'Bring on the heat!',
            '🌶️🌶️🌶️',
            'hot',
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildSpiceOption(
            'Very Hot',
            'I love extra spicy food',
            '🔥🔥🔥',
            'very_hot',
          ),
        ],
      ),
    );
  }

  Widget _buildSpiceOption(
    String title,
    String subtitle,
    String emoji,
    String value,
  ) {
    final isSelected = _spiceTolerance == value;
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => setState(() => _spiceTolerance = value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Page 4: Favorite Cuisines
  Widget _buildFavoriteCuisinesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: Icon(
              Icons.public,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'What cuisines do you love?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Select your favorites to get personalized recipe suggestions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              'Italian',
              'Mexican',
              'Chinese',
              'Japanese',
              'Indian',
              'Thai',
              'French',
              'Mediterranean',
              'Korean',
              'Vietnamese',
              'American',
              'Greek',
              'Spanish',
              'Middle Eastern',
              'Caribbean',
              'Brazilian',
            ].map((cuisine) {
              final isSelected = _favoriteCuisines.contains(cuisine);
              return FilterChip(
                label: Text(cuisine),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _favoriteCuisines.add(cuisine);
                    } else {
                      _favoriteCuisines.remove(cuisine);
                    }
                  });
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          if (_favoriteCuisines.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      '${_favoriteCuisines.length} cuisine${_favoriteCuisines.length > 1 ? 's' : ''} selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    'You can skip this if you\'re open to all cuisines',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Page 5: Excluded Ingredients
  Widget _buildExcludedIngredientsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.defaultPadding),
          Center(
            child: Icon(
              Icons.block,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Any ingredients to avoid?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'We\'ll exclude recipes containing these ingredients',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              'Peanuts',
              'Tree Nuts',
              'Shellfish',
              'Fish',
              'Eggs',
              'Soy',
              'Wheat',
              'Sesame',
              'Mushrooms',
              'Cilantro',
              'Coconut',
              'Onions',
              'Garlic',
              'Tomatoes',
              'Bell Peppers',
              'Celery',
              'Olives',
              'Blue Cheese',
              'None',
            ].map((ingredient) {
              final isSelected = ingredient == 'None'
                  ? _excludedIngredients.isEmpty
                  : _excludedIngredients.contains(ingredient);
              return FilterChip(
                label: Text(ingredient),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (ingredient == 'None') {
                      _excludedIngredients.clear();
                    } else {
                      if (selected) {
                        _excludedIngredients.add(ingredient);
                      } else {
                        _excludedIngredients.remove(ingredient);
                      }
                    }
                  });
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          if (_excludedIngredients.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: AppConstants.defaultPadding),
                  Expanded(
                    child: Text(
                      '${_excludedIngredients.length} ingredient${_excludedIngredients.length > 1 ? 's' : ''} excluded',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppConstants.defaultPadding),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    'This is separate from dietary restrictions and helps personalize your experience',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    String title,
    String subtitle,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
