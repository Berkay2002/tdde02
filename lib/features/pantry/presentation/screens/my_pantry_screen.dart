import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../camera/presentation/screens/camera_screen.dart';

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
        builder: (context) => const CameraScreen(
          mode: CameraMode.pantryAdd,
        ),
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
            ref.read(pantryIngredientsProvider.notifier).addIngredient(ingredient);
          },
        ),
      ),
    );
  }

  void _clearPantry() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Pantry?'),
        content: const Text('This will remove all ingredients from your pantry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(pantryIngredientsProvider.notifier).clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pantry cleared')),
              );
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
    final pantryIngredients = ref.watch(pantryIngredientsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantry'),
        centerTitle: true,
        actions: [
          if (pantryIngredients.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear pantry',
              onPressed: _clearPantry,
            ),
        ],
      ),
      body: Column(
        children: [
          // Add buttons
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
                    icon: Icon(_isAddingManually ? Icons.close : Icons.edit),
                    label: Text(_isAddingManually ? 'Cancel' : 'Type to Add'),
                  ),
                ),
              ],
            ),
          ),

          // Manual input field (if active)
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

          // Ingredients list
          Expanded(
            child: pantryIngredients.isEmpty
                ? _buildEmptyState(theme)
                : _buildIngredientsList(pantryIngredients, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.kitchen_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your pantry is empty',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add ingredients you have at home',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<String> ingredients, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.egg_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              ingredient,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeIngredient(ingredient),
              tooltip: 'Remove',
            ),
          ),
        );
      },
    );
  }
}
