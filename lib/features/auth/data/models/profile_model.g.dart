// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      r'_$ProfileModelImpl',
      json,
      ($checkedConvert) {
        final val = _$ProfileModelImpl(
          id: $checkedConvert('id', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          displayName: $checkedConvert('display_name', (v) => v as String?),
          avatarUrl: $checkedConvert('avatar_url', (v) => v as String?),
          bio: $checkedConvert('bio', (v) => v as String?),
          phoneNumber: $checkedConvert('phone_number', (v) => v as String?),
          dateOfBirth: $checkedConvert('date_of_birth',
              (v) => v == null ? null : DateTime.parse(v as String)),
          country: $checkedConvert('country', (v) => v as String?),
          languagePreference: $checkedConvert(
              'language_preference', (v) => v as String? ?? 'en'),
          themePreference: $checkedConvert(
              'theme_preference', (v) => v as String? ?? 'system'),
          notificationsEnabled: $checkedConvert(
              'notifications_enabled', (v) => v as bool? ?? true),
          emailNotificationsEnabled:
              $checkedConvert('email_notifications', (v) => v as bool? ?? true),
          createdAt:
              $checkedConvert('created_at', (v) => DateTime.parse(v as String)),
          updatedAt:
              $checkedConvert('updated_at', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {
        'displayName': 'display_name',
        'avatarUrl': 'avatar_url',
        'phoneNumber': 'phone_number',
        'dateOfBirth': 'date_of_birth',
        'languagePreference': 'language_preference',
        'themePreference': 'theme_preference',
        'notificationsEnabled': 'notifications_enabled',
        'emailNotificationsEnabled': 'email_notifications',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at'
      },
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'phone_number': instance.phoneNumber,
      'date_of_birth': instance.dateOfBirth?.toIso8601String(),
      'country': instance.country,
      'language_preference': instance.languagePreference,
      'theme_preference': instance.themePreference,
      'notifications_enabled': instance.notificationsEnabled,
      'email_notifications': instance.emailNotificationsEnabled,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
