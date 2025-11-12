import 'detected_ingredient_item.dart';

/// Entity representing detected ingredients from an image
class DetectedIngredients {
  // Legacy support
  final List<String> ingredients;

  // New structured format with confidence
  final List<DetectedIngredientItem> detectedItems;

  final String imageId;
  final DateTime detectionTime;
  final bool isManuallyEdited;

  const DetectedIngredients({
    required this.ingredients,
    this.detectedItems = const [],
    required this.imageId,
    required this.detectionTime,
    this.isManuallyEdited = false,
  });

  DetectedIngredients copyWith({
    List<String>? ingredients,
    List<DetectedIngredientItem>? detectedItems,
    String? imageId,
    DateTime? detectionTime,
    bool? isManuallyEdited,
  }) {
    return DetectedIngredients(
      ingredients: ingredients ?? this.ingredients,
      detectedItems: detectedItems ?? this.detectedItems,
      imageId: imageId ?? this.imageId,
      detectionTime: detectionTime ?? this.detectionTime,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
    );
  }

  /// Get items that need user clarification
  List<DetectedIngredientItem> get itemsNeedingClarification {
    return detectedItems.where((item) => item.needsUserClarification).toList();
  }

  /// Whether all items have been resolved (confirmed or skipped)
  bool get allItemsResolved {
    return detectedItems.every((item) => item.isResolved);
  }

  /// Update a specific item
  DetectedIngredients updateItem(int index, DetectedIngredientItem newItem) {
    if (index < 0 || index >= detectedItems.length) return this;

    final updatedItems = List<DetectedIngredientItem>.from(detectedItems);
    updatedItems[index] = newItem;

    // Also update legacy ingredients list
    final updatedIngredients = updatedItems.map((item) => item.name).toList();

    return copyWith(
      detectedItems: updatedItems,
      ingredients: updatedIngredients,
      isManuallyEdited: true,
    );
  }

  @override
  String toString() {
    return 'DetectedIngredients(ingredients: ${ingredients.length}, imageId: $imageId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DetectedIngredients &&
        other.ingredients.length == ingredients.length &&
        other.imageId == imageId &&
        other.detectionTime == detectionTime &&
        other.isManuallyEdited == isManuallyEdited;
  }

  @override
  int get hashCode {
    return ingredients.hashCode ^
        imageId.hashCode ^
        detectionTime.hashCode ^
        isManuallyEdited.hashCode;
  }
}
