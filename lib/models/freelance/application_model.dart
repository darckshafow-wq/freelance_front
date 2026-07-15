enum ApplicationStatus {
  pending,
  accepted,
  rejected;

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      default:
        return ApplicationStatus.pending;
    }
  }

  String toJson() => name;
}

class ApplicationModel {
  final int id;
  final int taskId;
  final int freelancerId;
  final String coverLetter;
  final double proposedBudget;
  final ApplicationStatus status;
  final DateTime? createdAt;

  ApplicationModel({
    required this.id,
    required this.taskId,
    required this.freelancerId,
    required this.coverLetter,
    required this.proposedBudget,
    required this.status,
    this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawStatus = json['status'] ?? json['application_status'];
    final dynamic rawMessage =
        json['message'] ??
        json['cover_letter'] ??
        json['coverLetter'] ??
        json['cover_letter'];
    final dynamic rawTaskId = json['task_id'] ?? json['taskId'];
    final dynamic rawFreelancerId =
        json['freelance_id'] ?? json['freelancer_id'] ?? json['freelancerId'];
    final dynamic rawBudget =
        json['proposed_budget'] ?? json['proposedBudget'] ?? json['budget'];

    return ApplicationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      taskId: int.tryParse(rawTaskId?.toString() ?? '0') ?? 0,
      freelancerId: int.tryParse(rawFreelancerId?.toString() ?? '0') ?? 0,
      coverLetter: rawMessage?.toString() ?? '',
      proposedBudget: (rawBudget as num?)?.toDouble() ?? 0.0,
      status: ApplicationStatus.fromString(rawStatus?.toString() ?? 'pending'),
      createdAt: json['createdAt'] ?? json['created_at'] != null
          ? DateTime.tryParse(
              (json['createdAt'] ?? json['created_at']).toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'freelancer_id': freelancerId,
      'cover_letter': coverLetter,
      'proposed_budget': proposedBudget,
      'status': status.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
