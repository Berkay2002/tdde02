import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/debug_utils.dart';

/// Debug panel for testing onboarding flow
/// Only show this in debug builds or when a flag is enabled
class OnboardingDebugPanel extends ConsumerStatefulWidget {
  final bool isVisible;

  const OnboardingDebugPanel({
    super.key,
    this.isVisible = true,
  });

  @override
  ConsumerState<OnboardingDebugPanel> createState() =>
      _OnboardingDebugPanelState();
}

class _OnboardingDebugPanelState extends ConsumerState<OnboardingDebugPanel> {
  bool _isLoading = false;
  String? _message;

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '🧪 DEBUG: Onboarding Tools',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                          _message = null;
                        });
                        try {
                          await DebugUtils.resetUserOnboarding(ref);
                          setState(() {
                            _message =
                                '✅ Onboarding reset! Navigating to onboarding...';
                          });
                          // Give a moment for the message to show, then navigate
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (context.mounted) {
                            // Import Navigator to go back to login screen
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          setState(() {
                            _message = '❌ Error: $e';
                          });
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text(
                  'Reset Onboarding',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                          _message = null;
                        });
                        try {
                          await DebugUtils.createTestUserPreferences(ref);
                          setState(() {
                            _message = '✅ Test preferences created!';
                          });
                        } catch (e) {
                          setState(() {
                            _message = '❌ Error: $e';
                          });
                        } finally {
                          setState(() => _isLoading = false);
                        }
                      },
                icon: const Icon(Icons.add, size: 14),
                label: const Text(
                  'Create Test Prefs',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Text(
              _message!,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
