import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../models/user_preferences_model.dart';

/// Firestore implementation of UserPreferencesRepository
class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final FirebaseFirestore _firestore;

  UserPreferencesRepositoryImpl(this._firestore);

  @override
  Future<UserPreferences?> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;

      return UserPreferencesModel.fromJson(data).toEntity();
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
      data['updated_at'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('user_preferences')
          .doc(preferences.userId)
          .set(data, SetOptions(merge: true));

      final updatedPrefs = await getUserPreferences(preferences.userId);
      if (updatedPrefs == null) {
        throw Exception('Failed to retrieve updated preferences');
      }

      return updatedPrefs;
    } catch (e) {
      throw Exception('Failed to upsert user preferences: $e');
    }
  }

  @override
  Future<void> deleteUserPreferences(String userId) async {
    try {
      await _firestore.collection('user_preferences').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user preferences: $e');
    }
  }
}
