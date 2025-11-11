import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_ai/firebase_ai.dart';
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

  // Initialize Supabase with hardcoded values (from .env)
  // Note: These are safe to expose as they are public API keys protected by RLS
  await Supabase.initialize(
    url: 'https://mqdflykfxutypueeffts.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1xZGZseWtmeHV0eXB1ZWVmZnRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MjU2NDMsImV4cCI6MjA3ODAwMTY0M30.mpyyTWbttUtGc0NXKEZcjrVc4ox7k---Htoci4ZguWk',
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Open Hive boxes
  await Hive.openBox(AppConstants.hiveRecipeBox);
  await Hive.openBox(AppConstants.hivePreferencesBox);

  // Initialize the Gemini Developer API backend service
  // Create a GenerativeModel instance with a model that supports your use case
  final geminiModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  // Provide a prompt that contains text
  final prompt = [Content.text('Write a story about a magic backpack.')];

  // To generate text output, call generateContent with the text input
  final response = await geminiModel.generateContent(prompt);
  print(response.text);
  // Force a frame to ensure proper initialization
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Ensure first frame is drawn properly
  });

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
