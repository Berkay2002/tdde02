import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';

/// Firebase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final Box? _recipeBox;
  final Box? _prefsBox;

  AuthRepositoryImpl(
    this._auth,
    this._firestore,
    this._googleSignIn, {
    Box? recipeBox,
    Box? prefsBox,
  }) : _recipeBox = recipeBox,
       _prefsBox = prefsBox;

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Update display name if provided
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Create profile document in Firestore
      final now = DateTime.now();
      final profileData = {
        'id': user.uid,
        'email': email,
        'display_name': displayName ?? email.split('@')[0],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('profiles').doc(user.uid).set(profileData);
      } catch (e) {
        // If profile creation fails, delete the auth user to maintain consistency
        await user.delete();
        throw Exception('Failed to create profile in database: $e');
      }

      // DON'T create default user preferences here - let onboarding handle it
      // This way we can check if preferences exist to determine if onboarding is complete

      // Initialize empty Firestore collections for new user
      try {
        await _initializeFirestoreCollections(user.uid);
      } catch (e) {
        print('Warning: Failed to initialize collections: $e');
        // Non-critical, collections can be created later
      }

      // Return profile directly instead of reading it back
      // (avoids timing issues with serverTimestamp)
      return Profile(
        id: user.uid,
        email: email,
        displayName: displayName ?? email.split('@')[0],
        createdAt: now,
        updatedAt: now,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<Profile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      final profile = await getCurrentProfile();
      if (profile == null) {
        throw Exception('Failed to get profile after sign in');
      }

      // Sync data from Firestore to Hive
      await _syncFromFirestore(userCredential.user!.uid);

      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<Profile> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Sign in with Google failed: No user returned');
      }

      // Check if profile already exists
      final existingProfile = await getCurrentProfile();
      if (existingProfile != null) {
        // Existing user - sync from Firestore
        try {
          await _syncFromFirestore(user.uid);
        } catch (e) {
          print('Warning: Sync from Firestore failed: $e');
          // Continue anyway - user can work offline
        }
        return existingProfile;
      }

      // Create new profile for first-time Google sign-in
      final now = DateTime.now();
      final profileData = {
        'id': user.uid,
        'email': user.email ?? '',
        'display_name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'avatar_url': user.photoURL,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      try {
        await _firestore.collection('profiles').doc(user.uid).set(profileData);
      } catch (e) {
        // If profile creation fails, sign out to maintain consistency
        await _auth.signOut();
        throw Exception('Failed to create user profile in Firestore: $e');
      }

      // DON'T create default user preferences here - let onboarding handle it
      // This way we can check if preferences exist to determine if onboarding is complete

      // Initialize empty Firestore collections for new user
      try {
        await _initializeFirestoreCollections(user.uid);
      } catch (e) {
        print('Warning: Failed to initialize Firestore collections: $e');
        // Non-critical, collections can be created on first write
      }

      // Return profile directly instead of reading it back
      return Profile(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
        avatarUrl: user.photoURL,
        createdAt: now,
        updatedAt: now,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final userId = _auth.currentUser?.uid;

      // Sync local changes to Firestore before signing out
      if (userId != null) {
        try {
          await _syncToFirestore(userId);
        } catch (e) {
          print('Warning: Failed to sync to Firestore on logout: $e');
          // Continue with logout anyway
        }
      }

      // Sign out from Firebase and Google
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);

      // Clear all local Hive storage
      final recipeBox = _recipeBox ?? Hive.box('recipe_box');
      final prefsBox = _prefsBox ?? Hive.box('preferences_box');

      await Future.wait([recipeBox.clear(), prefsBox.clear()]);
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('profiles').doc(user.uid).get();

      if (!doc.exists) return null;

      final data = doc.data();
      if (data == null) return null;

      return ProfileModel.fromJson(data).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final updateData = ProfileModel.fromEntity(profile).toJson();
      updateData['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('profiles')
          .doc(profile.id)
          .update(updateData);

      final updatedProfile = await getCurrentProfile();
      if (updatedProfile == null) {
        throw Exception('Failed to get updated profile');
      }

      return updatedProfile;
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  @override
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  @override
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // SYNC HELPER METHODS

  /// Sync data from Firestore to Hive (download)
  Future<void> _syncFromFirestore(String userId) async {
    try {
      final recipeBox = _recipeBox ?? Hive.box(AppConstants.hiveRecipeBox);
      final prefsBox = _prefsBox ?? Hive.box(AppConstants.hivePreferencesBox);

      // Sync pantry
      final pantryDoc = await _firestore
          .collection('user_data')
          .doc(userId)
          .collection('pantry')
          .doc('items')
          .get();

      if (pantryDoc.exists && pantryDoc.data() != null) {
        final items = pantryDoc.data()!['items'] ?? [];
        prefsBox.put('pantryIngredients', items);
      }

      // Sync favorites from recipes collection
      final favSnapshot = await _firestore
          .collection('recipes')
          .where('user_id', isEqualTo: userId)
          .where('is_favorite', isEqualTo: true)
          .get();

      final favorites = favSnapshot.docs.map((doc) => doc.data()).toList();
      recipeBox.put('favoriteRecipes', favorites);

      // Sync preferences
      final prefsDoc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (prefsDoc.exists && prefsDoc.data() != null) {
        final data = prefsDoc.data()!;
        prefsBox.put('dietaryRestrictions', data['dietary_restrictions'] ?? []);
        prefsBox.put('skillLevels', data['skill_levels'] ?? []);
        prefsBox.put('cuisinePreferences', data['cuisine_preferences'] ?? []);
        prefsBox.put(
          'measurementSystem',
          data['measurement_system'] ?? 'metric',
        );
      }
    } catch (e) {
      print('Error syncing from Firestore: $e');
      // Continue with cached data
    }
  }

  /// Sync data from Hive to Firestore (upload)
  Future<void> _syncToFirestore(String userId) async {
    try {
      final recipeBox = _recipeBox ?? Hive.box(AppConstants.hiveRecipeBox);
      final prefsBox = _prefsBox ?? Hive.box(AppConstants.hivePreferencesBox);

      // Sync pantry
      final pantryItems = prefsBox.get(
        'pantryIngredients',
        defaultValue: <dynamic>[],
      );
      await _firestore
          .collection('user_data')
          .doc(userId)
          .collection('pantry')
          .doc('items')
          .set({
            'items': pantryItems,
            'updated_at': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // Sync favorites
      final favorites =
          recipeBox.get('favoriteRecipes', defaultValue: <dynamic>[]) as List;
      for (final recipe in favorites) {
        if (recipe is Map) {
          final recipeId = recipe['id'] as String?;
          if (recipeId != null) {
            await _firestore.collection('recipes').doc(recipeId).set({
              ...Map<String, dynamic>.from(recipe),
              'user_id': userId,
              'is_favorite': true,
              'updated_at': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }

      // Sync preferences
      await _firestore.collection('user_preferences').doc(userId).set({
        'dietary_restrictions': prefsBox.get(
          'dietaryRestrictions',
          defaultValue: [],
        ),
        'skill_levels': prefsBox.get('skillLevels', defaultValue: []),
        'cuisine_preferences': prefsBox.get(
          'cuisinePreferences',
          defaultValue: [],
        ),
        'measurement_system': prefsBox.get(
          'measurementSystem',
          defaultValue: 'metric',
        ),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error syncing to Firestore: $e');
      // Data remains in Hive for next sync attempt
    }
  }

  /// Initialize empty Firestore collections for new user
  Future<void> _initializeFirestoreCollections(String userId) async {
    try {
      // Initialize empty pantry
      await _firestore
          .collection('user_data')
          .doc(userId)
          .collection('pantry')
          .doc('items')
          .set({
            'items': [],
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error initializing Firestore collections: $e');
      // Non-critical, can be created later
    }
  }
}
