import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/profile.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

/// Profile model for data layer with JSON serialization
/// 
/// This model handles conversion between Supabase JSON and domain entities.
@freezed
class ProfileModel with _$ProfileModel {
  const ProfileModel._();

  const factory ProfileModel({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'date_of_birth') DateTime? dateOfBirth,
    String? country,
    @JsonKey(name: 'language_preference') @Default('en') String languagePreference,
    @JsonKey(name: 'theme_preference') @Default('system') String themePreference,
    @JsonKey(name: 'notifications_enabled') @Default(true) bool notificationsEnabled,
    @JsonKey(name: 'email_notifications') @Default(true) bool emailNotificationsEnabled,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProfileModel;

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  /// Convert model to domain entity
  Profile toEntity() {
    return Profile(
      id: id,
      email: email,
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      phoneNumber: phoneNumber,
      dateOfBirth: dateOfBirth,
      country: country,
      languagePreference: languagePreference,
      themePreference: themePreference,
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from domain entity
  factory ProfileModel.fromEntity(Profile entity) {
    return ProfileModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      avatarUrl: entity.avatarUrl,
      bio: entity.bio,
      phoneNumber: entity.phoneNumber,
      dateOfBirth: entity.dateOfBirth,
      country: entity.country,
      languagePreference: entity.languagePreference,
      themePreference: entity.themePreference,
      notificationsEnabled: entity.notificationsEnabled,
      emailNotificationsEnabled: entity.emailNotificationsEnabled,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
