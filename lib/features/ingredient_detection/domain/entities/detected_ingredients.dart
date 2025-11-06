/// Entity representing detected ingredients from an image
class DetectedIngredients {
  final List<String> ingredients;
  final String imageId;
  final DateTime detectionTime;
  final bool isManuallyEdited;

  const DetectedIngredients({
    required this.ingredients,
    required this.imageId,
    required this.detectionTime,
    this.isManuallyEdited = false,
  });

  DetectedIngredients copyWith({
    List<String>? ingredients,
    String? imageId,
    DateTime? detectionTime,
    bool? isManuallyEdited,
  }) {
    return DetectedIngredients(
      ingredients: ingredients ?? this.ingredients,
      imageId: imageId ?? this.imageId,
      detectionTime: detectionTime ?? this.detectionTime,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
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
