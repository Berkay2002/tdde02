import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';
import '../errors/ai_exceptions.dart';

/// Image preprocessing utilities for AI inference
class ImageProcessor {
  /// Preprocess image for Gemma 3n model inference
  /// Resizes to 512x512 and normalizes pixel values
  /// Uses compute() for heavy processing on a separate isolate
  static Future<Uint8List> preprocessForInference(Uint8List imageBytes) async {
    try {
      return await compute(_preprocessImageIsolate, imageBytes);
    } catch (e) {
      throw ImagePreprocessingException('Failed to preprocess image', e);
    }
  }

  static Uint8List _preprocessImageIsolate(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw ImagePreprocessingException('Failed to decode image');
      }

      // Resize to model's expected input size
      final resized = img.copyResize(
        image,
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
        interpolation: img.Interpolation.linear,
      );

      // Encode back to JPEG for model input
      final processedBytes = Uint8List.fromList(
        img.encodeJpg(resized, quality: AppConstants.imageQuality),
      );

      return processedBytes;
    } catch (e) {
      throw ImagePreprocessingException('Image preprocessing failed: $e');
    }
  }

  /// Preprocess image and convert to normalized Float32 array
  /// This is the format expected by MediaPipe LLM models for advanced processing
  static Future<Float32List> preprocessToFloat32(Uint8List imageBytes) async {
    try {
      return await compute(_preprocessToFloat32Isolate, imageBytes);
    } catch (e) {
      throw ImagePreprocessingException('Failed to convert to Float32', e);
    }
  }

  static Float32List _preprocessToFloat32Isolate(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw ImagePreprocessingException('Failed to decode image');
      }

      // Resize to model's expected input size
      final resized = img.copyResize(
        image,
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
        interpolation: img.Interpolation.linear,
      );

      // Convert to Float32 and normalize to [0, 1]
      final float32Data = Float32List(
        AppConstants.imageSize * AppConstants.imageSize * 3,
      );

      int index = 0;
      for (int y = 0; y < resized.height; y++) {
        for (int x = 0; x < resized.width; x++) {
          final pixel = resized.getPixel(x, y);
          float32Data[index++] = pixel.r / 255.0; // Red
          float32Data[index++] = pixel.g / 255.0; // Green
          float32Data[index++] = pixel.b / 255.0; // Blue
        }
      }

      return float32Data;
    } catch (e) {
      throw ImagePreprocessingException('Float32 conversion failed: $e');
    }
  }

  /// Load and preprocess image from file path
  static Future<Uint8List> preprocessFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final imageBytes = await file.readAsBytes();
      return await preprocessForInference(imageBytes);
    } catch (e) {
      throw Exception('Failed to load image from file: $e');
    }
  }

  /// Normalize pixel values for model input
  /// Converts to float32 normalized to [0, 1] range
  static List<List<List<double>>> normalizePixels(img.Image image) {
    final normalized = List.generate(
      image.height,
      (y) => List.generate(
        image.width,
        (x) {
          final pixel = image.getPixel(x, y);
          return [
            pixel.r / 255.0, // Red channel
            pixel.g / 255.0, // Green channel
            pixel.b / 255.0, // Blue channel
          ];
        },
      ),
    );

    return normalized;
  }

  /// Create thumbnail for preview
  static Future<Uint8List> createThumbnail(
    Uint8List imageBytes, {
    int maxWidth = 300,
    int maxHeight = 300,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate aspect ratio
      final aspectRatio = image.width / image.height;
      int targetWidth = maxWidth;
      int targetHeight = maxHeight;

      if (aspectRatio > 1) {
        // Landscape
        targetHeight = (maxWidth / aspectRatio).round();
      } else {
        // Portrait
        targetWidth = (maxHeight * aspectRatio).round();
      }

      final thumbnail = img.copyResize(
        image,
        width: targetWidth,
        height: targetHeight,
        interpolation: img.Interpolation.linear,
      );

      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
    } catch (e) {
      throw Exception('Thumbnail creation failed: $e');
    }
  }

  /// Compress image to reduce file size
  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      var image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if dimensions specified
      if (maxWidth != null || maxHeight != null) {
        final targetWidth = maxWidth ?? image.width;
        final targetHeight = maxHeight ?? image.height;

        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      throw Exception('Image compression failed: $e');
    }
  }
}
