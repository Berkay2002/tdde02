// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RecipeModel _$RecipeModelFromJson(Map<String, dynamic> json) {
  return _RecipeModel.fromJson(json);
}

/// @nodoc
mixin _$RecipeModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'recipe_name')
  String get recipeName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'prep_time')
  int? get prepTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'cook_time')
  int? get cookTime => throw _privateConstructorUsedError;
  int? get servings => throw _privateConstructorUsedError;
  @JsonKey(name: 'cuisine_type')
  String? get cuisineType => throw _privateConstructorUsedError;
  @JsonKey(name: 'difficulty_level')
  String? get difficultyLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'meal_type')
  String? get mealType => throw _privateConstructorUsedError;
  List<IngredientModel> get ingredients => throw _privateConstructorUsedError;
  List<String> get instructions => throw _privateConstructorUsedError;
  @JsonKey(name: 'detected_ingredients')
  List<String>? get detectedIngredients => throw _privateConstructorUsedError;
  @JsonKey(name: 'dietary_tags')
  List<String> get dietaryTags => throw _privateConstructorUsedError;
  List<String> get allergens => throw _privateConstructorUsedError;
  @JsonKey(name: 'calories_per_serving')
  int? get caloriesPerServing => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_favorite')
  bool get isFavorite => throw _privateConstructorUsedError;
  int? get rating => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecipeModelCopyWith<RecipeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeModelCopyWith<$Res> {
  factory $RecipeModelCopyWith(
          RecipeModel value, $Res Function(RecipeModel) then) =
      _$RecipeModelCopyWithImpl<$Res, RecipeModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'recipe_name') String recipeName,
      String? description,
      @JsonKey(name: 'prep_time') int? prepTime,
      @JsonKey(name: 'cook_time') int? cookTime,
      int? servings,
      @JsonKey(name: 'cuisine_type') String? cuisineType,
      @JsonKey(name: 'difficulty_level') String? difficultyLevel,
      @JsonKey(name: 'meal_type') String? mealType,
      List<IngredientModel> ingredients,
      List<String> instructions,
      @JsonKey(name: 'detected_ingredients') List<String>? detectedIngredients,
      @JsonKey(name: 'dietary_tags') List<String> dietaryTags,
      List<String> allergens,
      @JsonKey(name: 'calories_per_serving') int? caloriesPerServing,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      int? rating,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$RecipeModelCopyWithImpl<$Res, $Val extends RecipeModel>
    implements $RecipeModelCopyWith<$Res> {
  _$RecipeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? recipeName = null,
    Object? description = freezed,
    Object? prepTime = freezed,
    Object? cookTime = freezed,
    Object? servings = freezed,
    Object? cuisineType = freezed,
    Object? difficultyLevel = freezed,
    Object? mealType = freezed,
    Object? ingredients = null,
    Object? instructions = null,
    Object? detectedIngredients = freezed,
    Object? dietaryTags = null,
    Object? allergens = null,
    Object? caloriesPerServing = freezed,
    Object? isFavorite = null,
    Object? rating = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recipeName: null == recipeName
          ? _value.recipeName
          : recipeName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      prepTime: freezed == prepTime
          ? _value.prepTime
          : prepTime // ignore: cast_nullable_to_non_nullable
              as int?,
      cookTime: freezed == cookTime
          ? _value.cookTime
          : cookTime // ignore: cast_nullable_to_non_nullable
              as int?,
      servings: freezed == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int?,
      cuisineType: freezed == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyLevel: freezed == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      mealType: freezed == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredients: null == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<IngredientModel>,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      detectedIngredients: freezed == detectedIngredients
          ? _value.detectedIngredients
          : detectedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietaryTags: null == dietaryTags
          ? _value.dietaryTags
          : dietaryTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allergens: null == allergens
          ? _value.allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      caloriesPerServing: freezed == caloriesPerServing
          ? _value.caloriesPerServing
          : caloriesPerServing // ignore: cast_nullable_to_non_nullable
              as int?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeModelImplCopyWith<$Res>
    implements $RecipeModelCopyWith<$Res> {
  factory _$$RecipeModelImplCopyWith(
          _$RecipeModelImpl value, $Res Function(_$RecipeModelImpl) then) =
      __$$RecipeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'recipe_name') String recipeName,
      String? description,
      @JsonKey(name: 'prep_time') int? prepTime,
      @JsonKey(name: 'cook_time') int? cookTime,
      int? servings,
      @JsonKey(name: 'cuisine_type') String? cuisineType,
      @JsonKey(name: 'difficulty_level') String? difficultyLevel,
      @JsonKey(name: 'meal_type') String? mealType,
      List<IngredientModel> ingredients,
      List<String> instructions,
      @JsonKey(name: 'detected_ingredients') List<String>? detectedIngredients,
      @JsonKey(name: 'dietary_tags') List<String> dietaryTags,
      List<String> allergens,
      @JsonKey(name: 'calories_per_serving') int? caloriesPerServing,
      @JsonKey(name: 'is_favorite') bool isFavorite,
      int? rating,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$RecipeModelImplCopyWithImpl<$Res>
    extends _$RecipeModelCopyWithImpl<$Res, _$RecipeModelImpl>
    implements _$$RecipeModelImplCopyWith<$Res> {
  __$$RecipeModelImplCopyWithImpl(
      _$RecipeModelImpl _value, $Res Function(_$RecipeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? recipeName = null,
    Object? description = freezed,
    Object? prepTime = freezed,
    Object? cookTime = freezed,
    Object? servings = freezed,
    Object? cuisineType = freezed,
    Object? difficultyLevel = freezed,
    Object? mealType = freezed,
    Object? ingredients = null,
    Object? instructions = null,
    Object? detectedIngredients = freezed,
    Object? dietaryTags = null,
    Object? allergens = null,
    Object? caloriesPerServing = freezed,
    Object? isFavorite = null,
    Object? rating = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$RecipeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      recipeName: null == recipeName
          ? _value.recipeName
          : recipeName // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      prepTime: freezed == prepTime
          ? _value.prepTime
          : prepTime // ignore: cast_nullable_to_non_nullable
              as int?,
      cookTime: freezed == cookTime
          ? _value.cookTime
          : cookTime // ignore: cast_nullable_to_non_nullable
              as int?,
      servings: freezed == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int?,
      cuisineType: freezed == cuisineType
          ? _value.cuisineType
          : cuisineType // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyLevel: freezed == difficultyLevel
          ? _value.difficultyLevel
          : difficultyLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      mealType: freezed == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredients: null == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<IngredientModel>,
      instructions: null == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      detectedIngredients: freezed == detectedIngredients
          ? _value._detectedIngredients
          : detectedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietaryTags: null == dietaryTags
          ? _value._dietaryTags
          : dietaryTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allergens: null == allergens
          ? _value._allergens
          : allergens // ignore: cast_nullable_to_non_nullable
              as List<String>,
      caloriesPerServing: freezed == caloriesPerServing
          ? _value.caloriesPerServing
          : caloriesPerServing // ignore: cast_nullable_to_non_nullable
              as int?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeModelImpl extends _RecipeModel {
  const _$RecipeModelImpl(
      {required this.id,
      @JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'recipe_name') required this.recipeName,
      this.description,
      @JsonKey(name: 'prep_time') this.prepTime,
      @JsonKey(name: 'cook_time') this.cookTime,
      this.servings,
      @JsonKey(name: 'cuisine_type') this.cuisineType,
      @JsonKey(name: 'difficulty_level') this.difficultyLevel,
      @JsonKey(name: 'meal_type') this.mealType,
      required final List<IngredientModel> ingredients,
      required final List<String> instructions,
      @JsonKey(name: 'detected_ingredients')
      final List<String>? detectedIngredients,
      @JsonKey(name: 'dietary_tags') final List<String> dietaryTags = const [],
      final List<String> allergens = const [],
      @JsonKey(name: 'calories_per_serving') this.caloriesPerServing,
      @JsonKey(name: 'is_favorite') this.isFavorite = false,
      this.rating,
      this.notes,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _ingredients = ingredients,
        _instructions = instructions,
        _detectedIngredients = detectedIngredients,
        _dietaryTags = dietaryTags,
        _allergens = allergens,
        super._();

  factory _$RecipeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'recipe_name')
  final String recipeName;
  @override
  final String? description;
  @override
  @JsonKey(name: 'prep_time')
  final int? prepTime;
  @override
  @JsonKey(name: 'cook_time')
  final int? cookTime;
  @override
  final int? servings;
  @override
  @JsonKey(name: 'cuisine_type')
  final String? cuisineType;
  @override
  @JsonKey(name: 'difficulty_level')
  final String? difficultyLevel;
  @override
  @JsonKey(name: 'meal_type')
  final String? mealType;
  final List<IngredientModel> _ingredients;
  @override
  List<IngredientModel> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _instructions;
  @override
  List<String> get instructions {
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_instructions);
  }

  final List<String>? _detectedIngredients;
  @override
  @JsonKey(name: 'detected_ingredients')
  List<String>? get detectedIngredients {
    final value = _detectedIngredients;
    if (value == null) return null;
    if (_detectedIngredients is EqualUnmodifiableListView)
      return _detectedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _dietaryTags;
  @override
  @JsonKey(name: 'dietary_tags')
  List<String> get dietaryTags {
    if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dietaryTags);
  }

  final List<String> _allergens;
  @override
  @JsonKey()
  List<String> get allergens {
    if (_allergens is EqualUnmodifiableListView) return _allergens;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergens);
  }

  @override
  @JsonKey(name: 'calories_per_serving')
  final int? caloriesPerServing;
  @override
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @override
  final int? rating;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'RecipeModel(id: $id, userId: $userId, recipeName: $recipeName, description: $description, prepTime: $prepTime, cookTime: $cookTime, servings: $servings, cuisineType: $cuisineType, difficultyLevel: $difficultyLevel, mealType: $mealType, ingredients: $ingredients, instructions: $instructions, detectedIngredients: $detectedIngredients, dietaryTags: $dietaryTags, allergens: $allergens, caloriesPerServing: $caloriesPerServing, isFavorite: $isFavorite, rating: $rating, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.recipeName, recipeName) ||
                other.recipeName == recipeName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.prepTime, prepTime) ||
                other.prepTime == prepTime) &&
            (identical(other.cookTime, cookTime) ||
                other.cookTime == cookTime) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.cuisineType, cuisineType) ||
                other.cuisineType == cuisineType) &&
            (identical(other.difficultyLevel, difficultyLevel) ||
                other.difficultyLevel == difficultyLevel) &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            const DeepCollectionEquality()
                .equals(other._detectedIngredients, _detectedIngredients) &&
            const DeepCollectionEquality()
                .equals(other._dietaryTags, _dietaryTags) &&
            const DeepCollectionEquality()
                .equals(other._allergens, _allergens) &&
            (identical(other.caloriesPerServing, caloriesPerServing) ||
                other.caloriesPerServing == caloriesPerServing) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        recipeName,
        description,
        prepTime,
        cookTime,
        servings,
        cuisineType,
        difficultyLevel,
        mealType,
        const DeepCollectionEquality().hash(_ingredients),
        const DeepCollectionEquality().hash(_instructions),
        const DeepCollectionEquality().hash(_detectedIngredients),
        const DeepCollectionEquality().hash(_dietaryTags),
        const DeepCollectionEquality().hash(_allergens),
        caloriesPerServing,
        isFavorite,
        rating,
        notes,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeModelImplCopyWith<_$RecipeModelImpl> get copyWith =>
      __$$RecipeModelImplCopyWithImpl<_$RecipeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeModelImplToJson(
      this,
    );
  }
}

