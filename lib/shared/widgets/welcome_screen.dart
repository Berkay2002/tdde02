import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import 'app_shell.dart';
import '../../../shared/providers/firebase_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Check if user is authenticated
    if (user != null) {
      // User is authenticated, go to the main app shell with tabs
      return AppShell(key: appShellKey);
    }

    // User not authenticated, show welcome screen
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // App logo/icon
              Icon(
                Icons.restaurant_menu,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppConstants.largePadding),

              // App name
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),

              // Tagline
              Text(
                'AI-Powered Recipe Generation\nfrom Your Fridge',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.largePadding),

              // Features
              _buildFeature(
                context,
                Icons.camera_alt,
                'Scan Your Fridge',
                'Take a photo of your ingredients',
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildFeature(
                context,
                Icons.auto_awesome,
                'AI Magic',
                'Get personalized recipes instantly',
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              _buildFeature(
                context,
                Icons.offline_bolt,
                'Works Offline',
                'No internet needed after setup',
              ),

              const Spacer(),

              // Get started button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
