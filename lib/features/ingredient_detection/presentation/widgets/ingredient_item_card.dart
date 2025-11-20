import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/detected_ingredient_item.dart';
import '../providers/ingredient_detection_provider.dart';

/// Card widget for displaying a detected ingredient with simplified UI
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 4,
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: item.category != null ? _buildCategoryChip(theme) : null,
          trailing: _buildTrailingActions(context, ref, theme),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(ThemeData theme) {
    // Get icon based on category
    IconData icon;
    Color color;

    switch (item.category?.toLowerCase()) {
      case 'vegetables':
        icon = Icons.eco;
        color = Colors.green;
        break;
      case 'fruits':
        icon = Icons.apple;
        color = Colors.orange;
        break;
      case 'proteins':
        icon = Icons.egg;
        color = Colors.red;
        break;
      case 'dairy':
        icon = Icons.local_drink;
        color = Colors.blue;
        break;
      case 'grains':
        icon = Icons.grain;
        color = Colors.brown;
        break;
      case 'herbs':
        icon = Icons.spa;
        color = Colors.teal;
        break;
      case 'canned':
        icon = Icons.inventory_2;
        color = Colors.grey;
        break;
      case 'condiments':
        icon = Icons.water_drop;
        color = Colors.amber;
        break;
      default:
        icon = Icons.restaurant;
        color = theme.primaryColor;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildCategoryChip(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        _formatCategory(item.category!),
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _formatCategory(String category) {
    return category.substring(0, 1).toUpperCase() + category.substring(1);
  }

  Widget _buildTrailingActions(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
  ) {
    return IconButton(
      icon: Icon(
        Icons.delete_outline,
        size: 22,
        color: theme.colorScheme.error,
      ),
      onPressed: () {
        ref.read(ingredientDetectionProvider.notifier).removeIngredient(index);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed ${item.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      tooltip: 'Remove ingredient',
    );
  }
}
