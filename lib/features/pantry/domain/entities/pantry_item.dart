import 'ingredient_category.dart';

/// Domain entity representing an ingredient stored in the pantry.
class PantryItem {
  final String id; // unique id
  final String name;
  final IngredientCategory category;
  final String? quantity; // e.g. "2", "500g", "1 bunch"
  final String? unit; // optional structured unit
  final DateTime dateAdded;
  final DateTime? expirationDate;

  const PantryItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    required this.dateAdded,
    this.expirationDate,
  });

  PantryItem copyWith({
    String? id,
    String? name,
    IngredientCategory? category,
    String? quantity,
    String? unit,
    DateTime? dateAdded,
    DateTime? expirationDate,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      dateAdded: dateAdded ?? this.dateAdded,
      expirationDate: expirationDate ?? this.expirationDate,
    );
  }

  /// Freshness heuristic if expiration date not provided.
  FreshnessStatus get freshnessStatus {
    if (expirationDate != null) {
      final remaining = expirationDate!.difference(DateTime.now()).inDays;
      if (remaining < 0) return FreshnessStatus.urgent;
      if (remaining <= 2) return FreshnessStatus.urgent;
      if (remaining <= 5) return FreshnessStatus.soon;
      return FreshnessStatus.fresh;
    }
    final ageDays = DateTime.now().difference(dateAdded).inDays;
    if (ageDays <= 3) return FreshnessStatus.fresh;
    if (ageDays <= 7) return FreshnessStatus.soon;
    return FreshnessStatus.urgent;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'quantity': quantity,
    'unit': unit,
    'dateAdded': dateAdded.toIso8601String(),
    'expirationDate': expirationDate?.toIso8601String(),
  };

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    final categoryName = json['category'] as String?;
    IngredientCategory category;
    if (categoryName != null) {
      category = IngredientCategory.values.firstWhere(
        (e) => e.name == categoryName,
        orElse: () => IngredientCategoryHelper.detectCategory(name),
      );
    } else {
      category = IngredientCategoryHelper.detectCategory(name);
    }
    return PantryItem(
      id:
          json['id'] as String? ??
          '${DateTime.now().millisecondsSinceEpoch}_$name',
      name: name,
      category: category,
      quantity: json['quantity'] as String?,
      unit: json['unit'] as String?,
      dateAdded:
          DateTime.tryParse(json['dateAdded'] as String? ?? '') ??
          DateTime.now(),
      expirationDate: json['expirationDate'] != null
          ? DateTime.tryParse(json['expirationDate'] as String)
          : null,
    );
  }

  /// Create from legacy string ingredient.
  factory PantryItem.fromLegacy(String ingredient) {
    return PantryItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_$ingredient',
      name: ingredient,
      category: IngredientCategoryHelper.detectCategory(ingredient),
      dateAdded: DateTime.now(),
    );
  }
}

enum FreshnessStatus { fresh, soon, urgent }
