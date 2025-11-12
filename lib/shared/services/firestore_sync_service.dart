import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';

/// Service to sync Hive local storage with Firestore
/// Handles offline-first approach with cloud backup
class FirestoreSyncService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreSyncService(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  /// Load user data from Firestore and cache to Hive
  Future<void> syncFromFirestore() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      // Sync pantry items
      await _syncPantryFromFirestore(userId);

      // Sync favorites
      await _syncFavoritesFromFirestore(userId);

      // Sync preferences
      await _syncPreferencesFromFirestore(userId);
    } catch (e) {
      print('Error syncing from Firestore: $e');
      // Continue using cached Hive data
    }
  }

  /// Upload local Hive data to Firestore
  Future<void> syncToFirestore() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      // Sync pantry items
      await _syncPantryToFirestore(userId);

      // Sync favorites
      await _syncFavoritesToFirestore(userId);

      // Sync preferences
      await _syncPreferencesToFirestore(userId);
    } catch (e) {
      print('Error syncing to Firestore: $e');
      // Data remains in Hive, will retry next time
    }
  }

  /// Clear all local Hive data (on logout)
  Future<void> clearLocalData() async {
    try {
      final recipeBox = Hive.box(AppConstants.hiveRecipeBox);
      final prefsBox = Hive.box(AppConstants.hivePreferencesBox);

      await Future.wait([
        recipeBox.clear(),
        prefsBox.clear(),
      ]);
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // PANTRY SYNC
  Future<void> _syncPantryFromFirestore(String userId) async {
    final doc = await _firestore
        .collection('user_data')
        .doc(userId)
        .collection('pantry')
        .doc('items')
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final items = (data['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

      final prefsBox = Hive.box(AppConstants.hivePreferencesBox);
      prefsBox.put('pantryIngredients', items);
    }
  }

  Future<void> _syncPantryToFirestore(String userId) async {
    final prefsBox = Hive.box(AppConstants.hivePreferencesBox);
    final items = prefsBox.get('pantryIngredients', defaultValue: <dynamic>[]);

    await _firestore
        .collection('user_data')
        .doc(userId)
        .collection('pantry')
        .doc('items')
        .set({
      'items': items,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // FAVORITES SYNC
  Future<void> _syncFavoritesFromFirestore(String userId) async {
    final snapshot = await _firestore
        .collection('recipes')
        .where('user_id', isEqualTo: userId)
        .where('is_favorite', isEqualTo: true)
        .get();

    final favorites = snapshot.docs.map((doc) => doc.data()).toList();

    final recipeBox = Hive.box(AppConstants.hiveRecipeBox);
    recipeBox.put('favoriteRecipes', favorites);
  }

  Future<void> _syncFavoritesToFirestore(String userId) async {
    final recipeBox = Hive.box(AppConstants.hiveRecipeBox);
    final favorites =
        recipeBox.get('favoriteRecipes', defaultValue: <dynamic>[]) as List;

    // Update each favorite recipe in Firestore
    for (final recipe in favorites) {
      if (recipe is Map) {
        final recipeId = recipe['id'] as String?;
        if (recipeId != null) {
          await _firestore.collection('recipes').doc(recipeId).set(
            {
              ...Map<String, dynamic>.from(recipe),
              'user_id': userId,
              'is_favorite': true,
              'updated_at': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }
    }
  }

  // PREFERENCES SYNC
  Future<void> _syncPreferencesFromFirestore(String userId) async {
    final doc =
        await _firestore.collection('user_preferences').doc(userId).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;

      final prefsBox = Hive.box(AppConstants.hivePreferencesBox);

      // Store dietary profile
      prefsBox.put('dietaryRestrictions', data['dietary_restrictions'] ?? []);
      prefsBox.put('skillLevels', data['skill_levels'] ?? []);
      prefsBox.put('cuisinePreferences', data['cuisine_preferences'] ?? []);
      prefsBox.put('measurementSystem', data['measurement_system'] ?? 'metric');
    }
  }

  Future<void> _syncPreferencesToFirestore(String userId) async {
    final prefsBox = Hive.box(AppConstants.hivePreferencesBox);

    await _firestore.collection('user_preferences').doc(userId).set({
      'dietary_restrictions':
          prefsBox.get('dietaryRestrictions', defaultValue: []),
      'skill_levels': prefsBox.get('skillLevels', defaultValue: []),
      'cuisine_preferences':
          prefsBox.get('cuisinePreferences', defaultValue: []),
      'measurement_system':
          prefsBox.get('measurementSystem', defaultValue: 'metric'),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Listen to Firestore changes and update Hive (real-time sync)
  Stream<void> listenToFirestoreChanges() async* {
    final userId = _userId;
    if (userId == null) return;

    // Listen to pantry changes
    _firestore
        .collection('user_data')
        .doc(userId)
        .collection('pantry')
        .doc('items')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        final items = data['items'] ?? [];

        final prefsBox = Hive.box(AppConstants.hivePreferencesBox);
        prefsBox.put('pantryIngredients', items);
      }
    });

    // Listen to preferences changes
    _firestore.collection('user_preferences').doc(userId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final data = snapshot.data()!;
          final prefsBox = Hive.box(AppConstants.hivePreferencesBox);

          prefsBox.put('dietaryRestrictions', data['dietary_restrictions'] ?? []);
          prefsBox.put('skillLevels', data['skill_levels'] ?? []);
          prefsBox.put('cuisinePreferences', data['cuisine_preferences'] ?? []);
          prefsBox.put(
            'measurementSystem',
            data['measurement_system'] ?? 'metric',
          );
        }
      },
    );
  }
}
