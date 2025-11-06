import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image preprocessing utilities for AI inference
class ImageProcessor {
  /// Preprocess image for Gemma 3n model inference
  /// Resizes to 512x512 and normalizes pixel values
  static Future<Uint8List> preprocessForInference(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize to 512x512 (Gemma 3n recommended size)
      final resized = img.copyResize(
        image,
        width: 512,
        height: 512,
        interpolation: img.Interpolation.linear,
      );

      // Convert to RGB (remove alpha channel if present)
      final rgb = img.Image.from(resized);

      // Encode back to bytes
      final processedBytes = Uint8List.fromList(img.encodeJpg(rgb, quality: 85));

      return processedBytes;
    } catch (e) {
      throw Exception('Image preprocessing failed: $e');
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
