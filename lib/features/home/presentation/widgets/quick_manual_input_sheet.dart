import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/app_state_provider.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../camera/presentation/screens/camera_screen.dart';

/// QuickManualInputSheet - Modal bottom sheet for manual ingredient entry
///
/// This modal has dual functionality:
/// 1. "Save to Pantry" - Adds ingredients to the persistent pantryIngredients list
/// 2. "Find Recipes" - Adds ingredients to sessionIngredients and switches to Recipes tab
class QuickManualInputSheet extends ConsumerStatefulWidget {
  final bool showRetryCamera;

  const QuickManualInputSheet({super.key, this.showRetryCamera = false});

  @override
  ConsumerState<QuickManualInputSheet> createState() =>
      _QuickManualInputSheetState();
}

class _QuickManualInputSheetState extends ConsumerState<QuickManualInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _tempIngredients = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addIngredient() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_tempIngredients.contains(text)) {
      setState(() {
        _tempIngredients.add(text);
        _controller.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _tempIngredients.remove(ingredient);
    });
  }

  void _saveToPantry() {
    if (_tempIngredients.isEmpty) return;

    // Send to Brain's pantryIngredients
    ref
        .read(pantryIngredientsProvider.notifier)
        .addIngredients(_tempIngredients);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_tempIngredients.length} ingredient(s) saved to pantry!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Clear the temp list
    setState(() {
      _tempIngredients.clear();
    });
  }

  void _findRecipes() {
    if (_tempIngredients.isEmpty) return;

    // Send to Brain's sessionIngredients
    ref
        .read(sessionIngredientsProvider.notifier)
        .setIngredients(_tempIngredients);

    // Close modal
    Navigator.pop(context);

    // Switch to Recipes tab
    switchToRecipeTab(context);
  }

  Future<void> _retryCamera() async {
    // Close the modal first
    Navigator.pop(context);

    // Launch camera again
    if (mounted) {
      final ingredients = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => const CameraScreen(mode: CameraMode.quickScan),
        ),
      );

      if (context.mounted) {
        if (ingredients != null && ingredients.isNotEmpty) {
          // Send to sessionIngredients
          ref
              .read(sessionIngredientsProvider.notifier)
              .setIngredients(ingredients);

          // Switch to Recipes tab
          switchToRecipeTab(context);
        } else if (ingredients != null && ingredients.isEmpty) {
          // No ingredients detected again - show manual entry again
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) =>
                const QuickManualInputSheet(showRetryCamera: true),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Ingredients',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.showRetryCamera) ...[
                    const SizedBox(height: 8),
                    Text(
                      'No ingredients detected. Add them manually or try again.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        prefixIcon: const Icon(Icons.add_circle_outline),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addIngredient(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _addIngredient,
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),

            // Ingredients list
            if (_tempIngredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Ingredients (${_tempIngredients.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _tempIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = _tempIngredients[index];
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(ingredient),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeIngredient(ingredient),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Retry camera button (if applicable)
            if (widget.showRetryCamera) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: OutlinedButton.icon(
                  onPressed: _retryCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retry Camera Scan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],

            // Action buttons
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _tempIngredients.isEmpty
                          ? null
                          : _saveToPantry,
                      icon: const Icon(Icons.kitchen),
                      label: const Text('Save to Pantry'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _tempIngredients.isEmpty ? null : _findRecipes,
                      icon: const Icon(Icons.search),
                      label: const Text('Find Recipes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
