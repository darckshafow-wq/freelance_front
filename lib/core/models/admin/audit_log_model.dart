class AuditLogModel {
  final int id;
  final int userId;
  final String action;
  final String targetType;
  final int targetId;
  final String details;
  final DateTime? createdAt;

  const AuditLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.details,
    this.createdAt,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      action: json['action'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      targetId: json['target_id'] as int? ?? 0,
      details: json['details'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'action': action,
        'target_type': targetType,
        'target_id': targetId,
        'details': details,
        'created_at': createdAt?.toIso8601String(),
      };
}
