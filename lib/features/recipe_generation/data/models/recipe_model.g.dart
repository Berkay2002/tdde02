// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeModelImpl _$$RecipeModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$RecipeModelImpl',
      json,
      ($checkedConvert) {
        final val = _$RecipeModelImpl(
          id: $checkedConvert('id', (v) => v as String),
          userId: $checkedConvert('user_id', (v) => v as String),
          recipeName: $checkedConvert('recipe_name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String?),
          prepTime: $checkedConvert('prep_time', (v) => (v as num?)?.toInt()),
          cookTime: $checkedConvert('cook_time', (v) => (v as num?)?.toInt()),
          servings: $checkedConvert('servings', (v) => (v as num?)?.toInt()),
          cuisineType: $checkedConvert('cuisine_type', (v) => v as String?),
          difficultyLevel:
              $checkedConvert('difficulty_level', (v) => v as String?),
          mealType: $checkedConvert('meal_type', (v) => v as String?),
          ingredients: $checkedConvert(
              'ingredients',
              (v) => (v as List<dynamic>)
                  .map((e) =>
                      IngredientModel.fromJson(e as Map<String, dynamic>))
                  .toList()),
          instructions: $checkedConvert('instructions',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          detectedIngredients: $checkedConvert('detected_ingredients',
              (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
          dietaryTags: $checkedConvert(
              'dietary_tags',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          allergens: $checkedConvert(
              'allergens',
              (v) =>
                  (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                  const []),
          caloriesPerServing: $checkedConvert(
              'calories_per_serving', (v) => (v as num?)?.toInt()),
          isFavorite:
              $checkedConvert('is_favorite', (v) => v as bool? ?? false),
          rating: $checkedConvert('rating', (v) => (v as num?)?.toInt()),
          notes: $checkedConvert('notes', (v) => v as String?),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updated_at', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'userId': 'user_id',
        'recipeName': 'recipe_name',
        'prepTime': 'prep_time',
        'cookTime': 'cook_time',
        'cuisineType': 'cuisine_type',
        'difficultyLevel': 'difficulty_level',
        'mealType': 'meal_type',
        'detectedIngredients': 'detected_ingredients',
        'dietaryTags': 'dietary_tags',
        'caloriesPerServing': 'calories_per_serving',
        'isFavorite': 'is_favorite',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$$RecipeModelImplToJson(_$RecipeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'recipe_name': instance.recipeName,
      'description': instance.description,
      'prep_time': instance.prepTime,
      'cook_time': instance.cookTime,
      'servings': instance.servings,
      'cuisine_type': instance.cuisineType,
      'difficulty_level': instance.difficultyLevel,
      'meal_type': instance.mealType,
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'instructions': instance.instructions,
      'detected_ingredients': instance.detectedIngredients,
      'dietary_tags': instance.dietaryTags,
      'allergens': instance.allergens,
      'calories_per_serving': instance.caloriesPerServing,
      'is_favorite': instance.isFavorite,
      'rating': instance.rating,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$IngredientModelImpl _$$IngredientModelImplFromJson(
        Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$IngredientModelImpl',
      json,
      ($checkedConvert) {
        final val = _$IngredientModelImpl(
          name: $checkedConvert('name', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => v as String?),
          unit: $checkedConvert('unit', (v) => v as String?),
          notes: $checkedConvert('notes', (v) => v as String?),
        );
        return val;
      },
    );

Map<String, dynamic> _$$IngredientModelImplToJson(
        _$IngredientModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'notes': instance.notes,
    };
