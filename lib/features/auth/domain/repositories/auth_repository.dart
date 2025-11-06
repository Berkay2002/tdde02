import '../entities/profile.dart';

/// Abstract authentication repository interface
abstract class AuthRepository {
  /// Sign up with email and password
  Future<Profile> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign in with email and password
  Future<Profile> signIn({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current user profile
  Future<Profile?> getCurrentProfile();

  /// Update user profile
  Future<Profile> updateProfile(Profile profile);

  /// Check if user is authenticated
  bool isAuthenticated();

  /// Get current user ID
  String? getCurrentUserId();
}
