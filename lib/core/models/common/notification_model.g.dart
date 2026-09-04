// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'is_read': instance.isRead,
      'created_at': instance.createdAt?.toIso8601String(),
    };
