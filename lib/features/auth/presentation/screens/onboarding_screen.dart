import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/providers/supabase_provider.dart';
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

  // User preferences data
  String _skillLevel = 'beginner';
  String _spiceTolerance = 'medium';
  String _cookingTimePreference = 'moderate';
  final Set<String> _dietaryRestrictions = {};
  final Set<String> _excludedIngredients = {};
  final Set<String> _favoriteCuisines = {};
  final Set<String> _favoriteProteins = {};
  final Set<String> _kitchenEquipment = {};
  int _servingSizePreference = 2;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final userId = ref.read(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return;

    final preferences = UserPreferences(
      userId: userId,
      skillLevel: _skillLevel,
      spiceTolerance: _spiceTolerance,
      cookingTimePreference: _cookingTimePreference,
      dietaryRestrictions: _dietaryRestrictions.toList(),
      excludedIngredients: _excludedIngredients.toList(),
      favoriteCuisines: _favoriteCuisines.toList(),
      favoriteProteins: _favoriteProteins.toList(),
      kitchenEquipment: _kitchenEquipment.toList(),
      servingSizePreference: _servingSizePreference,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(userPreferencesNotifierProvider.notifier).updatePreferences(preferences);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _previousPage,
                    ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 6,
                      backgroundColor: Colors.grey[300],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Skip'),
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
                  _buildWelcomePage(),
                  _buildSkillLevelPage(),
                  _buildDietaryPage(),
                  _buildCuisinePage(),
                  _buildKitchenPage(),
                  _buildServingSizePage(),
                ],
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage == 5 ? 'Get Started' : 'Continue',
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

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waving_hand,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Welcome!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            "Let's personalize your cooking experience. We'll ask a few questions to tailor recipes just for you.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkillLevelPage() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your cooking skill level?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'This helps us suggest recipes that match your experience.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildOptionCard(
            'Beginner',
            'Just starting out',
            Icons.star_outline,
            _skillLevel == 'beginner',
            () => setState(() => _skillLevel = 'beginner'),
          ),
          _buildOptionCard(
            'Intermediate',
            'Comfortable in the kitchen',
            Icons.star_half,
            _skillLevel == 'intermediate',
            () => setState(() => _skillLevel = 'intermediate'),
          ),
          _buildOptionCard(
            'Advanced',
            'Experienced home chef',
            Icons.star,
            _skillLevel == 'advanced',
            () => setState(() => _skillLevel = 'advanced'),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Spice Tolerance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            children: ['none', 'mild', 'medium', 'hot', 'very_hot'].map((level) {
              final labels = {
                'none': '🚫 None',
                'mild': '🌶️ Mild',
                'medium': '🌶️🌶️ Medium',
                'hot': '🌶️🌶️🌶️ Hot',
                'very_hot': '🌶️🌶️🌶️🌶️ Very Hot',
              };
              return ChoiceChip(
                label: Text(labels[level]!),
                selected: _spiceTolerance == level,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _spiceTolerance = level);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Cooking Time Preference',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            children: ['quick', 'moderate', 'long'].map((time) {
              final labels = {
                'quick': '⚡ Quick (<30 min)',
                'moderate': '⏱️ Moderate (30-60 min)',
                'long': '🕐 Long (60+ min)',
              };
              return ChoiceChip(
                label: Text(labels[time]!),
                selected: _cookingTimePreference == time,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _cookingTimePreference = time);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPage() {
    final restrictions = [
      'Vegetarian',
      'Vegan',
      'Gluten-Free',
      'Dairy-Free',
      'Nut-Free',
      'Halal',
      'Kosher',
      'Low-Carb',
      'Keto',
      'Paleo',
    ];

    final commonAllergens = [
      'Peanuts',
      'Tree Nuts',
      'Shellfish',
      'Fish',
      'Eggs',
      'Soy',
      'Wheat',
      'Dairy',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Select any dietary restrictions or preferences.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: restrictions.map((restriction) {
              final isSelected = _dietaryRestrictions.contains(restriction);
              return FilterChip(
                label: Text(restriction),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _dietaryRestrictions.add(restriction);
                    } else {
                      _dietaryRestrictions.remove(restriction);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Text(
            'Ingredients to Avoid',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'We\'ll exclude recipes containing these ingredients.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: commonAllergens.map((ingredient) {
              final isSelected = _excludedIngredients.contains(ingredient);
              return FilterChip(
                label: Text(ingredient),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _excludedIngredients.add(ingredient);
                    } else {
                      _excludedIngredients.remove(ingredient);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinePage() {
    final cuisines = [
      '🍕 Italian',
      '🍜 Chinese',
      '🍛 Indian',
      '🍣 Japanese',
      '🌮 Mexican',
      '🥖 French',
      '🍔 American',
      '🥙 Mediterranean',
      '🍲 Thai',
      '🍖 Korean',
      '🥘 Spanish',
      '🍝 Greek',
    ];

    final proteins = [
      '🍗 Chicken',
      '🥩 Beef',
      '🐷 Pork',
      '🐟 Fish',
      '🦐 Seafood',
      '🥚 Eggs',
      '🫘 Beans',
      '🌱 Tofu',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite Cuisines',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'What types of food do you love?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cuisines.map((cuisine) {
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
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Text(
            'Favorite Proteins',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: proteins.map((protein) {
              final isSelected = _favoriteProteins.contains(protein);
              return FilterChip(
                label: Text(protein),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _favoriteProteins.add(protein);
                    } else {
                      _favoriteProteins.remove(protein);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenPage() {
    final equipment = [
      'Oven',
      'Microwave',
      'Air Fryer',
      'Slow Cooker',
      'Pressure Cooker',
      'Blender',
      'Food Processor',
      'Stand Mixer',
      'Grill',
      'Wok',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kitchen Equipment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'What equipment do you have available?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: equipment.map((item) {
              final isSelected = _kitchenEquipment.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _kitchenEquipment.add(item);
                    } else {
                      _kitchenEquipment.remove(item);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServingSizePage() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default Serving Size',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'How many people do you typically cook for?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: AppConstants.largePadding * 2),
          Center(
            child: Column(
              children: [
                Text(
                  '$_servingSizePreference',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: AppConstants.smallPadding),
                Text(
                  _servingSizePreference == 1 ? 'person' : 'people',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.largePadding),
                Slider(
                  value: _servingSizePreference.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: '$_servingSizePreference',
                  onChanged: (value) {
                    setState(() {
                      _servingSizePreference = value.toInt();
                    });
                  },
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    'You can adjust serving sizes for individual recipes later.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
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
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
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
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
