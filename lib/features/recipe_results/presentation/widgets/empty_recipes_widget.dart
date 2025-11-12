import 'package:flutter/material.dart';

enum EmptyRecipesReason { noIngredients, generationFailed, noMatchingFilters }

class EmptyRecipesWidget extends StatelessWidget {
  final EmptyRecipesReason reason;
  final VoidCallback? onAction;

  const EmptyRecipesWidget({super.key, required this.reason, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (reason) {
      case EmptyRecipesReason.noIngredients:
        return _buildEmptyState(
          theme: theme,
          icon: Icons.restaurant_menu_outlined,
          title: 'No ingredients selected',
          subtitle: 'Scan or add ingredients to generate recipes',
          actionLabel: 'Add Ingredients',
          actionIcon: Icons.add,
          onAction: onAction,
        );

      case EmptyRecipesReason.generationFailed:
        return _buildEmptyState(
          theme: theme,
          icon: Icons.error_outline,
          title: 'Failed to generate recipes',
          subtitle: 'Something went wrong. Please try again.',
          actionLabel: 'Try Again',
          actionIcon: Icons.refresh,
          onAction: onAction,
          iconColor: theme.colorScheme.error,
        );

      case EmptyRecipesReason.noMatchingFilters:
        return _buildEmptyState(
          theme: theme,
          icon: Icons.search_off,
          title: 'No recipes found',
          subtitle: 'Try adjusting your filters or search query',
          actionLabel: 'Clear Filters',
          actionIcon: Icons.filter_alt_off,
          onAction: onAction,
        );
    }
  }

  Widget _buildEmptyState({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    IconData? actionIcon,
    VoidCallback? onAction,
    Color? iconColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 96,
              color:
                  iconColor ??
                  theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.arrow_forward),
                label: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
