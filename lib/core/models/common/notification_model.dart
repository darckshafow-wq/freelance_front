import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String title;
  final String content;
  final String type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
