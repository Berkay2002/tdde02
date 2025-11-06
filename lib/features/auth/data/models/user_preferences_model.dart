import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_preferences.dart';

part 'user_preferences_model.freezed.dart';
part 'user_preferences_model.g.dart';

/// UserPreferences model for data layer with JSON serialization
@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  const UserPreferencesModel._();

  const factory UserPreferencesModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'skill_level') @Default('beginner') String skillLevel,
    @JsonKey(name: 'spice_tolerance') @Default('medium') String spiceTolerance,
    @JsonKey(name: 'cooking_time_preference')
    @Default('moderate')
    String cookingTimePreference,
    @JsonKey(name: 'dietary_restrictions')
    @Default([])
    List<String> dietaryRestrictions,
    @JsonKey(name: 'excluded_ingredients')
    @Default([])
    List<String> excludedIngredients,
    @JsonKey(name: 'favorite_cuisines')
    @Default([])
    List<String> favoriteCuisines,
    @JsonKey(name: 'favorite_proteins')
    @Default([])
    List<String> favoriteProteins,
    @JsonKey(name: 'kitchen_equipment')
    @Default([])
    List<String> kitchenEquipment,
    @JsonKey(name: 'serving_size_preference')
    @Default(2)
    int servingSizePreference,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);

  /// Convert model to domain entity
  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      skillLevel: skillLevel,
      spiceTolerance: spiceTolerance,
      cookingTimePreference: cookingTimePreference,
      dietaryRestrictions: dietaryRestrictions,
      excludedIngredients: excludedIngredients,
      favoriteCuisines: favoriteCuisines,
      favoriteProteins: favoriteProteins,
      kitchenEquipment: kitchenEquipment,
      servingSizePreference: servingSizePreference,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from domain entity
  factory UserPreferencesModel.fromEntity(UserPreferences entity) {
    return UserPreferencesModel(
      userId: entity.userId,
      skillLevel: entity.skillLevel,
      spiceTolerance: entity.spiceTolerance,
      cookingTimePreference: entity.cookingTimePreference,
      dietaryRestrictions: entity.dietaryRestrictions,
      excludedIngredients: entity.excludedIngredients,
      favoriteCuisines: entity.favoriteCuisines,
      favoriteProteins: entity.favoriteProteins,
      kitchenEquipment: entity.kitchenEquipment,
      servingSizePreference: entity.servingSizePreference,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
