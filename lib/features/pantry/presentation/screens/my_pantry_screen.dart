import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../domain/entities/pantry_item.dart';
import '../../domain/entities/ingredient_category.dart';
import '../widgets/pantry_item_card.dart';
import '../widgets/empty_pantry_widget.dart';
import '../widgets/pantry_search_bar.dart';
import '../widgets/pantry_stats_card.dart';
import '../widgets/pantry_filter_chips.dart';
import '../widgets/pantry_sort_sheet.dart';
import '../widgets/grouped_pantry_view.dart';
import '../widgets/pantry_quick_actions.dart';
import '../../../camera/presentation/screens/camera_screen.dart';

enum PantryViewMode { list, grouped }

/// MyPantryScreen - Tab 2
///
/// Manages the persistent pantryIngredients list.
/// Users can add ingredients via camera or manual input,
/// and can remove ingredients they no longer have.
class MyPantryScreen extends ConsumerStatefulWidget {
  const MyPantryScreen({super.key});

  @override
  ConsumerState<MyPantryScreen> createState() => _MyPantryScreenState();
}

class _MyPantryScreenState extends ConsumerState<MyPantryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isAddingManually = false;
  Set<IngredientCategory> _selectedCategories = {};
  PantrySortOption _currentSort = PantrySortOption.alphabeticalAZ;
  PantryViewMode _viewMode = PantryViewMode.list;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCameraScan() async {
    // Launch camera modal for pantry add
    final ingredients = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(mode: CameraMode.pantryAdd),
      ),
    );

    if (ingredients != null && ingredients.isNotEmpty && mounted) {
      // Add to pantryIngredients
      ref.read(pantryIngredientsProvider.notifier).addIngredients(ingredients);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ingredients.length} ingredient(s) added to pantry!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleManualAdd() {
    setState(() {
      _isAddingManually = !_isAddingManually;
      if (!_isAddingManually) {
        _controller.clear();
      }
    });
  }

  void _addManualIngredient() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(pantryIngredientsProvider.notifier).addIngredient(text);
      _controller.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$text added to pantry!'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _removeIngredient(String ingredient) {
    ref.read(pantryIngredientsProvider.notifier).removeIngredient(ingredient);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$ingredient removed from pantry'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref
                .read(pantryIngredientsProvider.notifier)
                .addIngredient(ingredient);
          },
        ),
      ),
    );
  }

  void _updateItem(PantryItem updatedItem) {
    ref.read(pantryIngredientsProvider.notifier).updateItem(updatedItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${updatedItem.name} updated'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _clearPantry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pantry?'),
        content: const Text(
          'This will remove all ingredients from your pantry.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(pantryIngredientsProvider.notifier).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Pantry cleared')));
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notifier = ref.watch(pantryIngredientsProvider.notifier);
    final pantryItems = notifier.filteredItems;
    final searchQuery = notifier.searchQuery;
    final allItems = ref.watch(pantryIngredientsProvider);

    // Apply category filter
    final categoryFiltered = _selectedCategories.isEmpty
        ? pantryItems
        : pantryItems
              .where((item) => _selectedCategories.contains(item.category))
              .toList();

    // Apply sorting
    final sortedItems = _applySorting(categoryFiltered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        centerTitle: true,
        actions: [
          if (allItems.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                _viewMode == PantryViewMode.list
                    ? Icons.view_agenda
                    : Icons.list,
              ),
              tooltip: 'Toggle view',
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == PantryViewMode.list
                      ? PantryViewMode.grouped
                      : PantryViewMode.list;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort',
              onPressed: () => _showSortSheet(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear pantry',
              onPressed: _clearPantry,
            ),
          ],
        ],
      ),
      body: allItems.isEmpty
          ? Column(
              children: [
                PantrySearchBar(
                  query: searchQuery,
                  onChanged: (q) => ref
                      .read(pantryIngredientsProvider.notifier)
                      .setSearchQuery(q),
                  onClear: () => ref
                      .read(pantryIngredientsProvider.notifier)
                      .setSearchQuery(''),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _handleCameraScan,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scan to Add'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleManualAdd,
                          icon: Icon(
                            _isAddingManually ? Icons.close : Icons.edit,
                          ),
                          label: Text(
                            _isAddingManually ? 'Cancel' : 'Type to Add',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAddingManually)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Enter ingredient name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.add),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _addManualIngredient(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addManualIngredient,
                          icon: const Icon(Icons.check),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: EmptyPantryWidget(
                    onScan: _handleCameraScan,
                    onManual: _toggleManualAdd,
                  ),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      PantrySearchBar(
                        query: searchQuery,
                        onChanged: (q) => ref
                            .read(pantryIngredientsProvider.notifier)
                            .setSearchQuery(q),
                        onClear: () => ref
                            .read(pantryIngredientsProvider.notifier)
                            .setSearchQuery(''),
                      ),
                      if (allItems.isNotEmpty)
                        PantryFilterChips(
                          selectedCategories: _selectedCategories,
                          onFiltersChanged: (categories) {
                            setState(() => _selectedCategories = categories);
                          },
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _handleCameraScan,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Scan to Add'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _toggleManualAdd,
                                icon: Icon(
                                  _isAddingManually ? Icons.close : Icons.edit,
                                ),
                                label: Text(
                                  _isAddingManually ? 'Cancel' : 'Type to Add',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isAddingManually)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  decoration: InputDecoration(
                                    hintText: 'Enter ingredient name',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    prefixIcon: const Icon(Icons.add),
                                  ),
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _addManualIngredient(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: _addManualIngredient,
                                icon: const Icon(Icons.check),
                              ),
                            ],
                          ),
                        ),
                      PantryStatsCard(items: allItems),
                      const PantryQuickActions(),
                    ],
                  ),
                ),
                sortedItems.isEmpty
                    ? SliverFillRemaining(child: _buildNoResults(theme))
                    : _viewMode == PantryViewMode.list
                    ? _buildSliverList(sortedItems, theme)
                    : _buildSliverGroupedView(sortedItems),
              ],
            ),
    );
  }

  Widget _buildNoResults(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No items match your filters',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() => _selectedCategories = {});
                ref.read(pantryIngredientsProvider.notifier).setSearchQuery('');
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverList(List<PantryItem> items, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = items[index];
          return PantryItemCard(
            item: item,
            onDelete: () => _removeIngredient(item.name),
            onEdit: _updateItem,
          );
        }, childCount: items.length),
      ),
    );
  }

  Widget _buildSliverGroupedView(List<PantryItem> items) {
    final grouped = <IngredientCategory, List<PantryItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
      sliver: SliverToBoxAdapter(
        child: GroupedPantryView(
          groupedItems: grouped,
          onDelete: _removeIngredient,
          onEdit: _updateItem,
        ),
      ),
    );
  }

  List<PantryItem> _applySorting(List<PantryItem> items) {
    final sorted = List<PantryItem>.from(items);
    switch (_currentSort) {
      case PantrySortOption.alphabeticalAZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
      case PantrySortOption.alphabeticalZA:
        sorted.sort((a, b) => b.name.compareTo(a.name));
      case PantrySortOption.recentlyAdded:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case PantrySortOption.byCategory:
        sorted.sort((a, b) {
          final catCompare = a.category.index.compareTo(b.category.index);
          return catCompare != 0 ? catCompare : a.name.compareTo(b.name);
        });
      case PantrySortOption.byFreshness:
        sorted.sort((a, b) {
          final freshCompare = a.freshnessStatus.index.compareTo(
            b.freshnessStatus.index,
          );
          return freshCompare != 0 ? freshCompare : a.name.compareTo(b.name);
        });
    }
    return sorted;
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PantrySortSheet(
        currentSort: _currentSort,
        onSortChanged: (sort) {
          setState(() => _currentSort = sort);
        },
      ),
    );
  }
}
