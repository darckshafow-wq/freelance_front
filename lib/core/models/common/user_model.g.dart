// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String? ?? '',
  fullName: (json['full_name'] as String?) ?? (json['name'] as String? ?? ''),
  role: json['role'] as String? ?? 'user',
  isActive: json['is_active'] as bool? ?? true,
  isSuspended: json['is_suspended'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  failedLoginAttempts: (json['failed_login_attempts'] as num?)?.toInt(),
  lastFailedLogin: json['last_failed_login'] == null
      ? null
      : DateTime.parse(json['last_failed_login'] as String),
  profile: json['profile'] == null
      ? null
      : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'full_name': instance.fullName,
  'role': instance.role,
  'is_active': instance.isActive,
  'is_suspended': instance.isSuspended,
  'created_at': instance.createdAt?.toIso8601String(),
  'failed_login_attempts': instance.failedLoginAttempts,
  'last_failed_login': instance.lastFailedLogin?.toIso8601String(),
  'profile': instance.profile,
};
