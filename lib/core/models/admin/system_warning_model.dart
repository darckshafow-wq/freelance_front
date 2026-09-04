class SystemWarningModel {
  final int id;
  final String warningType;
  final int? userId;
  final String description;
  final bool isResolved;
  final DateTime? createdAt;

  const SystemWarningModel({
    required this.id,
    required this.warningType,
    required this.userId,
    required this.description,
    required this.isResolved,
    this.createdAt,
  });

  factory SystemWarningModel.fromJson(Map<String, dynamic> json) {
    return SystemWarningModel(
      id: json['id'] as int? ?? 0,
      warningType: json['warning_type'] as String? ?? 'UNKNOWN',
      userId: json['user_id'] as int?,
      description: json['description'] as String? ?? '',
      isResolved: json['is_resolved'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'warning_type': warningType,
        'user_id': userId,
        'description': description,
        'is_resolved': isResolved,
        'created_at': createdAt?.toIso8601String(),
      };
}
