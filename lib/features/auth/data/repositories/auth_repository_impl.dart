import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';

/// Firebase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._auth, this._firestore, this._googleSignIn);

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
      final profileData = {
        'id': user.uid,
        'email': email,
        'display_name': displayName ?? email.split('@')[0],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('profiles').doc(user.uid).set(profileData);

      // Create default user preferences
      final preferencesData = {
        'user_id': user.uid,
        'dietary_restrictions': <String>[],
        'allergies': <String>[],
        'cuisine_preferences': <String>[],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('user_preferences')
          .doc(user.uid)
          .set(preferencesData);

      final profile = await getCurrentProfile();
      if (profile == null) {
        throw Exception('Failed to create profile');
      }

      return profile;
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
        return existingProfile;
      }

      // Create new profile for first-time Google sign-in
      final profileData = {
        'id': user.uid,
        'email': user.email ?? '',
        'display_name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'avatar_url': user.photoURL,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('profiles').doc(user.uid).set(profileData);

      // Create default user preferences
      final preferencesData = {
        'user_id': user.uid,
        'dietary_restrictions': <String>[],
        'allergies': <String>[],
        'cuisine_preferences': <String>[],
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('user_preferences')
          .doc(user.uid)
          .set(preferencesData);

      final profile = await getCurrentProfile();
      if (profile == null) {
        throw Exception('Failed to create profile');
      }

      return profile;
    } on FirebaseAuthException catch (e) {
      throw Exception('Google sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
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
}
