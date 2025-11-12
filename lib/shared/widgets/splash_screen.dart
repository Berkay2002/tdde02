import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/services_provider.dart';

/// Splash screen that loads the AI model on app startup
class SplashScreen extends ConsumerStatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _statusMessage = 'Initializing...';
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();

    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Initialize AI model
      setState(() {
        _statusMessage = 'Loading AI model...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final inferenceService = ref.read(geminiAIServiceProvider);
      await inferenceService.initialize();

      // Step 2: Verify model is ready
      setState(() {
        _statusMessage = 'Preparing AI engine...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      if (!inferenceService.isInitialized) {
        throw Exception('Failed to initialize AI model');
      }

      // Step 3: Ready to go
      setState(() {
        _statusMessage = 'Ready!';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to home screen
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => widget.nextScreen));
      }
    } catch (e) {
      print('SplashScreen: Initialization error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _statusMessage = 'Failed to initialize';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                  ]
                : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(context),
                  const SizedBox(height: 48),
                  _buildContent(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.restaurant_menu,
        size: 60,
        color: isDark
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_hasError) {
      return _buildErrorContent(context);
    }

    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onPrimary;

    return Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Theme.of(context).colorScheme.onPrimary,
            ),
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _statusMessage,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This may take a few moments',
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.onPrimary;
        
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: textColor, size: 60),
          const SizedBox(height: 16),
          Text(
            'Initialization Failed',
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                    _statusMessage = 'Retrying...';
                  });
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: () {
                  // Continue without AI (limited functionality)
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => widget.nextScreen),
                  );
                },
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
