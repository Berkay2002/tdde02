import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../errors/rate_limit_exceptions.dart';

/// Service for enforcing user-level rate limits on Gemini API calls
///
/// Uses 5-hour windows aligned with meal cycles (breakfast → lunch → dinner)
/// plus daily caps. Tracks usage in Firestore `user_usage` collection.
///
/// **Pro Users**: Beta testers and approved users (via email whitelist) get
/// significantly higher limits. See [AppConstants.proUserEmails].
class RateLimiterService {
  final FirebaseFirestore _firestore;

  RateLimiterService(this._firestore);

  /// Check if an email belongs to a Pro user (beta tester / approved user)
  static bool isProUser(String? email) {
    if (email == null || email.isEmpty) return false;
    return AppConstants.proUserEmails.contains(email.toLowerCase());
  }

  /// Get the appropriate limits based on Pro status
  static Map<String, int> getLimitsForUser(String? email) {
    if (isProUser(email)) {
      return {
        'recipe_window': AppConstants.proMaxRecipeGenerationsPerWindow,
        'recipe_daily': AppConstants.proMaxRecipeGenerationsPerDay,
        'detection_window': AppConstants.proMaxIngredientDetectionsPerWindow,
        'detection_daily': AppConstants.proMaxIngredientDetectionsPerDay,
        'chat_window': AppConstants.proMaxChatMessagesPerWindow,
        'chat_daily': AppConstants.proMaxChatMessagesPerDay,
      };
    }
    return {
      'recipe_window': AppConstants.maxRecipeGenerationsPerWindow,
      'recipe_daily': AppConstants.maxRecipeGenerationsPerDay,
      'detection_window': AppConstants.maxIngredientDetectionsPerWindow,
      'detection_daily': AppConstants.maxIngredientDetectionsPerDay,
      'chat_window': AppConstants.maxChatMessagesPerWindow,
      'chat_daily': AppConstants.maxChatMessagesPerDay,
    };
  }

  /// Check if user can generate a recipe (enforces window and daily limits)
  ///
  /// [userEmail] is optional but enables Pro user detection for higher limits.
  /// Throws [RecipeGenerationWindowLimitException] or [RecipeGenerationDailyLimitException]
  /// if limit exceeded.
  Future<void> checkRecipeGenerationLimit(
    String userId, {
    String? userEmail,
  }) async {
    final limits = getLimitsForUser(userEmail);
    final isPro = isProUser(userEmail);

    if (isPro) {
      print('[RateLimiter] Pro user detected: $userEmail');
    }

    await _checkLimit(
      userId: userId,
      actionType: 'recipe_generation',
      windowLimit: limits['recipe_window']!,
      dailyLimit: limits['recipe_daily']!,
      windowExceptionBuilder: (current, max, resetIn) =>
          RecipeGenerationWindowLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
      dailyExceptionBuilder: (current, max, resetIn) =>
          RecipeGenerationDailyLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
    );
  }

  /// Check if user can detect ingredients (enforces window and daily limits)
  ///
  /// [userEmail] is optional but enables Pro user detection for higher limits.
  /// Throws [IngredientDetectionWindowLimitException] or [IngredientDetectionDailyLimitException]
  /// if limit exceeded.
  Future<void> checkIngredientDetectionLimit(
    String userId, {
    String? userEmail,
  }) async {
    final limits = getLimitsForUser(userEmail);
    final isPro = isProUser(userEmail);

    if (isPro) {
      print('[RateLimiter] Pro user detected: $userEmail');
    }

    await _checkLimit(
      userId: userId,
      actionType: 'ingredient_detection',
      windowLimit: limits['detection_window']!,
      dailyLimit: limits['detection_daily']!,
      windowExceptionBuilder: (current, max, resetIn) =>
          IngredientDetectionWindowLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
      dailyExceptionBuilder: (current, max, resetIn) =>
          IngredientDetectionDailyLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
    );
  }

  /// Increment recipe generation counter
  Future<void> incrementRecipeGeneration(String userId) async {
    await _incrementCounter(userId, 'recipe_generation');
  }

  /// Increment ingredient detection counter
  Future<void> incrementIngredientDetection(String userId) async {
    await _incrementCounter(userId, 'ingredient_detection');
  }

