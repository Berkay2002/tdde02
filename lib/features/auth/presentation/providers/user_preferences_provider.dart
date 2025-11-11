import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/providers/firebase_provider.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';

part 'user_preferences_provider.g.dart';

/// Provider for UserPreferencesRepository
@riverpod
UserPreferencesRepository userPreferencesRepository(
  UserPreferencesRepositoryRef ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return UserPreferencesRepositoryImpl(firestore);
}

/// Provider for current user preferences
@riverpod
Future<UserPreferences?> currentUserPreferences(
  CurrentUserPreferencesRef ref,
) async {
  final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
  if (userId == null) return null;

  final repository = ref.watch(userPreferencesRepositoryProvider);
  return await repository.getUserPreferences(userId);
}

/// User preferences notifier for managing user preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  FutureOr<UserPreferences?> build() async {
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    if (userId == null) return null;

    final repository = ref.watch(userPreferencesRepositoryProvider);
    return await repository.getUserPreferences(userId);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      final updated = await repository.upsertUserPreferences(preferences);
      // Invalidate the current user preferences provider to refresh
      ref.invalidate(currentUserPreferencesProvider);
      return updated;
    });
  }
}
