import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_sync_service.dart';
import './firebase_provider.dart';

/// Provider for Firestore sync service
final firestoreSyncServiceProvider = Provider<FirestoreSyncService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return FirestoreSyncService(firestore, auth);
});
