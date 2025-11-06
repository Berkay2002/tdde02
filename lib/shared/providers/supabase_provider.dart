import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Global provider for Supabase client
@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

/// Provider for current user session
@riverpod
Stream<AuthState> authStateChanges(AuthStateChangesRef ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.onAuthStateChange;
}

/// Provider for current user
@riverpod
User? currentUser(CurrentUserRef ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.currentUser;
}
