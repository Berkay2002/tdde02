// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_preferences_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserPreferencesModel _$UserPreferencesModelFromJson(Map<String, dynamic> json) {
  return _UserPreferencesModel.fromJson(json);
}

/// @nodoc
mixin _$UserPreferencesModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'skill_level')
  String get skillLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'spice_tolerance')
  String get spiceTolerance => throw _privateConstructorUsedError;
  @JsonKey(name: 'cooking_time_preference')
  String get cookingTimePreference => throw _privateConstructorUsedError;
  @JsonKey(name: 'dietary_restrictions')
  List<String> get dietaryRestrictions => throw _privateConstructorUsedError;
  @JsonKey(name: 'excluded_ingredients')
  List<String> get excludedIngredients => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_cuisines')
  List<String> get favoriteCuisines => throw _privateConstructorUsedError;
  @JsonKey(name: 'favorite_proteins')
  List<String> get favoriteProteins => throw _privateConstructorUsedError;
  @JsonKey(name: 'kitchen_equipment')
  List<String> get kitchenEquipment => throw _privateConstructorUsedError;
  @JsonKey(name: 'serving_size_preference')
  int get servingSizePreference => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserPreferencesModelCopyWith<UserPreferencesModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserPreferencesModelCopyWith<$Res> {
  factory $UserPreferencesModelCopyWith(UserPreferencesModel value,
          $Res Function(UserPreferencesModel) then) =
      _$UserPreferencesModelCopyWithImpl<$Res, UserPreferencesModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'skill_level') String skillLevel,
      @JsonKey(name: 'spice_tolerance') String spiceTolerance,
      @JsonKey(name: 'cooking_time_preference') String cookingTimePreference,
      @JsonKey(name: 'dietary_restrictions') List<String> dietaryRestrictions,
      @JsonKey(name: 'excluded_ingredients') List<String> excludedIngredients,
      @JsonKey(name: 'favorite_cuisines') List<String> favoriteCuisines,
      @JsonKey(name: 'favorite_proteins') List<String> favoriteProteins,
      @JsonKey(name: 'kitchen_equipment') List<String> kitchenEquipment,
      @JsonKey(name: 'serving_size_preference') int servingSizePreference,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$UserPreferencesModelCopyWithImpl<$Res,
        $Val extends UserPreferencesModel>
    implements $UserPreferencesModelCopyWith<$Res> {
  _$UserPreferencesModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? skillLevel = null,
    Object? spiceTolerance = null,
    Object? cookingTimePreference = null,
    Object? dietaryRestrictions = null,
    Object? excludedIngredients = null,
    Object? favoriteCuisines = null,
    Object? favoriteProteins = null,
    Object? kitchenEquipment = null,
    Object? servingSizePreference = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      skillLevel: null == skillLevel
          ? _value.skillLevel
          : skillLevel // ignore: cast_nullable_to_non_nullable
              as String,
      spiceTolerance: null == spiceTolerance
          ? _value.spiceTolerance
          : spiceTolerance // ignore: cast_nullable_to_non_nullable
              as String,
      cookingTimePreference: null == cookingTimePreference
          ? _value.cookingTimePreference
          : cookingTimePreference // ignore: cast_nullable_to_non_nullable
              as String,
      dietaryRestrictions: null == dietaryRestrictions
          ? _value.dietaryRestrictions
          : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedIngredients: null == excludedIngredients
          ? _value.excludedIngredients
          : excludedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteCuisines: null == favoriteCuisines
          ? _value.favoriteCuisines
          : favoriteCuisines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteProteins: null == favoriteProteins
          ? _value.favoriteProteins
          : favoriteProteins // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kitchenEquipment: null == kitchenEquipment
          ? _value.kitchenEquipment
          : kitchenEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      servingSizePreference: null == servingSizePreference
          ? _value.servingSizePreference
          : servingSizePreference // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$UserPreferencesModelImplCopyWith<$Res>
    implements $UserPreferencesModelCopyWith<$Res> {
  factory _$$UserPreferencesModelImplCopyWith(_$UserPreferencesModelImpl value,
          $Res Function(_$UserPreferencesModelImpl) then) =
      __$$UserPreferencesModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'skill_level') String skillLevel,
      @JsonKey(name: 'spice_tolerance') String spiceTolerance,
      @JsonKey(name: 'cooking_time_preference') String cookingTimePreference,
      @JsonKey(name: 'dietary_restrictions') List<String> dietaryRestrictions,
      @JsonKey(name: 'excluded_ingredients') List<String> excludedIngredients,
      @JsonKey(name: 'favorite_cuisines') List<String> favoriteCuisines,
      @JsonKey(name: 'favorite_proteins') List<String> favoriteProteins,
      @JsonKey(name: 'kitchen_equipment') List<String> kitchenEquipment,
      @JsonKey(name: 'serving_size_preference') int servingSizePreference,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$UserPreferencesModelImplCopyWithImpl<$Res>
    extends _$UserPreferencesModelCopyWithImpl<$Res, _$UserPreferencesModelImpl>
    implements _$$UserPreferencesModelImplCopyWith<$Res> {
  __$$UserPreferencesModelImplCopyWithImpl(_$UserPreferencesModelImpl _value,
      $Res Function(_$UserPreferencesModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? skillLevel = null,
    Object? spiceTolerance = null,
    Object? cookingTimePreference = null,
    Object? dietaryRestrictions = null,
    Object? excludedIngredients = null,
    Object? favoriteCuisines = null,
    Object? favoriteProteins = null,
    Object? kitchenEquipment = null,
    Object? servingSizePreference = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserPreferencesModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      skillLevel: null == skillLevel
          ? _value.skillLevel
          : skillLevel // ignore: cast_nullable_to_non_nullable
              as String,
      spiceTolerance: null == spiceTolerance
          ? _value.spiceTolerance
          : spiceTolerance // ignore: cast_nullable_to_non_nullable
              as String,
      cookingTimePreference: null == cookingTimePreference
          ? _value.cookingTimePreference
          : cookingTimePreference // ignore: cast_nullable_to_non_nullable
              as String,
      dietaryRestrictions: null == dietaryRestrictions
          ? _value._dietaryRestrictions
          : dietaryRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedIngredients: null == excludedIngredients
          ? _value._excludedIngredients
          : excludedIngredients // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteCuisines: null == favoriteCuisines
          ? _value._favoriteCuisines
          : favoriteCuisines // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteProteins: null == favoriteProteins
          ? _value._favoriteProteins
          : favoriteProteins // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kitchenEquipment: null == kitchenEquipment
          ? _value._kitchenEquipment
          : kitchenEquipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      servingSizePreference: null == servingSizePreference
          ? _value.servingSizePreference
          : servingSizePreference // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$UserPreferencesModelImpl extends _UserPreferencesModel {
  const _$UserPreferencesModelImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      @JsonKey(name: 'skill_level') this.skillLevel = 'beginner',
      @JsonKey(name: 'spice_tolerance') this.spiceTolerance = 'medium',
      @JsonKey(name: 'cooking_time_preference')
      this.cookingTimePreference = 'moderate',
      @JsonKey(name: 'dietary_restrictions')
      final List<String> dietaryRestrictions = const [],
      @JsonKey(name: 'excluded_ingredients')
      final List<String> excludedIngredients = const [],
      @JsonKey(name: 'favorite_cuisines')
      final List<String> favoriteCuisines = const [],
      @JsonKey(name: 'favorite_proteins')
      final List<String> favoriteProteins = const [],
      @JsonKey(name: 'kitchen_equipment')
      final List<String> kitchenEquipment = const [],
      @JsonKey(name: 'serving_size_preference') this.servingSizePreference = 2,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _dietaryRestrictions = dietaryRestrictions,
        _excludedIngredients = excludedIngredients,
        _favoriteCuisines = favoriteCuisines,
        _favoriteProteins = favoriteProteins,
        _kitchenEquipment = kitchenEquipment,
        super._();

  factory _$UserPreferencesModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserPreferencesModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'skill_level')
  final String skillLevel;
  @override
  @JsonKey(name: 'spice_tolerance')
  final String spiceTolerance;
  @override
  @JsonKey(name: 'cooking_time_preference')
  final String cookingTimePreference;
  final List<String> _dietaryRestrictions;
  @override
  @JsonKey(name: 'dietary_restrictions')
  List<String> get dietaryRestrictions {
    if (_dietaryRestrictions is EqualUnmodifiableListView)
      return _dietaryRestrictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dietaryRestrictions);
  }

  final List<String> _excludedIngredients;
  @override
  @JsonKey(name: 'excluded_ingredients')
  List<String> get excludedIngredients {
    if (_excludedIngredients is EqualUnmodifiableListView)
      return _excludedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedIngredients);
  }

  final List<String> _favoriteCuisines;
  @override
  @JsonKey(name: 'favorite_cuisines')
  List<String> get favoriteCuisines {
    if (_favoriteCuisines is EqualUnmodifiableListView)
      return _favoriteCuisines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteCuisines);
  }

  final List<String> _favoriteProteins;
  @override
  @JsonKey(name: 'favorite_proteins')
  List<String> get favoriteProteins {
    if (_favoriteProteins is EqualUnmodifiableListView)
      return _favoriteProteins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteProteins);
  }

  final List<String> _kitchenEquipment;
  @override
  @JsonKey(name: 'kitchen_equipment')
  List<String> get kitchenEquipment {
    if (_kitchenEquipment is EqualUnmodifiableListView)
      return _kitchenEquipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_kitchenEquipment);
  }

  @override
  @JsonKey(name: 'serving_size_preference')
  final int servingSizePreference;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserPreferencesModel(userId: $userId, skillLevel: $skillLevel, spiceTolerance: $spiceTolerance, cookingTimePreference: $cookingTimePreference, dietaryRestrictions: $dietaryRestrictions, excludedIngredients: $excludedIngredients, favoriteCuisines: $favoriteCuisines, favoriteProteins: $favoriteProteins, kitchenEquipment: $kitchenEquipment, servingSizePreference: $servingSizePreference, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserPreferencesModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.skillLevel, skillLevel) ||
                other.skillLevel == skillLevel) &&
            (identical(other.spiceTolerance, spiceTolerance) ||
                other.spiceTolerance == spiceTolerance) &&
            (identical(other.cookingTimePreference, cookingTimePreference) ||
                other.cookingTimePreference == cookingTimePreference) &&
            const DeepCollectionEquality()
                .equals(other._dietaryRestrictions, _dietaryRestrictions) &&
            const DeepCollectionEquality()
                .equals(other._excludedIngredients, _excludedIngredients) &&
            const DeepCollectionEquality()
                .equals(other._favoriteCuisines, _favoriteCuisines) &&
            const DeepCollectionEquality()
                .equals(other._favoriteProteins, _favoriteProteins) &&
            const DeepCollectionEquality()
                .equals(other._kitchenEquipment, _kitchenEquipment) &&
            (identical(other.servingSizePreference, servingSizePreference) ||
                other.servingSizePreference == servingSizePreference) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      skillLevel,
      spiceTolerance,
      cookingTimePreference,
      const DeepCollectionEquality().hash(_dietaryRestrictions),
      const DeepCollectionEquality().hash(_excludedIngredients),
      const DeepCollectionEquality().hash(_favoriteCuisines),
      const DeepCollectionEquality().hash(_favoriteProteins),
      const DeepCollectionEquality().hash(_kitchenEquipment),
      servingSizePreference,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserPreferencesModelImplCopyWith<_$UserPreferencesModelImpl>
      get copyWith =>
          __$$UserPreferencesModelImplCopyWithImpl<_$UserPreferencesModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserPreferencesModelImplToJson(
      this,
    );
  }
}

