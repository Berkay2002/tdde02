import 'package:flutter/material.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/ingredient_category.dart';
import 'pantry_item_card.dart';

/// Grouped view of pantry items by category
class GroupedPantryView extends StatefulWidget {
  final Map<IngredientCategory, List<PantryItem>> groupedItems;
  final Function(String) onDelete;
  final Function(PantryItem)? onEdit;

  const GroupedPantryView({
    super.key,
    required this.groupedItems,
    required this.onDelete,
    this.onEdit,
  });

  @override
  State<GroupedPantryView> createState() => _GroupedPantryViewState();
}

class _GroupedPantryViewState extends State<GroupedPantryView> {
  final Map<IngredientCategory, bool> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    // Initialize all sections as expanded
    for (final category in widget.groupedItems.keys) {
      _expandedSections[category] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedCategories = widget.groupedItems.keys.toList()
      ..sort(
        (a, b) => widget.groupedItems[b]!.length.compareTo(
          widget.groupedItems[a]!.length,
        ),
      );

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        final items = widget.groupedItems[category]!;
        final isExpanded = _expandedSections[category] ?? true;

        return _CategorySection(
          category: category,
          items: items,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              _expandedSections[category] = !isExpanded;
            });
          },
          onDelete: widget.onDelete,
          onEdit: widget.onEdit,
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final IngredientCategory category;
  final List<PantryItem> items;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(String) onDelete;
  final Function(PantryItem)? onEdit;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.isExpanded,
    required this.onToggle,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = IngredientCategoryHelper.getColor(category);
    final categoryIcon = IngredientCategoryHelper.getIcon(category);
    final categoryName = IngredientCategoryHelper.getName(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(categoryIcon, size: 20, color: categoryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    categoryName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: categoryColor,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...items.map(
            (item) => PantryItemCard(
              item: item,
              onDelete: () => onDelete(item.name),
              onEdit: onEdit,
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
