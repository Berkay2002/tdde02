import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../widgets/quick_manual_input_sheet.dart';
import '../../../camera/presentation/screens/camera_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Quick Search'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'What do you want to cook?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan ingredients or enter them manually for quick recipe suggestions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Camera Scan Button
                _ActionCard(
                  icon: Icons.camera_alt,
                  title: 'Scan Ingredients',
                  description: 'Take a photo of your ingredients',
                  color: theme.colorScheme.primary,
                  onTap: () => _handleCameraScan(context, ref),
                ),
                const SizedBox(height: 16),

                // Manual Entry Button
                _ActionCard(
                  icon: Icons.edit_note,
                  title: 'Enter Manually',
                  description: 'Type your ingredients',
                  color: theme.colorScheme.secondary,
                  onTap: () => _handleManualEntry(context),
                ),

                const SizedBox(height: 48),

                // Current Session Ingredients (if any)
                if (sessionIngredients.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Current Search',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  FilledButton.icon(
                    onPressed: () => switchToRecipeTab(context),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('View Recipes'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action card widget for the home screen buttons
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
