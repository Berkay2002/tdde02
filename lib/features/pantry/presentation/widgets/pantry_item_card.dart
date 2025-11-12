import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/ingredient_category.dart';

class PantryItemCard extends StatelessWidget {
  final PantryItem item;
  final VoidCallback? onDelete;
  final Function(PantryItem)? onEdit;
  final VoidCallback? onTap;
  const PantryItemCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onEdit,
    this.onTap,
  });

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

  void _showItemMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Details'),
              onTap: () {
                Navigator.pop(context);
                if (onEdit != null) {
                  _showEditDialog(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outlined),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: IngredientCategoryHelper.getName(item.category),
            ),
            if (item.quantity != null)
              _DetailRow(
                icon: Icons.shopping_basket_outlined,
                label: 'Quantity',
                value:
                    '${item.quantity}${item.unit != null ? ' ${item.unit}' : ''}',
              ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Added',
              value: DateFormat.yMMMd().format(item.dateAdded),
            ),
            if (item.expirationDate != null)
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'Expires',
                value: DateFormat.yMMMd().format(item.expirationDate!),
              ),
            _DetailRow(
              icon: Icons.circle,
              label: 'Freshness',
              value: item.freshnessStatus.name.toUpperCase(),
              valueColor: _freshnessColor(item.freshnessStatus, theme),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (onEdit != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
              child: const Text('Edit'),
            ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final quantityController = TextEditingController(text: item.quantity ?? '');
    final unitController = TextEditingController(text: item.unit ?? '');
    DateTime? selectedExpiration = item.expirationDate;
    IngredientCategory selectedCategory = item.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit ${item.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<IngredientCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: IngredientCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(
                            IngredientCategoryHelper.getIcon(cat),
                            color: IngredientCategoryHelper.getColor(cat),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(IngredientCategoryHelper.getName(cat)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          prefixIcon: Icon(Icons.shopping_basket_outlined),
                          hintText: 'e.g., 2',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          hintText: 'e.g., kg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Expiration Date'),
                  subtitle: Text(
                    selectedExpiration != null
                        ? DateFormat.yMMMd().format(selectedExpiration!)
                        : 'Not set',
                  ),
                  trailing: selectedExpiration != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              setState(() => selectedExpiration = null),
                        )
                      : null,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          selectedExpiration ??
                          DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedExpiration = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final updatedItem = item.copyWith(
                  category: selectedCategory,
                  quantity: quantityController.text.trim().isEmpty
                      ? null
                      : quantityController.text.trim(),
                  unit: unitController.text.trim().isEmpty
                      ? null
                      : unitController.text.trim(),
                  expirationDate: selectedExpiration,
                );
                onEdit?.call(updatedItem);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = IngredientCategoryHelper.getColor(item.category);

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Ingredient?'),
            content: Text('Remove "${item.name}" from your pantry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap ?? () => _showDetailsDialog(context),
          onLongPress: () => _showItemMenu(context),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 80,
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
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: categoryColor.withOpacity(0.15),
                        foregroundColor: categoryColor,
                        radius: 26,
                        child: Icon(
                          IngredientCategoryHelper.getIcon(item.category),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (item.quantity != null &&
                                    item.quantity!.isNotEmpty) ...[
                                  Icon(
                                    Icons.shopping_basket_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.quantity}${item.unit != null ? ' ${item.unit}' : ''}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                if (item.expirationDate != null) ...[
                                  Icon(
                                    Icons.event_outlined,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat.MMMd().format(
                                      item.expirationDate!,
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _freshnessColor(
                                item.freshnessStatus,
                                theme,
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _freshnessColor(
                                      item.freshnessStatus,
                                      theme,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.freshnessStatus.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _freshnessColor(
                                      item.freshnessStatus,
                                      theme,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'More options',
                        onPressed: () => _showItemMenu(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
