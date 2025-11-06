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

  // Essential preferences collected during onboarding
  String _skillLevel = 'intermediate'; // Smart default: most common
  final Set<String> _dietaryRestrictions = {};

  // Deferred preferences with smart defaults (collected contextually later)
  final String _spiceTolerance = 'medium'; // Safe default
  final String _cookingTimePreference = 'moderate'; // Middle ground
  final List<String> _excludedIngredients = []; // Empty by default
  final List<String> _favoriteCuisines = []; // Collect when relevant
  final List<String> _favoriteProteins = []; // Collect when relevant
  final List<String> _kitchenEquipment = []; // Infer from usage
  final int _servingSizePreference = 2; // Typical couple/small family

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      // Only 2 pages now (0 and 1)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    // Allow users to skip and use defaults
    _finishOnboarding();
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
      excludedIngredients: _excludedIngredients,
      favoriteCuisines: _favoriteCuisines,
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
                      value: (_currentPage + 1) / 2,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),

            // Pages - Streamlined to 2 essential pages
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
                  _buildQuickSetupPage(), // Skill + Dietary in one page
                  _buildWelcomeSummaryPage(), // Summary and celebration
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
                  _currentPage == 1 ? 'Get Cooking!' : 'Continue',
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

  // Page 1: Quick Setup - Essential preferences only
  Widget _buildQuickSetupPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Setup',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Just the essentials to get you started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppConstants.largePadding * 1.5),

          // Skill Level Section
          Text(
            'What\'s your cooking skill level?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          _buildOptionCard(
            'Beginner',
            'Just starting out with simple recipes',
            Icons.star_outline,
            _skillLevel == 'beginner',
            () => setState(() => _skillLevel = 'beginner'),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildOptionCard(
            'Intermediate',
            'Comfortable with most cooking techniques',
            Icons.star_half,
            _skillLevel == 'intermediate',
            () => setState(() => _skillLevel = 'intermediate'),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildOptionCard(
            'Advanced',
            'Experienced and adventurous chef',
            Icons.star,
            _skillLevel == 'advanced',
            () => setState(() => _skillLevel = 'advanced'),
          ),

          const SizedBox(height: AppConstants.largePadding * 2),

          // Dietary Restrictions Section
          Text(
            'Any dietary restrictions?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Optional - we\'ll only suggest compatible recipes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'Vegetarian',
                  'Vegan',
                  'Gluten-Free',
                  'Dairy-Free',
                  'Nut-Free',
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
                  );
                }).toList(),
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Info box
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                Expanded(
                  child: Text(
                    'You can customize more preferences later in your profile',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
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

  // Page 2: Welcome Summary - Celebration & app capabilities
  Widget _buildWelcomeSummaryPage() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: AppConstants.largePadding * 2),

          Text(
            'You\'re all set!',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          Text(
            'Here\'s what you can do now:',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.largePadding * 2),

          // Feature highlights
          _buildFeatureHighlight(
            icon: Icons.camera_alt,
            title: 'Scan Your Fridge',
            description: 'Snap a photo to instantly detect ingredients',
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          _buildFeatureHighlight(
            icon: Icons.auto_awesome,
            title: 'Get AI Recipes',
            description: 'Personalized recipes based on what you have',
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          _buildFeatureHighlight(
            icon: Icons.bookmark,
            title: 'Save Favorites',
            description: 'Keep track of recipes you love',
          ),

          const Spacer(),

          // Info text
          Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Text(
                    'Customize more preferences anytime in Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildFeatureHighlight({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
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
                    ? Theme.of(context).colorScheme.primary
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
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
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
