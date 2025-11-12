/// Rate limiting exceptions for API quota management
class RateLimitException implements Exception {
  final String message;
  final String type;
  final int currentCount;
  final int maxAllowed;
  final Duration resetIn;

  RateLimitException({
    required this.message,
    required this.type,
    required this.currentCount,
    required this.maxAllowed,
    required this.resetIn,
  });

  @override
  String toString() => message;

  /// Get user-friendly error message with helpful context
  String get userMessage {
    final resetTime = _formatDuration(resetIn);
    return '$message\n\nYou\'ve used $currentCount of $maxAllowed allowed $type.\nLimit resets in $resetTime.';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds != 1 ? 's' : ''}';
    }
  }
}

/// Thrown when hourly recipe generation limit is exceeded
class RecipeGenerationHourlyLimitException extends RateLimitException {
  RecipeGenerationHourlyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Recipe generation hourly limit exceeded',
         type: 'recipe generations per hour',
       );
}

/// Thrown when daily recipe generation limit is exceeded
class RecipeGenerationDailyLimitException extends RateLimitException {
  RecipeGenerationDailyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Recipe generation daily limit exceeded',
         type: 'recipe generations per day',
       );
}

/// Thrown when hourly ingredient detection limit is exceeded
class IngredientDetectionHourlyLimitException extends RateLimitException {
  IngredientDetectionHourlyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Ingredient detection hourly limit exceeded',
         type: 'ingredient scans per hour',
       );
}

/// Thrown when daily ingredient detection limit is exceeded
class IngredientDetectionDailyLimitException extends RateLimitException {
  IngredientDetectionDailyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Ingredient detection daily limit exceeded',
         type: 'ingredient scans per day',
       );
}
