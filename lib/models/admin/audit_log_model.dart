class AuditLogResponse {
  final Map<String, int> aggregatedByRole;
  final List<AuditLogEntry> recent;

  AuditLogResponse({required this.aggregatedByRole, required this.recent});

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    final aggregated = <String, int>{};
    final rawAggregated =
        json['aggregated_by_role'] as Map<String, dynamic>? ?? {};
    rawAggregated.forEach((key, value) {
      aggregated[key] = int.tryParse(value.toString()) ?? 0;
    });

    final recent = (json['recent'] as List? ?? [])
        .map((item) => AuditLogEntry.fromJson(item as Map<String, dynamic>))
        .toList();

    return AuditLogResponse(aggregatedByRole: aggregated, recent: recent);
  }
}

class AuditLogEntry {
  final int? userId;
  final String path;
  final String method;
  final String role;
  final DateTime createdAt;

  AuditLogEntry({
    required this.userId,
    required this.path,
    required this.method,
    required this.role,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      userId: json['user_id'] == null
          ? null
          : int.tryParse(json['user_id'].toString()),
      path: json['path']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