abstract class _UserPreferencesModel extends UserPreferencesModel {
  const factory _UserPreferencesModel(
      {@JsonKey(name: 'user_id') required final String userId,
      @JsonKey(name: 'skill_level') final String skillLevel,
      @JsonKey(name: 'spice_tolerance') final String spiceTolerance,
      @JsonKey(name: 'cooking_time_preference')
      final String cookingTimePreference,
      @JsonKey(name: 'dietary_restrictions')
      final List<String> dietaryRestrictions,
      @JsonKey(name: 'excluded_ingredients')
      final List<String> excludedIngredients,
      @JsonKey(name: 'favorite_cuisines') final List<String> favoriteCuisines,
      @JsonKey(name: 'favorite_proteins') final List<String> favoriteProteins,
      @JsonKey(name: 'kitchen_equipment') final List<String> kitchenEquipment,
      @JsonKey(name: 'serving_size_preference') final int servingSizePreference,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      required final DateTime updatedAt}) = _$UserPreferencesModelImpl;
  const _UserPreferencesModel._() : super._();

  factory _UserPreferencesModel.fromJson(Map<String, dynamic> json) =
      _$UserPreferencesModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'skill_level')
  String get skillLevel;
  @override
  @JsonKey(name: 'spice_tolerance')
  String get spiceTolerance;
  @override
  @JsonKey(name: 'cooking_time_preference')
  String get cookingTimePreference;
  @override
  @JsonKey(name: 'dietary_restrictions')
  List<String> get dietaryRestrictions;
  @override
  @JsonKey(name: 'excluded_ingredients')
  List<String> get excludedIngredients;
  @override
  @JsonKey(name: 'favorite_cuisines')
  List<String> get favoriteCuisines;
  @override
  @JsonKey(name: 'favorite_proteins')
  List<String> get favoriteProteins;
  @override
  @JsonKey(name: 'kitchen_equipment')
  List<String> get kitchenEquipment;
  @override
  @JsonKey(name: 'serving_size_preference')
  int get servingSizePreference;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserPreferencesModelImplCopyWith<_$UserPreferencesModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
