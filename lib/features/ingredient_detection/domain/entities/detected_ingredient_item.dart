/// Confidence level for ingredient quantity detection
enum QuantityConfidence {
  /// Exact quantity clearly visible and countable
  high,

  /// Approximate quantity can be estimated but not exact
  medium,

  /// Quantity is uncertain, partially obscured or very unclear
  low,

  /// No quantity information available
  none;

  static QuantityConfidence fromString(String? value) {
    if (value == null) return none;
    switch (value.toLowerCase()) {
      case 'high':
        return high;
      case 'medium':
        return medium;
      case 'low':
        return low;
      case 'none':
      default:
        return none;
    }
  }

  /// Whether this confidence level requires user clarification
  bool get needsClarification => this == low;

  /// Whether this confidence level should show approximation indicators
  bool get shouldShowApproximation => this == medium;

  /// Get display text for quantity based on confidence
  String formatQuantity(String? quantity, String? unit) {
    if (quantity == null) return '';

    final baseText = unit != null ? '$quantity $unit' : quantity;

    switch (this) {
      case QuantityConfidence.high:
        return baseText;
      case QuantityConfidence.medium:
        return 'circa $baseText';
      case QuantityConfidence.low:
        return '~$baseText (unverified)';
      case QuantityConfidence.none:
        return '';
    }
  }
}

/// Entity representing a single detected ingredient with metadata
class DetectedIngredientItem {
  final String name;
  final String? quantity;
  final String? unit;
  final QuantityConfidence quantityConfidence;
  final String? category;
  final String? freshness;

  /// User-confirmed quantity after clarification (if applicable)
  final String? confirmedQuantity;
  final String? confirmedUnit;
  final bool needsUserClarification;

  const DetectedIngredientItem({
    required this.name,
    this.quantity,
    this.unit,
    this.quantityConfidence = QuantityConfidence.none,
    this.category,
    this.freshness,
    this.confirmedQuantity,
    this.confirmedUnit,
    this.needsUserClarification = false,
  });

  /// Create from AI response JSON
  factory DetectedIngredientItem.fromJson(Map<String, dynamic> json) {
    final confidence = QuantityConfidence.fromString(
      json['quantityConfidence'] as String?,
    );

    return DetectedIngredientItem(
      name: json['name'] as String? ?? '',
      quantity: json['quantity']?.toString(),
      unit: json['unit'] as String?,
      quantityConfidence: confidence,
      category: json['category'] as String?,
      freshness: json['freshness'] as String?,
      needsUserClarification: confidence.needsClarification,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'quantityConfidence': quantityConfidence.name,
      'category': category,
      'freshness': freshness,
      'confirmedQuantity': confirmedQuantity,
      'confirmedUnit': confirmedUnit,
      'needsUserClarification': needsUserClarification,
    };
  }

  /// Get display-ready quantity text
  String get displayQuantity {
    // Prefer confirmed quantity if available
    if (confirmedQuantity != null) {
      return confirmedUnit != null
          ? '$confirmedQuantity $confirmedUnit'
          : confirmedQuantity!;
    }

    return quantityConfidence.formatQuantity(quantity, unit);
  }

  /// Get final quantity for recipe generation (confirmed or original)
  String? get finalQuantity => confirmedQuantity ?? quantity;

  /// Get final unit for recipe generation (confirmed or original)
  String? get finalUnit => confirmedUnit ?? unit;

  /// Whether user has confirmed/skipped this ingredient
  bool get isResolved => confirmedQuantity != null || !needsUserClarification;

  DetectedIngredientItem copyWith({
    String? name,
    String? quantity,
    String? unit,
    QuantityConfidence? quantityConfidence,
    String? category,
    String? freshness,
    String? confirmedQuantity,
    String? confirmedUnit,
    bool? needsUserClarification,
  }) {
    return DetectedIngredientItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      quantityConfidence: quantityConfidence ?? this.quantityConfidence,
      category: category ?? this.category,
      freshness: freshness ?? this.freshness,
      confirmedQuantity: confirmedQuantity ?? this.confirmedQuantity,
      confirmedUnit: confirmedUnit ?? this.confirmedUnit,
      needsUserClarification:
          needsUserClarification ?? this.needsUserClarification,
    );
  }

  /// Mark as skipped (user chose to fix later)
  DetectedIngredientItem markAsSkipped() {
    return copyWith(
      confirmedQuantity: quantity,
      confirmedUnit: unit,
      needsUserClarification: false,
    );
  }

  /// Confirm with user-provided values
  DetectedIngredientItem confirmWith(String newQuantity, String? newUnit) {
    return copyWith(
      confirmedQuantity: newQuantity,
      confirmedUnit: newUnit,
      needsUserClarification: false,
    );
  }

  @override
  String toString() {
    return 'DetectedIngredientItem(name: $name, quantity: $quantity, unit: $unit, confidence: ${quantityConfidence.name})';
  }
}
