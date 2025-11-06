import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../../data/repositories/user_preferences_repository_impl.dart';

part 'user_preferences_provider.g.dart';

/// Provider for UserPreferencesRepository
@riverpod
UserPreferencesRepository userPreferencesRepository(
  UserPreferencesRepositoryRef ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return UserPreferencesRepositoryImpl(supabase);
}

/// Provider for current user preferences
@riverpod
Future<UserPreferences?> currentUserPreferences(
  CurrentUserPreferencesRef ref,
) async {
  final userId = ref.watch(supabaseProvider).auth.currentUser?.id;
  if (userId == null) return null;

  final repository = ref.watch(userPreferencesRepositoryProvider);
  return await repository.getUserPreferences(userId);
}

/// User preferences notifier for managing user preferences
@riverpod
class UserPreferencesNotifier extends _$UserPreferencesNotifier {
  @override
  FutureOr<UserPreferences?> build() async {
    final userId = ref.watch(supabaseProvider).auth.currentUser?.id;
    if (userId == null) return null;

    final repository = ref.watch(userPreferencesRepositoryProvider);
    return await repository.getUserPreferences(userId);
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(userPreferencesRepositoryProvider);
      return await repository.upsertUserPreferences(preferences);
    });
  }
}
