import 'package:flutter/material.dart';

class EmptyPantryWidget extends StatelessWidget {
  final VoidCallback onScan;
  final VoidCallback onManual;
  const EmptyPantryWidget({
    super.key,
    required this.onScan,
    required this.onManual,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.kitchen_outlined,
                size: 96,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Pantry is Empty',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start building your digital pantry to get personalized recipe suggestions',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Step-by-step guide
            _buildStep(theme, 1, 'Scan or add ingredients', Icons.add_a_photo),
            const SizedBox(height: 12),
            _buildStep(theme, 2, 'Organize by categories', Icons.category),
            const SizedBox(height: 12),
            _buildStep(
              theme,
              3,
              'Generate recipes instantly',
              Icons.restaurant_menu,
            ),

            const SizedBox(height: 40),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onScan,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Ingredients'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onManual,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                icon: const Icon(Icons.edit),
                label: const Text('Type to Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme, int number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
