class ReportModel {
  final int id;
  final int reporterId;
  final int? targetId;
  final int? projectId;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.projectId,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int? ?? 0,
      reporterId: json['reporter_id'] as int? ?? 0,
      targetId: json['target_id'] as int?,
      projectId: json['project_id'] as int?,
      reason: json['reason'] as String? ?? '',
      status: (json['status'] as String?)?.toUpperCase() ?? 'OPEN',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reporter_id': reporterId,
        'target_id': targetId,
        'project_id': projectId,
        'reason': reason,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
