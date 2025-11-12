import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ingredient_detection_provider.dart';
import 'quantity_clarification_dialog.dart';

/// Banner that prompts user to resolve quantity clarifications
class ClarificationPromptBanner extends ConsumerWidget {
  const ClarificationPromptBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectionState = ref.watch(ingredientDetectionProvider);
    final detected = detectionState.detectedIngredients;

    if (detected == null) return const SizedBox.shrink();

    final itemsNeedingClarification = detected.itemsNeedingClarification;

    if (itemsNeedingClarification.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantity Verification Needed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${itemsNeedingClarification.length} ${itemsNeedingClarification.length == 1 ? 'item needs' : 'items need'} verification',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'The AI wasn\'t very confident about some quantities. '
            'Please verify them now or skip to fix later.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _startClarificationFlow(context, ref),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Verify Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _skipAllClarifications(context, ref),
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startClarificationFlow(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ingredientDetectionProvider.notifier);
    final items = notifier.getItemsNeedingClarification();

    if (items.isEmpty) return;

    _showNextClarification(context, ref, 0);
  }

  void _showNextClarification(BuildContext context, WidgetRef ref, int index) {
    final notifier = ref.read(ingredientDetectionProvider.notifier);
    final items = notifier.getItemsNeedingClarification();

    if (index >= items.length) {
      // All done!
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ All quantities verified!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final item = items[index];

    // Find the actual index in the full list
    final detected = ref.read(ingredientDetectionProvider).detectedIngredients;
    if (detected == null) return;

    final actualIndex = detected.detectedItems.indexOf(item);
    if (actualIndex == -1) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuantityClarificationDialog(
        item: item,
        onConfirm: (quantity, unit) {
          notifier.confirmIngredientQuantity(actualIndex, quantity, unit);

          // Show next item
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              _showNextClarification(context, ref, index + 1);
            }
          });
        },
        onSkip: () {
          notifier.skipIngredientClarification(actualIndex);

          // Show next item
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              _showNextClarification(context, ref, index + 1);
            }
          });
        },
      ),
    );
  }

  void _skipAllClarifications(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ingredientDetectionProvider.notifier);
    final detected = ref.read(ingredientDetectionProvider).detectedIngredients;

    if (detected == null) return;

    // Skip all items needing clarification
    for (var i = 0; i < detected.detectedItems.length; i++) {
      final item = detected.detectedItems[i];
      if (item.needsUserClarification && !item.isResolved) {
        notifier.skipIngredientClarification(i);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Skipped all - you can edit quantities later'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
