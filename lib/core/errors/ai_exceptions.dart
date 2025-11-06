/// Base exception for AI-related errors
class AIException implements Exception {
  final String message;
  final dynamic originalError;

  AIException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'AIException: $message\nCaused by: $originalError';
    }
    return 'AIException: $message';
  }
}

/// Exception thrown when model fails to load
class ModelLoadException extends AIException {
  ModelLoadException(super.message, [super.originalError]);

  @override
  String toString() => 'ModelLoadException: $message';
}

/// Exception thrown when trying to use uninitialized model
class ModelNotInitializedException extends AIException {
  ModelNotInitializedException(super.message);

  @override
  String toString() => 'ModelNotInitializedException: $message';
}

/// Exception thrown when inference fails
class InferenceException extends AIException {
  InferenceException(super.message, [super.originalError]);

  @override
  String toString() => 'InferenceException: $message';
}

/// Exception thrown when inference times out
class InferenceTimeoutException extends AIException {
  final Duration timeout;

  InferenceTimeoutException(this.timeout)
    : super('Inference operation timed out after ${timeout.inSeconds} seconds');

  @override
  String toString() => 'InferenceTimeoutException: $message';
}

/// Exception thrown when image preprocessing fails
class ImagePreprocessingException extends AIException {
  ImagePreprocessingException(super.message, [super.originalError]);

  @override
  String toString() => 'ImagePreprocessingException: $message';
}
