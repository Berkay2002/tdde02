import 'package:flutter/material.dart';

/// Quick tip widget with contextual guidance
class QuickTipWidget extends StatefulWidget {
  const QuickTipWidget({super.key});

  @override
  State<QuickTipWidget> createState() => _QuickTipWidgetState();
}

class _QuickTipWidgetState extends State<QuickTipWidget> {
  bool _dismissed = false;

  final List<String> _tips = [
    'Tap the camera to scan ingredients from your fridge!',
    'Already have ingredients? Use the pantry section!',
    'Save your favorite recipes for quick access later!',
    'Try different dietary restrictions in your profile!',
  ];

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    // Rotate tip based on current time (changes daily)
    final tipIndex = DateTime.now().day % _tips.length;
    final currentTip = _tips[tipIndex];

    return Card(
      elevation: 0,
      color: Colors.yellow.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.orange.shade700,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                currentTip,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.brown.shade900,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: Colors.brown.shade700),
              onPressed: () {
                setState(() {
                  _dismissed = true;
                });
              },
              tooltip: 'Dismiss',
            ),
          ],
        ),
      ),
    );
  }
}
