import 'package:flutter/material.dart';
import '../../domain/entities/ingredient_category.dart';

/// Filter chips for pantry categories
class PantryFilterChips extends StatelessWidget {
  final Set<IngredientCategory> selectedCategories;
  final ValueChanged<Set<IngredientCategory>> onFiltersChanged;

  const PantryFilterChips({
    super.key,
    required this.selectedCategories,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // All chip
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: selectedCategories.isEmpty,
                onSelected: (_) => onFiltersChanged({}),
                avatar: selectedCategories.isEmpty
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: theme.colorScheme.primary,
                      )
                    : null,
              ),
            ),

            // Category chips
            ...IngredientCategory.values
                .where((c) => c != IngredientCategory.unknown)
                .map((category) {
                  final isSelected = selectedCategories.contains(category);
                  final categoryColor = IngredientCategoryHelper.getColor(
                    category,
                  );
                  final categoryIcon = IngredientCategoryHelper.getIcon(
                    category,
                  );
                  final categoryName = IngredientCategoryHelper.getName(
                    category,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(categoryName),
                      avatar: Icon(
                        categoryIcon,
                        size: 18,
                        color: isSelected ? Colors.white : categoryColor,
                      ),
                      selected: isSelected,
                      selectedColor: categoryColor,
                      onSelected: (selected) {
                        final updated = Set<IngredientCategory>.from(
                          selectedCategories,
                        );
                        if (selected) {
                          updated.add(category);
                        } else {
                          updated.remove(category);
                        }
                        onFiltersChanged(updated);
                      },
                    ),
                  );
                })
                ,
          ],
        ),
      ),
    );
  }
}
