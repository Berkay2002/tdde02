import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../models/user_preferences_model.dart';

/// Supabase implementation of UserPreferencesRepository
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final SupabaseClient _supabase;

  UserPreferencesRepositoryImpl(this._supabase);

  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final response = await _supabase
          .from('user_preferences')
          .select()
          .eq('user_id', userId)
          .single();

      return UserPreferencesModel.fromJson(response).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserPreferences> upsertUserPreferences(
    UserPreferences preferences,
  ) async {
    try {
      final model = UserPreferencesModel.fromEntity(preferences);
      final data = model.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('user_preferences')
          .upsert(data)
          .select()
          .single();

      return UserPreferencesModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Failed to upsert user preferences: $e');
    }
  }

  @override
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await _supabase.from('user_preferences').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete user preferences: $e');
    }
  }
}