abstract class _RecipeModel extends RecipeModel {
  const factory _RecipeModel(
          {required final String id,
          @JsonKey(name: 'user_id') required final String userId,
          @JsonKey(name: 'recipe_name') required final String recipeName,
          final String? description,
          @JsonKey(name: 'prep_time') final int? prepTime,
          @JsonKey(name: 'cook_time') final int? cookTime,
          final int? servings,
          @JsonKey(name: 'cuisine_type') final String? cuisineType,
          @JsonKey(name: 'difficulty_level') final String? difficultyLevel,
          @JsonKey(name: 'meal_type') final String? mealType,
          required final List<IngredientModel> ingredients,
          required final List<String> instructions,
          @JsonKey(name: 'detected_ingredients')
          final List<String>? detectedIngredients,
          @JsonKey(name: 'dietary_tags') final List<String> dietaryTags,
          final List<String> allergens,
          @JsonKey(name: 'calories_per_serving') final int? caloriesPerServing,
          @JsonKey(name: 'is_favorite') final bool isFavorite,
          final int? rating,
          final String? notes,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$RecipeModelImpl;
  const _RecipeModel._() : super._();

  factory _RecipeModel.fromJson(Map<String, dynamic> json) =
      _$RecipeModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'recipe_name')
  String get recipeName;
  @override
  String? get description;
  @override
  @JsonKey(name: 'prep_time')
  int? get prepTime;
  @override
  @JsonKey(name: 'cook_time')
  int? get cookTime;
  @override
  int? get servings;
  @override
  @JsonKey(name: 'cuisine_type')
  String? get cuisineType;
  @override
  @JsonKey(name: 'difficulty_level')
  String? get difficultyLevel;
  @override
  @JsonKey(name: 'meal_type')
  String? get mealType;
  @override
  List<IngredientModel> get ingredients;
  @override
  List<String> get instructions;
  @override
  @JsonKey(name: 'detected_ingredients')
  List<String>? get detectedIngredients;
  @override
  @JsonKey(name: 'dietary_tags')
  List<String> get dietaryTags;
  @override
  List<String> get allergens;
  @override
  @JsonKey(name: 'calories_per_serving')
  int? get caloriesPerServing;
  @override
  @JsonKey(name: 'is_favorite')
  bool get isFavorite;
  @override
  int? get rating;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$RecipeModelImplCopyWith<_$RecipeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IngredientModel _$IngredientModelFromJson(Map<String, dynamic> json) {
  return _IngredientModel.fromJson(json);
}

/// @nodoc
mixin _$IngredientModel {
  String get name => throw _privateConstructorUsedError;
  String? get quantity => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IngredientModelCopyWith<IngredientModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IngredientModelCopyWith<$Res> {
  factory $IngredientModelCopyWith(
          IngredientModel value, $Res Function(IngredientModel) then) =
      _$IngredientModelCopyWithImpl<$Res, IngredientModel>;
  @useResult
  $Res call({String name, String? quantity, String? unit, String? notes});
}

/// @nodoc
class _$IngredientModelCopyWithImpl<$Res, $Val extends IngredientModel>
    implements $IngredientModelCopyWith<$Res> {
  _$IngredientModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = freezed,
    Object? unit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IngredientModelImplCopyWith<$Res>
    implements $IngredientModelCopyWith<$Res> {
  factory _$$IngredientModelImplCopyWith(_$IngredientModelImpl value,
          $Res Function(_$IngredientModelImpl) then) =
      __$$IngredientModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String? quantity, String? unit, String? notes});
}

/// @nodoc
class __$$IngredientModelImplCopyWithImpl<$Res>
    extends _$IngredientModelCopyWithImpl<$Res, _$IngredientModelImpl>
    implements _$$IngredientModelImplCopyWith<$Res> {
  __$$IngredientModelImplCopyWithImpl(
      _$IngredientModelImpl _value, $Res Function(_$IngredientModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = freezed,
    Object? unit = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$IngredientModelImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: freezed == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IngredientModelImpl extends _IngredientModel {
  const _$IngredientModelImpl(
      {required this.name, this.quantity, this.unit, this.notes})
      : super._();

  factory _$IngredientModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$IngredientModelImplFromJson(json);

  @override
  final String name;
  @override
  final String? quantity;
  @override
  final String? unit;
  @override
  final String? notes;

  @override
  String toString() {
    return 'IngredientModel(name: $name, quantity: $quantity, unit: $unit, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IngredientModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, unit, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IngredientModelImplCopyWith<_$IngredientModelImpl> get copyWith =>
      __$$IngredientModelImplCopyWithImpl<_$IngredientModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IngredientModelImplToJson(
      this,
    );
  }
}

abstract class _IngredientModel extends IngredientModel {
  const factory _IngredientModel(
      {required final String name,
      final String? quantity,
      final String? unit,
      final String? notes}) = _$IngredientModelImpl;
  const _IngredientModel._() : super._();

  factory _IngredientModel.fromJson(Map<String, dynamic> json) =
      _$IngredientModelImpl.fromJson;

  @override
  String get name;
  @override
  String? get quantity;
  @override
  String? get unit;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$IngredientModelImplCopyWith<_$IngredientModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