  /// Check if user can send a chat message (enforces window and daily limits)
  ///
  /// [userEmail] is optional but enables Pro user detection for higher limits.
  /// Throws [ChatMessageWindowLimitException] or [ChatMessageDailyLimitException]
  /// if limit exceeded.
  Future<void> checkChatMessageLimit(String userId, {String? userEmail}) async {
    final limits = getLimitsForUser(userEmail);
    final isPro = isProUser(userEmail);

    if (isPro) {
      print('[RateLimiter] Pro user detected for chat: $userEmail');
    }

    await _checkLimit(
      userId: userId,
      actionType: 'chat_message',
      windowLimit: limits['chat_window']!,
      dailyLimit: limits['chat_daily']!,
      windowExceptionBuilder: (current, max, resetIn) =>
          ChatMessageWindowLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
      dailyExceptionBuilder: (current, max, resetIn) =>
          ChatMessageDailyLimitException(
            currentCount: current,
            maxAllowed: max,
            resetIn: resetIn,
          ),
    );
  }

  /// Increment chat message counter
  Future<void> incrementChatMessage(String userId) async {
    await _incrementCounter(userId, 'chat_message');
  }

  /// Get current usage stats for a user (for UI display)
  Future<Map<String, dynamic>> getUserUsageStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.userUsageCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {
          'recipe_generation_window': 0,
          'recipe_generation_daily': 0,
          'ingredient_detection_window': 0,
          'ingredient_detection_daily': 0,
          'window_hours': AppConstants.rateLimitWindowHours,
        };
      }

      final data = doc.data()!;
      final now = DateTime.now();

      // Reset counters if expired
      final windowResetAt = (data['window_reset_at'] as Timestamp?)?.toDate();
      final dailyResetAt = (data['daily_reset_at'] as Timestamp?)?.toDate();

      final windowExpired = windowResetAt == null || now.isAfter(windowResetAt);
      final dailyExpired = dailyResetAt == null || now.isAfter(dailyResetAt);

      return {
        'recipe_generation_window': windowExpired
            ? 0
            : (data['recipe_generation_window'] ?? 0),
        'recipe_generation_daily': dailyExpired
            ? 0
            : (data['recipe_generation_daily'] ?? 0),
        'ingredient_detection_window': windowExpired
            ? 0
            : (data['ingredient_detection_window'] ?? 0),
        'ingredient_detection_daily': dailyExpired
            ? 0
            : (data['ingredient_detection_daily'] ?? 0),
        'window_reset_at': windowResetAt,
        'daily_reset_at': dailyResetAt,
        'window_hours': AppConstants.rateLimitWindowHours,
      };
    } catch (e) {
      print('[RateLimiter] Failed to get usage stats: $e');
      // Return zeros on error (graceful degradation)
      return {
        'recipe_generation_window': 0,
        'recipe_generation_daily': 0,
        'ingredient_detection_window': 0,
        'ingredient_detection_daily': 0,
        'window_hours': AppConstants.rateLimitWindowHours,
      };
    }
  }

  /// Core rate limiting logic using 5-hour windows
  Future<void> _checkLimit({
    required String userId,
    required String actionType,
    required int windowLimit,
    required int dailyLimit,
    required RateLimitException Function(int, int, Duration)
    windowExceptionBuilder,
    required RateLimitException Function(int, int, Duration)
    dailyExceptionBuilder,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.userUsageCollection)
          .doc(userId);
      final doc = await docRef.get();

      final now = DateTime.now();
      final windowHours = AppConstants.rateLimitWindowHours;
      final windowResetAt = now.add(Duration(hours: windowHours));
      final dailyResetAt = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      if (!doc.exists) {
        // First usage - create document with initial counters
        await docRef.set({
          'user_id': userId,
          '${actionType}_window': 0,
          '${actionType}_daily': 0,
          'window_reset_at': Timestamp.fromDate(windowResetAt),
          'daily_reset_at': Timestamp.fromDate(dailyResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = doc.data()!;

      // Get current counters
      int windowCount = data['${actionType}_window'] ?? 0;
      int dailyCount = data['${actionType}_daily'] ?? 0;

      // Get reset timestamps
      final storedWindowResetAt = (data['window_reset_at'] as Timestamp?)
          ?.toDate();
      final storedDailyResetAt = (data['daily_reset_at'] as Timestamp?)
          ?.toDate();

      // Check if counters need to be reset
      if (storedWindowResetAt != null && now.isAfter(storedWindowResetAt)) {
        windowCount = 0;
        // Also reset window counters for other action types
        await docRef.update({
          'recipe_generation_window': 0,
          'ingredient_detection_window': 0,
          'window_reset_at': Timestamp.fromDate(windowResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
      }

      if (storedDailyResetAt != null && now.isAfter(storedDailyResetAt)) {
        dailyCount = 0;
        // Also reset daily counters for other action types
        await docRef.update({
          'recipe_generation_daily': 0,
          'ingredient_detection_daily': 0,
          'daily_reset_at': Timestamp.fromDate(dailyResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
      }

      // Check window limit (5-hour window)
      if (windowCount >= windowLimit) {
        final resetIn = storedWindowResetAt != null
            ? storedWindowResetAt.difference(now)
            : Duration(hours: windowHours);

        print(
          '[RateLimiter] Window limit exceeded for $actionType: $windowCount/$windowLimit',
        );
        throw windowExceptionBuilder(windowCount, windowLimit, resetIn);
      }

      // Check daily limit
      if (dailyCount >= dailyLimit) {
        final resetIn = storedDailyResetAt != null
            ? storedDailyResetAt.difference(now)
            : Duration(hours: 24 - now.hour);

        print(
          '[RateLimiter] Daily limit exceeded for $actionType: $dailyCount/$dailyLimit',
        );
        throw dailyExceptionBuilder(dailyCount, dailyLimit, resetIn);
      }

      // All checks passed
      print(
        '[RateLimiter] $actionType allowed: window=$windowCount/$windowLimit, daily=$dailyCount/$dailyLimit',
      );
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      // Don't block on Firestore errors - graceful degradation
      print('[RateLimiter] Error checking limit (allowing request): $e');
    }
  }

  /// Increment usage counter (fire-and-forget)
  Future<void> _incrementCounter(String userId, String actionType) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.userUsageCollection)
          .doc(userId);
      final doc = await docRef.get();

      final now = DateTime.now();
      final windowHours = AppConstants.rateLimitWindowHours;
      final windowResetAt = now.add(Duration(hours: windowHours));
      final dailyResetAt = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      if (!doc.exists) {
        // Create initial document
        await docRef.set({
          'user_id': userId,
          '${actionType}_window': 1,
          '${actionType}_daily': 1,
          'window_reset_at': Timestamp.fromDate(windowResetAt),
          'daily_reset_at': Timestamp.fromDate(dailyResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Increment existing counters
      await docRef.update({
        '${actionType}_window': FieldValue.increment(1),
        '${actionType}_daily': FieldValue.increment(1),
        'last_updated': FieldValue.serverTimestamp(),
      });

      print('[RateLimiter] Incremented $actionType counter for user $userId');
    } catch (e) {
      // Don't fail on counter increment errors
      print('[RateLimiter] Failed to increment counter (non-critical): $e');
    }
  }

  /// Reset all counters for a user (admin function)
  Future<void> resetUserLimits(String userId) async {
    try {
      final now = DateTime.now();
      final windowHours = AppConstants.rateLimitWindowHours;
      final windowResetAt = now.add(Duration(hours: windowHours));
      final dailyResetAt = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      await _firestore
          .collection(AppConstants.userUsageCollection)
          .doc(userId)
          .set({
            'user_id': userId,
            'recipe_generation_window': 0,
            'recipe_generation_daily': 0,
            'ingredient_detection_window': 0,
            'ingredient_detection_daily': 0,
            'window_reset_at': Timestamp.fromDate(windowResetAt),
            'daily_reset_at': Timestamp.fromDate(dailyResetAt),
            'last_updated': FieldValue.serverTimestamp(),
          });

      print('[RateLimiter] Reset all limits for user $userId');
    } catch (e) {
      print('[RateLimiter] Failed to reset limits: $e');
      rethrow;
    }
  }
}
