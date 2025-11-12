import 'package:flutter/material.dart';

/// Empty state widget for new users
class EmptyHomeWidget extends StatelessWidget {
  final VoidCallback onGetStarted;

  const EmptyHomeWidget({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large friendly icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Welcome message
            Text(
              'Welcome to Your\nAI Recipe Generator!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 16),

            // Instructions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstructionStep(
                  number: '1',
                  text: 'Scan or add ingredients',
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _InstructionStep(
                  number: '2',
                  text: 'Generate personalized recipes',
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _InstructionStep(
                  number: '3',
                  text: 'Save your favorites',
                  theme: theme,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CTA button
            FilledButton.icon(
              onPressed: onGetStarted,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Get Started with Scan'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String text;
  final ThemeData theme;

  const _InstructionStep({
    required this.number,
    required this.text,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
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
              number,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
