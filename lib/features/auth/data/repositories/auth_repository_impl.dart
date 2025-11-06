import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/profile_model.dart';

/// Supabase implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<Profile> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Create profile in profiles table
      final profileData = {
        'id': response.user!.id,
        'email': email,
        'display_name': displayName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('profiles').insert(profileData);

      // Create default user preferences
      final preferencesData = {
        'user_id': response.user!.id,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_preferences').insert(preferencesData);

      // Fetch the created profile
      final profile = await getCurrentProfile();
      if (profile == null) {
        throw Exception('Failed to create profile');
      }

      return profile;
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
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      final profile = await getCurrentProfile();
      if (profile == null) {
        throw Exception('Failed to get profile after sign in');
      }

      return profile;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  @override
  Future<Profile?> getCurrentProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return ProfileModel.fromJson(response).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    try {
      final updateData = ProfileModel.fromEntity(profile).toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', profile.id)
          .select()
          .single();

      return ProfileModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Update profile failed: $e');
    }
  }

  @override
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  @override
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
