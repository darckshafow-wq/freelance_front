enum ApplicationStatus {
  pending,
  interview, // Phase de discussion avant attribution
  accepted,
  rejected;

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;

      case 'interview':
        return ApplicationStatus.interview;

      case 'accepted':
      case 'validated': // Gère le statut "validated" de ton JSON

        return ApplicationStatus.accepted;

      case 'rejected':
      case 'declined':
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
  final String? taskTitle;
  final String? taskDescription;
  final int freelancerId;
  final String coverLetter;
  final double proposedBudget;
  final ApplicationStatus status;
  final DateTime? createdAt;
  final int? clientId; // Added for messaging

  ApplicationModel({
    required this.id,
    required this.taskId,
    this.taskTitle,
    this.taskDescription,
    required this.freelancerId,
    required this.coverLetter,
    required this.proposedBudget,
    required this.status,
    this.createdAt,
    this.clientId,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawStatus = json['status'] ?? json['application_status'];
    final dynamic rawMessage =
        json['cover_letter'] ?? json['coverLetter'] ?? json['message'] ?? '';

    // Utilise en priorité 'task_id', et évite de fallback sur la clé 'id' de la candidature
    final dynamic rawTaskId = json['task_id'] ?? json['taskId'];

    // Ton JSON utilise 'client_id' pour le créateur ou le candidat selon l'API
    final dynamic rawFreelancerId =
        json['freelancer_id'] ?? json['freelancerId'] ?? json['freelance_id'];

    final dynamic rawBudget =
        json['proposed_budget'] ??
        json['proposedBudget'] ??
        json['budget'] ??
        json['price'];

    return ApplicationModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      taskId: int.tryParse(rawTaskId?.toString() ?? '0') ?? 0,
      // CORRECTION ICI : Gère 'task_title' en priorité, puis replie sur 'title'
      taskTitle: (json['task_title'] ?? json['title'])?.toString(),
      taskDescription: (json['task_description'] ?? json['description'])
          ?.toString(),
      freelancerId: int.tryParse(rawFreelancerId?.toString() ?? '0') ?? 0,
      coverLetter: rawMessage?.toString() ?? '',
      proposedBudget: (rawBudget as num?)?.toDouble() ?? 0.0,
      status: ApplicationStatus.fromString(rawStatus?.toString() ?? 'pending'),
      createdAt: (json['createdAt'] ?? json['created_at']) != null
          ? DateTime.tryParse(
              (json['createdAt'] ?? json['created_at']).toString(),
            )
          : null,
      clientId: json['client_id'] != null
          ? int.tryParse(json['client_id'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'task_title': taskTitle, // Alignement avec l'API
      'description': taskDescription,
      'freelancer_id': freelancerId,
      'cover_letter': coverLetter,
      'proposed_budget': proposedBudget,
      'status': status.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'client_id': clientId,
    };
  }
}
