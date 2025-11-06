/// Custom exceptions for the application
class AIInferenceException implements Exception {
  final String message;
  final dynamic originalError;

  AIInferenceException(this.message, [this.originalError]);

  @override
  String toString() => 'AIInferenceException: $message';
}

class ImageProcessingException implements Exception {
  final String message;
  final dynamic originalError;

  ImageProcessingException(this.message, [this.originalError]);

  @override
  String toString() => 'ImageProcessingException: $message';
}

class CameraException implements Exception {
  final String message;
  final dynamic originalError;

  CameraException(this.message, [this.originalError]);

  @override
  String toString() => 'CameraException: $message';
}

class StorageException implements Exception {
  final String message;
  final dynamic originalError;

  StorageException(this.message, [this.originalError]);

  @override
  String toString() => 'StorageException: $message';
}
