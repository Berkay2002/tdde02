import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/user_preferences_provider.dart';
import '../../shared/providers/firebase_provider.dart';

/// Debug utilities for testing and development
/// These should only be used during development/testing

class DebugUtils {
  /// Reset user onboarding by deleting their preferences
  /// This allows you to test the onboarding flow multiple times
  static Future<void> resetUserOnboarding(WidgetRef ref) async {
    try {
      final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final firestore = ref.read(firestoreProvider);
      
      // Delete the user preferences document
      await firestore
          .collection('user_preferences')
          .doc(userId)
          .delete();

      // Invalidate the cache so it refreshes
      ref.invalidate(currentUserPreferencesProvider);
      ref.invalidate(userPreferencesNotifierProvider);

      print('✅ Onboarding reset for user: $userId');
    } catch (e) {
      print('❌ Failed to reset onboarding: $e');
      rethrow;
    }
  }

  /// Quick method to create test user preferences
  /// Useful for testing the app state after onboarding
  static Future<void> createTestUserPreferences(WidgetRef ref) async {
    try {
      final userId = ref.read(firebaseAuthProvider).currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final firestore = ref.read(firestoreProvider);
      final now = DateTime.now();

      // Create test preferences
      await firestore
          .collection('user_preferences')
          .doc(userId)
          .set({
            'userId': userId,
            'skillLevel': 'intermediate',
            'spiceTolerance': 'medium',
            'cookingTimePreference': 'moderate',
            'dietaryRestrictions': [],
            'excludedIngredients': [],
            'favoriteCuisines': ['italian', 'asian'],
            'favoriteProteins': ['chicken', 'fish'],
            'kitchenEquipment': [],
            'servingSizePreference': 2,
            'createdAt': now,
            'updatedAt': now,
          });

      // Invalidate cache
      ref.invalidate(currentUserPreferencesProvider);
      ref.invalidate(userPreferencesNotifierProvider);

      print('✅ Test preferences created for user: $userId');
    } catch (e) {
      print('❌ Failed to create test preferences: $e');
      rethrow;
    }
  }
}
