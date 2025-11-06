import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../shared/providers/supabase_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

/// Provider for AuthRepository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthRepositoryImpl(supabase);
}

/// Provider for current user profile
@riverpod
Future<Profile?> currentUserProfile(CurrentUserProfileRef ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  return await authRepository.getCurrentProfile();
}

/// Provider for auth state (authenticated or not)
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.isAuthenticated();
}

/// Auth notifier for handling authentication actions
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<Profile?> build() async {
    final authRepository = ref.watch(authRepositoryProvider);
    return await authRepository.getCurrentProfile();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return await authRepository.signIn(email: email, password: password);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return await authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> updateProfile(Profile profile) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      return await authRepository.updateProfile(profile);
    });
  }
}
