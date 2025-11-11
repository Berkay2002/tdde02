import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import '../../../../core/services/gemini_ai_service.dart';
import '../../../../core/utils/image_processor.dart';
import '../../../../core/errors/ai_exceptions.dart';
import '../../domain/entities/detected_ingredients.dart';

part 'ingredient_detection_provider.g.dart';

/// Provider for the GeminiAIService singleton (kept alive for app lifetime)
@Riverpod(keepAlive: true)
GeminiAIService geminiAIService(Ref ref) {
  final service = GeminiAIService();

  // Dispose when provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// State for ingredient detection
class IngredientDetectionState {
  final DetectedIngredients? detectedIngredients;
  final bool isLoading;
  final String? errorMessage;
  final Uint8List? processedImage;

  const IngredientDetectionState({
    this.detectedIngredients,
    this.isLoading = false,
    this.errorMessage,
    this.processedImage,
  });

  IngredientDetectionState copyWith({
    DetectedIngredients? detectedIngredients,
    bool? isLoading,
    String? errorMessage,
    Uint8List? processedImage,
  }) {
    return IngredientDetectionState(
      detectedIngredients: detectedIngredients ?? this.detectedIngredients,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      processedImage: processedImage ?? this.processedImage,
    );
  }

  IngredientDetectionState clearError() {
    return copyWith(errorMessage: '');
  }
}

/// Provider for ingredient detection logic
@riverpod
class IngredientDetection extends _$IngredientDetection {
  @override
  IngredientDetectionState build() {
    return const IngredientDetectionState();
  }

  /// Detect ingredients from image bytes
  Future<void> detectIngredients(Uint8List imageBytes, String imageId) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Step 1: Preprocess the image
      print('IngredientDetection: Preprocessing image...');
      final processedImage = await ImageProcessor.preprocessForInference(
        imageBytes,
      );

      state = state.copyWith(processedImage: processedImage);

      // Step 2: Run inference
      print('IngredientDetection: Running inference...');
      final inferenceService = ref.read(geminiAIServiceProvider);

      if (!inferenceService.isInitialized) {
        throw ModelNotInitializedException('AI model not initialized');
      }

      final ingredients = await inferenceService.detectIngredients(
        processedImage,
      );

      // Step 3: Create DetectedIngredients entity
      final detected = DetectedIngredients(
        ingredients: ingredients,
        imageId: imageId,
        detectionTime: DateTime.now(),
        isManuallyEdited: false,
      );

      state = state.copyWith(detectedIngredients: detected, isLoading: false);

      print(
        'IngredientDetection: Successfully detected ${ingredients.length} ingredients',
      );
    } on AIException catch (e) {
      print('IngredientDetection: AI error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      print('IngredientDetection: Unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to detect ingredients: $e',
      );
    }
  }

  /// Add a new ingredient manually
  void addIngredient(String ingredient) {
    final current = state.detectedIngredients;
    if (current == null) return;

    final updatedIngredients = [...current.ingredients, ingredient];
    final updated = current.copyWith(
      ingredients: updatedIngredients,
      isManuallyEdited: true,
    );

    state = state.copyWith(detectedIngredients: updated);
    print('IngredientDetection: Added ingredient: $ingredient');
  }

  /// Remove an ingredient by index
  void removeIngredient(int index) {
    final current = state.detectedIngredients;
    if (current == null || index < 0 || index >= current.ingredients.length) {
      return;
    }

    final updatedIngredients = List<String>.from(current.ingredients)
      ..removeAt(index);

    final updated = current.copyWith(
      ingredients: updatedIngredients,
      isManuallyEdited: true,
    );

    state = state.copyWith(detectedIngredients: updated);
    print('IngredientDetection: Removed ingredient at index $index');
  }

  /// Update an ingredient at specific index
  void updateIngredient(int index, String newValue) {
    final current = state.detectedIngredients;
    if (current == null || index < 0 || index >= current.ingredients.length) {
      return;
    }

    final updatedIngredients = List<String>.from(current.ingredients);
    updatedIngredients[index] = newValue;

    final updated = current.copyWith(
      ingredients: updatedIngredients,
      isManuallyEdited: true,
    );

    state = state.copyWith(detectedIngredients: updated);
    print(
      'IngredientDetection: Updated ingredient at index $index to: $newValue',
    );
  }

  /// Clear all detected ingredients
  void clearIngredients() {
    state = const IngredientDetectionState();
    print('IngredientDetection: Cleared all ingredients');
  }

  /// Retry detection with the same image
  Future<void> retryDetection() async {
    final processedImage = state.processedImage;
    if (processedImage == null) {
      state = state.copyWith(errorMessage: 'No image available to retry');
      return;
    }

    final imageId =
        state.detectedIngredients?.imageId ??
        DateTime.now().millisecondsSinceEpoch.toString();

    await detectIngredients(processedImage, imageId);
  }
}
