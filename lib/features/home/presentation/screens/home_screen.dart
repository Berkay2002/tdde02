import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../widgets/quick_manual_input_sheet.dart';
import '../../../camera/presentation/screens/camera_screen.dart';
import '../widgets/personalized_greeting_card.dart';
import '../widgets/quick_pantry_widget.dart';
import '../widgets/recent_recipes_widget.dart';
import '../widgets/empty_home_widget.dart';
import '../widgets/quick_tip_widget.dart';

/// HomeScreen - Tab 1
///
/// Quick scan or manual entry for session-based recipe search.
/// This screen launches the camera or manual input modal and sends
/// the results to sessionIngredients, then switches to the Recipes tab.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _handleCameraScan(BuildContext context, WidgetRef ref) async {
    // Launch camera modal
    final ingredients = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(mode: CameraMode.quickScan),
      ),
    );

    if (ingredients != null && ingredients.isNotEmpty && context.mounted) {
      // Send to Brain's sessionIngredients
      ref.read(sessionIngredientsProvider.notifier).setIngredients(ingredients);

      // Switch to Recipes tab
      switchToRecipeTab(context);
    }
  }

  void _handleManualEntry(BuildContext context) {
    // Launch manual input modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickManualInputSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sessionIngredients = ref.watch(sessionIngredientsProvider);
    final pantryItems = ref.watch(pantryIngredientsProvider);
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);

    // Determine if user is new (no pantry, no favorites, no session)
    final isNewUser =
        pantryItems.isEmpty &&
        favoriteRecipes.isEmpty &&
        sessionIngredients.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personalized greeting with stats
                const PersonalizedGreetingCard(),
                const SizedBox(height: 24),

                // Quick tip
                if (!isNewUser) ...[
                  const QuickTipWidget(),
                  const SizedBox(height: 16),
                ],

                // For new users, show empty state
                if (isNewUser) ...[
                  EmptyHomeWidget(
                    onGetStarted: () => _handleCameraScan(context, ref),
                  ),
                  const SizedBox(height: 24),
                ],

                // Main action cards with gradient backgrounds
                Text(
                  'What do you want to cook?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Camera Scan Button - Primary action with gradient
                _ActionCard(
                  icon: Icons.camera_alt,
                  title: 'Scan Ingredients',
                  description: 'Take a photo of your ingredients',
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _handleCameraScan(context, ref),
                ),
                const SizedBox(height: 12),

                // Manual Entry Button - Secondary action with gradient
                _ActionCard(
                  icon: Icons.edit_note,
                  title: 'Enter Manually',
                  description: 'Type your ingredients quickly',
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade600, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () => _handleManualEntry(context),
                ),

                const SizedBox(height: 24),

                // Current Session Ingredients (if any)
                if (sessionIngredients.isNotEmpty) ...[
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Search',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (sessionIngredients.length > 1)
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                          sessionIngredientsProvider.notifier,
                                        )
                                        .clear();
                                  },
                                  child: const Text('Clear All'),
                                ),
                            ],
                          ),
                          Text(
                            '${sessionIngredients.length} ${sessionIngredients.length == 1 ? 'ingredient' : 'ingredients'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: sessionIngredients.map((ingredient) {
                              return Chip(
                                label: Text(ingredient),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  ref
                                      .read(sessionIngredientsProvider.notifier)
                                      .removeIngredient(ingredient);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => switchToRecipeTab(context),
                              icon: const Icon(Icons.search),
                              label: const Text('Find Recipes'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Quick pantry access
                if (!isNewUser) ...[
                  const QuickPantryWidget(),
                  const SizedBox(height: 24),
                ],

                // Recent favorites
                if (favoriteRecipes.isNotEmpty) ...[
                  const RecentRecipesWidget(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action card widget for the home screen buttons with gradient background
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.8),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
