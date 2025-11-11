import 'package:flutter/material.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/ingredient_category.dart';

class PantryItemCard extends StatelessWidget {
  final PantryItem item;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  const PantryItemCard({super.key, required this.item, this.onDelete, this.onTap});

  Color _freshnessColor(FreshnessStatus status, ThemeData theme) {
    switch (status) {
      case FreshnessStatus.fresh:
        return Colors.green;
      case FreshnessStatus.soon:
        return Colors.orange;
      case FreshnessStatus.urgent:
        return theme.colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = IngredientCategoryHelper.getColor(item.category);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Category accent
            Container(
              width: 6,
              height: 72,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: categoryColor.withOpacity(0.15),
                      foregroundColor: categoryColor,
                      radius: 24,
                      child: Icon(IngredientCategoryHelper.getIcon(item.category), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (item.quantity != null && item.quantity!.isNotEmpty)
                            Text(
                              item.quantity! + (item.unit != null ? ' ${item.unit}' : ''),
                              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    // Freshness indicator
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _freshnessColor(item.freshnessStatus, theme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Remove',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
