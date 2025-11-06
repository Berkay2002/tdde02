import '../entities/user_preferences.dart';

/// Abstract user preferences repository interface
abstract class UserPreferencesRepository {
  /// Get user preferences for a specific user
  Future<UserPreferences?> getUserPreferences(String userId);

  /// Create or update user preferences
  Future<UserPreferences> upsertUserPreferences(UserPreferences preferences);

  /// Delete user preferences
  Future<void> deleteUserPreferences(String userId);
}
