import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/services/rate_limiter_service.dart';
import '../../core/services/gemini_ai_service.dart';

part 'services_provider.g.dart';

/// Provider for Firestore instance
@Riverpod(keepAlive: true)
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider for RateLimiterService singleton
@Riverpod(keepAlive: true)
RateLimiterService rateLimiterService(Ref ref) {
  final firestore = ref.watch(firestoreProvider);
  return RateLimiterService(firestore);
}

/// Provider for GeminiAIService singleton with rate limiting
@Riverpod(keepAlive: true)
GeminiAIService geminiAIService(Ref ref) {
  final rateLimiter = ref.watch(rateLimiterServiceProvider);
  final service = GeminiAIService(rateLimiter);

  // Dispose when provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
