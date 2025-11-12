import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../errors/rate_limit_exceptions.dart';

/// Service for enforcing user-level rate limits on Gemini API calls
/// 
/// Tracks usage in Firestore `user_usage` collection with hourly and daily counters.
/// Resets counters automatically based on timestamps.
class RateLimiterService {
  final FirebaseFirestore _firestore;

  RateLimiterService(this._firestore);

  /// Check if user can generate a recipe (enforces hourly and daily limits)
  /// 
  /// Throws [RecipeGenerationHourlyLimitException] or [RecipeGenerationDailyLimitException]
  /// if limit exceeded.
  Future<void> checkRecipeGenerationLimit(String userId) async {
    await _checkLimit(
      userId: userId,
      actionType: 'recipe_generation',
      hourlyLimit: AppConstants.maxRecipeGenerationsPerHour,
      dailyLimit: AppConstants.maxRecipeGenerationsPerDay,
      hourlyExceptionBuilder: (current, max, resetIn) =>
          RecipeGenerationHourlyLimitException(
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

  /// Check if user can detect ingredients (enforces hourly and daily limits)
  /// 
  /// Throws [IngredientDetectionHourlyLimitException] or [IngredientDetectionDailyLimitException]
  /// if limit exceeded.
  Future<void> checkIngredientDetectionLimit(String userId) async {
    await _checkLimit(
      userId: userId,
      actionType: 'ingredient_detection',
      hourlyLimit: AppConstants.maxIngredientDetectionsPerHour,
      dailyLimit: AppConstants.maxIngredientDetectionsPerDay,
      hourlyExceptionBuilder: (current, max, resetIn) =>
          IngredientDetectionHourlyLimitException(
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

  /// Get current usage stats for a user (for UI display)
  Future<Map<String, dynamic>> getUserUsageStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.userUsageCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return {
          'recipe_generation_hourly': 0,
          'recipe_generation_daily': 0,
          'ingredient_detection_hourly': 0,
          'ingredient_detection_daily': 0,
        };
      }

      final data = doc.data()!;
      final now = DateTime.now();

      // Reset counters if expired
      final hourlyResetAt = (data['hourly_reset_at'] as Timestamp?)?.toDate();
      final dailyResetAt = (data['daily_reset_at'] as Timestamp?)?.toDate();

      final hourlyExpired = hourlyResetAt == null || now.isAfter(hourlyResetAt);
      final dailyExpired = dailyResetAt == null || now.isAfter(dailyResetAt);

      return {
        'recipe_generation_hourly': hourlyExpired ? 0 : (data['recipe_generation_hourly'] ?? 0),
        'recipe_generation_daily': dailyExpired ? 0 : (data['recipe_generation_daily'] ?? 0),
        'ingredient_detection_hourly': hourlyExpired ? 0 : (data['ingredient_detection_hourly'] ?? 0),
        'ingredient_detection_daily': dailyExpired ? 0 : (data['ingredient_detection_daily'] ?? 0),
        'hourly_reset_at': hourlyResetAt,
        'daily_reset_at': dailyResetAt,
      };
    } catch (e) {
      print('[RateLimiter] Failed to get usage stats: $e');
      // Return zeros on error (graceful degradation)
      return {
        'recipe_generation_hourly': 0,
        'recipe_generation_daily': 0,
        'ingredient_detection_hourly': 0,
        'ingredient_detection_daily': 0,
      };
    }
  }

  /// Core rate limiting logic
  Future<void> _checkLimit({
    required String userId,
    required String actionType,
    required int hourlyLimit,
    required int dailyLimit,
    required RateLimitException Function(int, int, Duration) hourlyExceptionBuilder,
    required RateLimitException Function(int, int, Duration) dailyExceptionBuilder,
  }) async {
    try {
      final docRef = _firestore.collection(AppConstants.userUsageCollection).doc(userId);
      final doc = await docRef.get();

      final now = DateTime.now();
      final hourlyResetAt = now.add(const Duration(hours: 1));
      final dailyResetAt = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      if (!doc.exists) {
        // First usage - create document with initial counters
        await docRef.set({
          'user_id': userId,
          '${actionType}_hourly': 0,
          '${actionType}_daily': 0,
          'hourly_reset_at': Timestamp.fromDate(hourlyResetAt),
          'daily_reset_at': Timestamp.fromDate(dailyResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = doc.data()!;
      
      // Get current counters
      int hourlyCount = data['${actionType}_hourly'] ?? 0;
      int dailyCount = data['${actionType}_daily'] ?? 0;
      
      // Get reset timestamps
      final storedHourlyResetAt = (data['hourly_reset_at'] as Timestamp?)?.toDate();
      final storedDailyResetAt = (data['daily_reset_at'] as Timestamp?)?.toDate();

      // Check if counters need to be reset
      if (storedHourlyResetAt != null && now.isAfter(storedHourlyResetAt)) {
        hourlyCount = 0;
        // Also reset hourly counters for other action types
        await docRef.update({
          'recipe_generation_hourly': 0,
          'ingredient_detection_hourly': 0,
          'hourly_reset_at': Timestamp.fromDate(hourlyResetAt),
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

      // Check hourly limit
      if (hourlyCount >= hourlyLimit) {
        final resetIn = storedHourlyResetAt != null
            ? storedHourlyResetAt.difference(now)
            : const Duration(hours: 1);
        
        print('[RateLimiter] Hourly limit exceeded for $actionType: $hourlyCount/$hourlyLimit');
        throw hourlyExceptionBuilder(hourlyCount, hourlyLimit, resetIn);
      }

      // Check daily limit
      if (dailyCount >= dailyLimit) {
        final resetIn = storedDailyResetAt != null
            ? storedDailyResetAt.difference(now)
            : Duration(hours: 24 - now.hour);
        
        print('[RateLimiter] Daily limit exceeded for $actionType: $dailyCount/$dailyLimit');
        throw dailyExceptionBuilder(dailyCount, dailyLimit, resetIn);
      }

      // All checks passed
      print('[RateLimiter] $actionType allowed: hourly=$hourlyCount/$hourlyLimit, daily=$dailyCount/$dailyLimit');
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
      final docRef = _firestore.collection(AppConstants.userUsageCollection).doc(userId);
      final doc = await docRef.get();

      final now = DateTime.now();
      final hourlyResetAt = now.add(const Duration(hours: 1));
      final dailyResetAt = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      if (!doc.exists) {
        // Create initial document
        await docRef.set({
          'user_id': userId,
          '${actionType}_hourly': 1,
          '${actionType}_daily': 1,
          'hourly_reset_at': Timestamp.fromDate(hourlyResetAt),
          'daily_reset_at': Timestamp.fromDate(dailyResetAt),
          'last_updated': FieldValue.serverTimestamp(),
        });
        return;
      }

      // Increment existing counters
      await docRef.update({
        '${actionType}_hourly': FieldValue.increment(1),
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
      final hourlyResetAt = now.add(const Duration(hours: 1));
      final dailyResetAt = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

      await _firestore.collection(AppConstants.userUsageCollection).doc(userId).set({
        'user_id': userId,
        'recipe_generation_hourly': 0,
        'recipe_generation_daily': 0,
        'ingredient_detection_hourly': 0,
        'ingredient_detection_daily': 0,
        'hourly_reset_at': Timestamp.fromDate(hourlyResetAt),
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
