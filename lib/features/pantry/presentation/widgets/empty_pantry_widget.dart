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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.kitchen_outlined,
              size: 96,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text('Your pantry is empty', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Start by scanning or typing ingredients you have.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Ingredients'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onManual,
              icon: const Icon(Icons.edit),
              label: const Text('Type to Add'),
            ),
          ],
        ),
      ),
    );
  }
}
