/// UserPreferences entity - Pure business logic model
/// 
/// This represents user cooking preferences in the domain layer.
class UserPreferences {
  final String userId;
  final String skillLevel;
  final String spiceTolerance;
  final String cookingTimePreference;
  final List<String> dietaryRestrictions;
  final List<String> excludedIngredients;
  final List<String> favoriteCuisines;
  final List<String> favoriteProteins;
  final List<String> kitchenEquipment;
  final int servingSizePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserPreferences({
    required this.userId,
    this.skillLevel = 'beginner',
    this.spiceTolerance = 'medium',
    this.cookingTimePreference = 'moderate',
    this.dietaryRestrictions = const [],
    this.excludedIngredients = const [],
    this.favoriteCuisines = const [],
    this.favoriteProteins = const [],
    this.kitchenEquipment = const [],
    this.servingSizePreference = 2,
    required this.createdAt,
    required this.updatedAt,
  });

  UserPreferences copyWith({
    String? userId,
    String? skillLevel,
    String? spiceTolerance,
    String? cookingTimePreference,
    List<String>? dietaryRestrictions,
    List<String>? excludedIngredients,
    List<String>? favoriteCuisines,
    List<String>? favoriteProteins,
    List<String>? kitchenEquipment,
    int? servingSizePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      skillLevel: skillLevel ?? this.skillLevel,
      spiceTolerance: spiceTolerance ?? this.spiceTolerance,
      cookingTimePreference: cookingTimePreference ?? this.cookingTimePreference,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      excludedIngredients: excludedIngredients ?? this.excludedIngredients,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      favoriteProteins: favoriteProteins ?? this.favoriteProteins,
      kitchenEquipment: kitchenEquipment ?? this.kitchenEquipment,
      servingSizePreference: servingSizePreference ?? this.servingSizePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
