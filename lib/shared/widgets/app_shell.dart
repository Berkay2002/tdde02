import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/pantry/presentation/screens/my_pantry_screen.dart';
import '../../features/recipe_results/presentation/screens/recipe_results_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// AppShell - The main navigation container for the app
/// 
/// This widget serves as the "Container" that holds the bottom navigation bar
/// and switches between the 5 main screens. It has no data logic - just navigation.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  // The 5 main screens
  static const List<Widget> _screens = [
    HomeScreen(),           // Tab 0: Quick scan/search
    MyPantryScreen(),       // Tab 1: Pantry management
    RecipeResultsScreen(),  // Tab 2: Recipe results
    FavoritesScreen(),      // Tab 3: Saved favorites
    ProfileScreen(),        // Tab 4: User profile
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Public method to allow other widgets to switch tabs
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.primaryContainer,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
            tooltip: 'Quick scan or search',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'My Pantry',
            tooltip: 'Manage your pantry',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Recipes',
            tooltip: 'Browse recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
            tooltip: 'Your favorite recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
            tooltip: 'Your profile and preferences',
          ),
        ],
      ),
    );
  }
}

/// Global key to access AppShell's state from anywhere
/// This allows screens to programmatically switch tabs
final appShellKey = GlobalKey<_AppShellState>();

/// Helper function to switch tabs from anywhere in the app
void switchToRecipeTab(BuildContext context) {
  appShellKey.currentState?.switchToTab(2);
}

void switchToHomeTab(BuildContext context) {
  appShellKey.currentState?.switchToTab(0);
}

void switchToPantryTab(BuildContext context) {
  appShellKey.currentState?.switchToTab(1);
}

void switchToFavoritesTab(BuildContext context) {
  appShellKey.currentState?.switchToTab(3);
}

void switchToProfileTab(BuildContext context) {
  appShellKey.currentState?.switchToTab(4);
}
