/// Rate limiting exceptions for API quota management
///
/// Uses 5-hour windows aligned with meal cycles (breakfast → lunch → dinner)
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
    return '$message\n\nYou\'ve used $currentCount of $maxAllowed $type.\nMore credits available in $resetTime.';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hour${hours != 1 ? 's' : ''} and $minutes minute${minutes != 1 ? 's' : ''}';
      }
      return '$hours hour${hours != 1 ? 's' : ''}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    } else {
      return 'less than a minute';
    }
  }
}

/// Thrown when window-based recipe generation limit is exceeded (5-hour window)
class RecipeGenerationWindowLimitException extends RateLimitException {
  RecipeGenerationWindowLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Recipe credits used up for now',
         type: 'recipes this session',
       );
}

/// Thrown when daily recipe generation limit is exceeded
class RecipeGenerationDailyLimitException extends RateLimitException {
  RecipeGenerationDailyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(message: 'Daily recipe limit reached', type: 'recipes today');
}

/// Thrown when window-based ingredient detection limit is exceeded (5-hour window)
class IngredientDetectionWindowLimitException extends RateLimitException {
  IngredientDetectionWindowLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Scan credits used up for now',
         type: 'scans this session',
       );
}

/// Thrown when daily ingredient detection limit is exceeded
class IngredientDetectionDailyLimitException extends RateLimitException {
  IngredientDetectionDailyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(message: 'Daily scan limit reached', type: 'scans today');
}

/// Thrown when window-based chat message limit is exceeded (5-hour window)
class ChatMessageWindowLimitException extends RateLimitException {
  ChatMessageWindowLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(
         message: 'Chat credits used up for now',
         type: 'messages this session',
       );
}

/// Thrown when daily chat message limit is exceeded
class ChatMessageDailyLimitException extends RateLimitException {
  ChatMessageDailyLimitException({
    required super.currentCount,
    required super.maxAllowed,
    required super.resetIn,
  }) : super(message: 'Daily chat limit reached', type: 'messages today');
}

// Legacy aliases for backward compatibility
typedef RecipeGenerationHourlyLimitException =
    RecipeGenerationWindowLimitException;
typedef IngredientDetectionHourlyLimitException =
    IngredientDetectionWindowLimitException;
