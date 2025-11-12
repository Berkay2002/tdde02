import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/detected_ingredient_item.dart';

/// Dialog for clarifying uncertain ingredient quantities
///
/// Provides HITL (Human-in-the-Loop) interface for low-confidence detections
class QuantityClarificationDialog extends StatefulWidget {
  final DetectedIngredientItem item;
  final Function(String quantity, String? unit) onConfirm;
  final VoidCallback onSkip;

  const QuantityClarificationDialog({
    super.key,
    required this.item,
    required this.onConfirm,
    required this.onSkip,
  });

  @override
  State<QuantityClarificationDialog> createState() =>
      _QuantityClarificationDialogState();
}

class _QuantityClarificationDialogState
    extends State<QuantityClarificationDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.item.quantity ?? '',
    );
    _unitController = TextEditingController(text: widget.item.unit ?? '');
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Verify Quantity')),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ingredient name
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.kitchen,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.item.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Warning message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uncertain Quantity',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'The AI wasn\'t very confident about this amount. '
                            'Please verify or skip to fix later.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // AI's guess
              if (widget.item.quantity != null) ...[
                Text(
                  'AI\'s estimate:',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.item.quantity} ${widget.item.unit ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Input fields
              Text(
                'Your correction:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  // Quantity field
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'e.g., 2, 500',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.numbers),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      autofocus: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Unit field
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: 'Unit (optional)',
                        hintText: 'e.g., pieces, g, kg',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.straighten),
                        isDense: true,
                      ),
                      textCapitalization: TextCapitalization.none,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Common unit shortcuts
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _unitChip(context, 'pieces'),
                  _unitChip(context, 'g'),
                  _unitChip(context, 'kg'),
                  _unitChip(context, 'ml'),
                  _unitChip(context, 'L'),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Skip button
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSkip();
          },
          icon: const Icon(Icons.skip_next),
          label: const Text('Skip (Fix Later)'),
        ),

        // Confirm button
        FilledButton.icon(
          onPressed: () {
            final quantity = _quantityController.text.trim();
            if (quantity.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a quantity or skip'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }

            Navigator.of(context).pop();
            widget.onConfirm(
              quantity,
              _unitController.text.trim().isEmpty
                  ? null
                  : _unitController.text.trim(),
            );
          },
          icon: const Icon(Icons.check),
          label: const Text('Confirm'),
        ),
      ],
    );
  }

  Widget _unitChip(BuildContext context, String unit) {
    return ActionChip(
      label: Text(unit),
      onPressed: () {
        setState(() {
          _unitController.text = unit;
        });
      },
      avatar: const Icon(Icons.add, size: 16),
      visualDensity: VisualDensity.compact,
    );
  }
}
