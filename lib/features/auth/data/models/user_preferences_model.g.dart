// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserPreferencesModelImpl _$$UserPreferencesModelImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$UserPreferencesModelImpl',
      json,
      ($checkedConvert) {
        final val = _$UserPreferencesModelImpl(
          userId: $checkedConvert('user_id', (v) => v as String),
          skillLevel:
              $checkedConvert('skill_level', (v) => v as String? ?? 'beginner'),
          spiceTolerance: $checkedConvert(
              'spice_tolerance', (v) => v as String? ?? 'medium'),
          cookingTimePreference: $checkedConvert(
              'cooking_time_preference', (v) => v as String? ?? 'moderate'),
          dietaryRestrictions: $checkedConvert(
              'dietary_restrictions',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          excludedIngredients: $checkedConvert(
              'excluded_ingredients',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          favoriteCuisines: $checkedConvert(
              'favorite_cuisines',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          favoriteProteins: $checkedConvert(
              'favorite_proteins',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          kitchenEquipment: $checkedConvert(
              'kitchen_equipment',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          servingSizePreference: $checkedConvert(
              'serving_size_preference', (v) => (v as num?)?.toInt() ?? 2),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updated_at', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'skillLevel': 'skill_level',
        'spiceTolerance': 'spice_tolerance',
        'cookingTimePreference': 'cooking_time_preference',
        'dietaryRestrictions': 'dietary_restrictions',
        'excludedIngredients': 'excluded_ingredients',
        'favoriteCuisines': 'favorite_cuisines',
        'favoriteProteins': 'favorite_proteins',
        'kitchenEquipment': 'kitchen_equipment',
        'servingSizePreference': 'serving_size_preference',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$$UserPreferencesModelImplToJson(
        _$UserPreferencesModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'skill_level': instance.skillLevel,
      'spice_tolerance': instance.spiceTolerance,
      'cooking_time_preference': instance.cookingTimePreference,
      'dietary_restrictions': instance.dietaryRestrictions,
      'excluded_ingredients': instance.excludedIngredients,
      'favorite_cuisines': instance.favoriteCuisines,
      'favorite_proteins': instance.favoriteProteins,
      'kitchen_equipment': instance.kitchenEquipment,
      'serving_size_preference': instance.servingSizePreference,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
