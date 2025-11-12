import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ingredient_detection_provider.dart';
import '../widgets/ingredient_list_widget.dart';
import '../widgets/detection_loading_widget.dart';
import '../widgets/clarification_prompt_banner.dart';
import '../widgets/ingredient_item_card.dart';

/// Screen for reviewing and editing detected ingredients
class IngredientDetectionScreen extends ConsumerWidget {
  final String? imageId;
  final bool isPantryMode;

  const IngredientDetectionScreen({
    super.key,
    this.imageId,
    this.isPantryMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionState = ref.watch(ingredientDetectionProvider);
    
    // Debug logging
    print('IngredientDetectionScreen: Building with state:');
    print('  - Items: ${detectionState.detectedIngredients?.detectedItems.length ?? 0}');
    print('  - Ingredients list: ${detectionState.detectedIngredients?.ingredients.length ?? 0}');
    print('  - Error: ${detectionState.errorMessage}');
    print('  - Is loading: ${detectionState.isLoading}');

    return WillPopScope(
      onWillPop: () async {
        // Return true if pantry mode to signal confirmation
        if (isPantryMode) {
          Navigator.of(context).pop(true);
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isPantryMode ? 'Review Ingredients' : 'Detected Ingredients'),
          actions: [
            if (detectionState.detectedIngredients != null &&
                detectionState.detectedIngredients!.ingredients.isNotEmpty)
              if (isPantryMode)
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Add to Pantry',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: () => _generateRecipe(context, ref),
                  icon: Icon(
                    Icons.restaurant_menu,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Generate Recipe',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
          ],
        ),
        body: _buildBody(context, ref, detectionState),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    IngredientDetectionState state,
  ) {
    if (state.isLoading) {
      return const DetectionLoadingWidget();
    }

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      return _buildErrorState(context, ref, state.errorMessage!);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.detectedIngredients?.isManuallyEdited == true)
            _buildEditedBanner(context),

          // Show clarification prompt if there are unresolved items
          const ClarificationPromptBanner(),

          // Show enhanced ingredient list with confidence indicators
          _buildEnhancedIngredientList(context, ref, state),

          const SizedBox(height: 24),
          _buildActionButtons(context, ref, state),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Detection Failed',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(ingredientDetectionProvider.notifier)
                        .retryDetection();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditedBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
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
            Icons.edit,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'ve edited the ingredient list',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedIngredientList(
    BuildContext context,
    WidgetRef ref,
    IngredientDetectionState state,
  ) {
    final detected = state.detectedIngredients;
    if (detected == null || detected.detectedItems.isEmpty) {
      // Fallback to legacy list widget if no structured items
      return const IngredientListWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Detected Ingredients',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                detected.detectedItems.length.toString(),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: detected.detectedItems.length,
          itemBuilder: (context, index) {
            return IngredientItemCard(
              item: detected.detectedItems[index],
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    IngredientDetectionState state,
  ) {
    final hasIngredients =
        state.detectedIngredients != null &&
        state.detectedIngredients!.ingredients.isNotEmpty;

    return Column(
      children: [
        if (hasIngredients) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _generateRecipe(context, ref),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Generate Recipe'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Only clear ingredients if not in pantry mode
              // In pantry mode, user will add to pantry then clear
              if (!isPantryMode) {
                ref.read(ingredientDetectionProvider.notifier).clearIngredients();
              }
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take New Photo'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _generateRecipe(BuildContext context, WidgetRef ref) {
    final ingredients = ref
        .read(ingredientDetectionProvider)
        .detectedIngredients
        ?.ingredients;

    if (ingredients == null || ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No ingredients to generate recipe from'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // TODO: Navigate to recipe generation screen
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating recipe from ${ingredients.length} ingredients...',
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // This will be implemented in Phase 4
    print('Generate recipe with ingredients: $ingredients');
  }
}
