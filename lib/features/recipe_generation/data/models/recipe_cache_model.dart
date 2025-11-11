import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for caching generated recipes in Firestore
/// Stores recipes along with the ingredients used to generate them
class RecipeCacheModel {
  final String id;
  final String userId;
  final List<String> ingredients; // Sorted list for consistent matching
  final List<Map<String, dynamic>> recipes; // 3 generated recipes
  final String? dietaryRestrictions;
  final String? skillLevel;
  final String? cuisinePreference;
  final DateTime createdAt;
  final DateTime? expiresAt; // Optional expiration (e.g., 7 days)

  RecipeCacheModel({
    required this.id,
    required this.userId,
    required this.ingredients,
    required this.recipes,
    this.dietaryRestrictions,
    this.skillLevel,
    this.cuisinePreference,
    required this.createdAt,
    this.expiresAt,
  });

  /// Generate cache key from ingredients and preferences
  static String generateCacheKey(
    List<String> ingredients,
    String? dietaryRestrictions,
    String? skillLevel,
    String? cuisinePreference,
  ) {
    final sortedIngredients = List<String>.from(ingredients)..sort();
    final key = [
      sortedIngredients.join('|'),
      dietaryRestrictions ?? '',
      skillLevel ?? '',
      cuisinePreference ?? '',
    ].join('::');
    return key.hashCode.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ingredients': ingredients,
      'recipes': recipes,
      'dietary_restrictions': dietaryRestrictions,
      'skill_level': skillLevel,
      'cuisine_preference': cuisinePreference,
      'created_at': Timestamp.fromDate(createdAt),
      'expires_at': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  factory RecipeCacheModel.fromJson(Map<String, dynamic> json) {
    return RecipeCacheModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      ingredients: (json['ingredients'] as List).cast<String>(),
      recipes: (json['recipes'] as List).cast<Map<String, dynamic>>(),
      dietaryRestrictions: json['dietary_restrictions'] as String?,
      skillLevel: json['skill_level'] as String?,
      cuisinePreference: json['cuisine_preference'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      expiresAt: json['expires_at'] != null 
          ? (json['expires_at'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Check if cache is still valid (not expired)
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }
}
