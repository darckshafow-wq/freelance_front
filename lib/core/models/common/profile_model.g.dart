// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  bio: json['bio'] as String?,
  skills: (json['skills'] as List<dynamic>?)?.map((e) => e as String).toList(),
  ratingAverage: (json['rating_average'] as num?)?.toDouble(),
  avatarUrl: json['avatar_url'] as String?,
  identityVerified: json['identity_verified'] as bool? ?? false,
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'bio': instance.bio,
      'skills': instance.skills,
      'rating_average': instance.ratingAverage,
      'avatar_url': instance.avatarUrl,
      'identity_verified': instance.identityVerified,
    };
