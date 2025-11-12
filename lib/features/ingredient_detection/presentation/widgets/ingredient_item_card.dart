import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detected_ingredient_item.dart';
import '../providers/ingredient_detection_provider.dart';
import 'quantity_clarification_dialog.dart';

/// Card widget for displaying a detected ingredient with confidence indicators
class IngredientItemCard extends ConsumerWidget {
  final DetectedIngredientItem item;
  final int index;

  const IngredientItemCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final needsClarification = item.needsUserClarification && !item.isResolved;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: needsClarification 
            ? () => _showClarificationDialog(context, ref)
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: needsClarification 
                ? Colors.orange.shade50
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(theme),
              width: needsClarification ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: needsClarification 
                    ? Colors.orange.withOpacity(0.15)
                    : theme.shadowColor.withOpacity(0.05),
                blurRadius: needsClarification ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: _buildLeadingIcon(theme),
            title: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: _buildSubtitle(theme),
            trailing: _buildTrailingActions(context, ref, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ThemeData theme) {
    IconData icon;
    Color color;

    if (item.needsUserClarification && !item.isResolved) {
      icon = Icons.help_outline;
      color = Colors.orange;
    } else if (item.quantityConfidence == QuantityConfidence.high) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (item.quantityConfidence == QuantityConfidence.medium) {
      icon = Icons.info;
      color = Colors.blue;
    } else {
      icon = Icons.shopping_basket;
      color = theme.primaryColor;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget? _buildSubtitle(ThemeData theme) {
    final quantityText = item.displayQuantity;
    final needsClarification = item.needsUserClarification && !item.isResolved;

    if (quantityText.isEmpty && !needsClarification) {
      return const Text(
        'No quantity detected',
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quantityText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              quantityText,
              style: TextStyle(
                fontSize: 14,
                color: _getQuantityColor(theme),
                fontWeight: item.confirmedQuantity != null
                    ? FontWeight.w600
                    : item.quantityConfidence == QuantityConfidence.high
                        ? FontWeight.w500
                        : FontWeight.normal,
              ),
            ),
          ),
        if (needsClarification)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 14,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap card to verify quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTrailingActions(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    final needsClarification = item.needsUserClarification && !item.isResolved;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Prominent edit button for items needing clarification
        if (needsClarification)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () => _showClarificationDialog(context, ref),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          )
        else
          // Small edit button for already-resolved items
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => _showClarificationDialog(context, ref),
            tooltip: 'Edit quantity',
            color: theme.colorScheme.primary,
          ),

        // Confidence badge
        Tooltip(
          message: _getConfidenceTooltip(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getConfidenceBadgeColor(theme),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getConfidenceBadgeText(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _getConfidenceBadgeTextColor(),
              ),
            ),
          ),
        ),

        // Delete button
        IconButton(
          icon: Icon(Icons.delete_outline, size: 22, color: theme.colorScheme.error),
          onPressed: () {
            ref
                .read(ingredientDetectionProvider.notifier)
                .removeIngredient(index);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed ${item.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          tooltip: 'Remove ingredient',
        ),
      ],
    );
  }

  Color _getBorderColor(ThemeData theme) {
    if (item.needsUserClarification && !item.isResolved) {
      return Colors.orange.withOpacity(0.5);
    }
    return theme.colorScheme.outline.withOpacity(0.3);
  }

  Color _getQuantityColor(ThemeData theme) {
    if (item.confirmedQuantity != null) {
      return Colors.green.shade700;
    }

    switch (item.quantityConfidence) {
      case QuantityConfidence.high:
        return theme.colorScheme.onSurface;
      case QuantityConfidence.medium:
        return Colors.blue.shade700;
      case QuantityConfidence.low:
        return Colors.orange.shade700;
      case QuantityConfidence.none:
        return theme.colorScheme.onSurface.withOpacity(0.6);
    }
  }

  Color _getConfidenceBadgeColor(ThemeData theme) {
    switch (item.quantityConfidence) {
      case QuantityConfidence.high:
        return Colors.green.withOpacity(0.2);
      case QuantityConfidence.medium:
        return Colors.blue.withOpacity(0.2);
      case QuantityConfidence.low:
        return Colors.orange.withOpacity(0.2);
      case QuantityConfidence.none:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  String _getConfidenceBadgeText() {
    if (item.confirmedQuantity != null) return '✓ Verified';

    switch (item.quantityConfidence) {
      case QuantityConfidence.high:
        return 'Sure';
      case QuantityConfidence.medium:
        return 'Circa';
      case QuantityConfidence.low:
        return 'Unsure';
      case QuantityConfidence.none:
        return 'None';
    }
  }

  Color _getConfidenceBadgeTextColor() {
    if (item.confirmedQuantity != null) return Colors.green.shade800;

    switch (item.quantityConfidence) {
      case QuantityConfidence.high:
        return Colors.green.shade800;
      case QuantityConfidence.medium:
        return Colors.blue.shade800;
      case QuantityConfidence.low:
        return Colors.orange.shade800;
      case QuantityConfidence.none:
        return Colors.grey.shade700;
    }
  }

  String _getConfidenceTooltip() {
    if (item.confirmedQuantity != null) {
      return 'Quantity confirmed by you';
    }

    switch (item.quantityConfidence) {
      case QuantityConfidence.high:
        return 'AI is confident about this quantity';
      case QuantityConfidence.medium:
        return 'Approximate quantity (circa)';
      case QuantityConfidence.low:
        return 'Uncertain - please verify';
      case QuantityConfidence.none:
        return 'No quantity detected';
    }
  }

  void _showClarificationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuantityClarificationDialog(
        item: item,
        onConfirm: (quantity, unit) {
          ref
              .read(ingredientDetectionProvider.notifier)
              .confirmIngredientQuantity(index, quantity, unit);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Confirmed quantity for ${item.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onSkip: () {
          ref
              .read(ingredientDetectionProvider.notifier)
              .skipIngredientClarification(index);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Skipped ${item.name} - you can edit it later'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
