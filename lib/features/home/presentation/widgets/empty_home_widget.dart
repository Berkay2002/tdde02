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
            // Friendly illustration
            Image.asset(
              'assets/images/illustrations/empty_home_cooking.png',
              height: 280,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24),

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
