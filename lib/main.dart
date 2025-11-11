import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/recipe_history/presentation/screens/home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'shared/widgets/splash_screen.dart';
import 'shared/widgets/welcome_screen.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Note: Firebase AI (Gemini) is initialized lazily when GeminiAIService is first used
  // No upfront initialization needed - it will use Firebase credentials automatically

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox(AppConstants.hiveRecipeBox);
  await Hive.openBox(AppConstants.hivePreferencesBox);

  runApp(
    // Wrap app with ProviderScope for Riverpod
    const ProviderScope(child: MyApp()),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      key: const ValueKey('main_app'),
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        // Fix viewport/scaling issues by wrapping in LayoutBuilder
        return LayoutBuilder(
          builder: (context, constraints) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.3,
                ),
              ),
              child: child!,
            );
          },
        );
      },
      // Start with welcome screen that checks auth
      home: const SplashScreen(nextScreen: WelcomeScreen()),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
