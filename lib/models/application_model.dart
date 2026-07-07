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
    return ApplicationModel(
      id: json['id'] as int,
      taskId: json['taskId'] ?? json['task_id'] ?? 0,
      freelancerId: json['freelancerId'] ?? json['freelancer_id'] ?? 0,
      coverLetter: json['coverLetter'] ?? json['cover_letter'] ?? '',
      proposedBudget: (json['proposedBudget'] ?? json['proposed_budget'] as num?)?.toDouble() ?? 0.0,
      status: ApplicationStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: json['createdAt'] ?? json['created_at'] != null 
          ? DateTime.parse(json['createdAt'] ?? json['created_at']) 
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
