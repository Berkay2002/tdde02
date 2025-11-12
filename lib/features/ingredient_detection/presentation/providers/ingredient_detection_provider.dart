import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/utils/image_processor.dart';
import '../../../../core/errors/ai_exceptions.dart';
import '../../../../core/errors/rate_limit_exceptions.dart';
import '../../../../shared/providers/services_provider.dart';
import '../../../../shared/providers/firebase_provider.dart';
import '../../domain/entities/detected_ingredients.dart';
import '../../domain/entities/detected_ingredient_item.dart';

part 'ingredient_detection_provider.g.dart';

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
@Riverpod(keepAlive: true)
class IngredientDetection extends _$IngredientDetection {
  @override
  IngredientDetectionState build() {
    return const IngredientDetectionState();
  }

  /// Detect ingredients from image bytes
  /// Returns true if detection was successful, false otherwise
  Future<bool> detectIngredients(Uint8List imageBytes, String imageId) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Get current user ID for rate limiting
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to detect ingredients');
      }

      // Step 1: Preprocess the image
      print('IngredientDetection: Preprocessing image...');
      final processedImage = await ImageProcessor.preprocessForInference(
        imageBytes,
      );

      state = state.copyWith(processedImage: processedImage);

      // Step 2: Run inference with rate limiting
      print('IngredientDetection: Running inference...');
      final inferenceService = ref.read(geminiAIServiceProvider);

      if (!inferenceService.isInitialized) {
        throw ModelNotInitializedException('AI model not initialized');
      }

      // Use structured detection with confidence scoring
      final structuredIngredients = await inferenceService
          .detectIngredientsStructured(processedImage, user.uid);

      print('IngredientDetection: Received ${structuredIngredients.length} structured ingredients');

      // Parse into DetectedIngredientItem objects
      final detectedItems = <DetectedIngredientItem>[];
      for (var json in structuredIngredients) {
        try {
          final item = DetectedIngredientItem.fromJson(json);
          detectedItems.add(item);
          print('IngredientDetection: Parsed item: ${item.name}');
        } catch (e) {
          print('IngredientDetection: Failed to parse item: $json, error: $e');
        }
      }

      // Extract names for legacy support
      final ingredients = detectedItems.map((item) => item.name).toList();

      print('IngredientDetection: Parsed ${detectedItems.length} items into entities');

      // Step 3: Create DetectedIngredients entity
      final detected = DetectedIngredients(
        ingredients: ingredients,
        detectedItems: detectedItems,
        imageId: imageId,
        detectionTime: DateTime.now(),
        isManuallyEdited: false,
      );

      state = state.copyWith(detectedIngredients: detected, isLoading: false);

      print(
        'IngredientDetection: Successfully detected ${ingredients.length} ingredients',
      );
      print('IngredientDetection: State updated with ${state.detectedIngredients?.detectedItems.length ?? 0} items');

      // Log items needing clarification
      final needsClarification = detected.itemsNeedingClarification;
      if (needsClarification.isNotEmpty) {
        print(
          'IngredientDetection: ${needsClarification.length} items need user clarification',
        );
      }
      
      return true; // Success
    } on RateLimitException catch (e) {
      // Handle rate limit errors with user-friendly message
      print('IngredientDetection: Rate limit exceeded: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.userMessage);
      return false;
    } on AIException catch (e) {
      print('IngredientDetection: AI error: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      print('IngredientDetection: Unexpected error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to detect ingredients: $e',
      );
      return false;
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
    print('IngredientDetection: clearIngredients() called from:');
    print(StackTrace.current);
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

  /// Confirm quantity for an ingredient (user provided value)
  void confirmIngredientQuantity(
    int index,
    String confirmedQuantity,
    String? confirmedUnit,
  ) {
    final current = state.detectedIngredients;
    if (current == null || index < 0 || index >= current.detectedItems.length) {
      return;
    }

    final item = current.detectedItems[index];
    final updatedItem = item.confirmWith(confirmedQuantity, confirmedUnit);

    final updatedDetection = current.updateItem(index, updatedItem);
    state = state.copyWith(detectedIngredients: updatedDetection);

    print(
      'IngredientDetection: Confirmed quantity for ${item.name}: $confirmedQuantity $confirmedUnit',
    );
  }

  /// Skip quantity clarification (user will fix later)
  void skipIngredientClarification(int index) {
    final current = state.detectedIngredients;
    if (current == null || index < 0 || index >= current.detectedItems.length) {
      return;
    }

    final item = current.detectedItems[index];
    final updatedItem = item.markAsSkipped();

    final updatedDetection = current.updateItem(index, updatedItem);
    state = state.copyWith(detectedIngredients: updatedDetection);

    print('IngredientDetection: Skipped clarification for ${item.name}');
  }

  /// Get items that still need user clarification
  List<DetectedIngredientItem> getItemsNeedingClarification() {
    return state.detectedIngredients?.itemsNeedingClarification ?? [];
  }

  /// Check if all clarifications are resolved
  bool areAllClarificationsResolved() {
    return state.detectedIngredients?.allItemsResolved ?? true;
  }
}
