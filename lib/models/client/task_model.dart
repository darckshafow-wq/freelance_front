enum TaskStatus {
  pending,
  validated,
  executed;

  static TaskStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TaskStatus.pending;
      case 'validated':
        return TaskStatus.validated;
      case 'executed':
        return TaskStatus.executed;
      default:
        return TaskStatus.pending;
    }
  }

  String toJson() => name;
}

class TaskModel {
  final int id;
  final String title;
  final String description;

  /// Budget de la mission.
  /// Côté backend : champ 'price' (SQLAlchemy/Pydantic).
  /// Côté Flutter : affiché comme 'budget'.
  /// Les deux sont gérés dans fromJson().
  final double budget;

  final TaskStatus status;
  final int clientId;
  final int? assignedToId;
  final DateTime? deadline;
  final DateTime? createdAt;

  /// Champ optionnel du backend réel
  final String? location;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.status,
    required this.clientId,
    this.assignedToId,
    this.deadline,
    this.createdAt,
    this.location,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Support de 'budget' (mock) ET 'price' (backend réel)
    final double budget =
        (json['budget'] ?? json['price'] as num?)?.toDouble() ?? 0.0;

    return TaskModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      budget: budget,
      status: TaskStatus.fromString(json['status'] as String? ?? 'pending'),
      clientId: json['clientId'] ?? json['client_id'] ?? 0,
      assignedToId: json['assignedToId'] ?? json['assigned_to_id'],
      location: json['location'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.tryParse(
              (json['createdAt'] ?? json['created_at']).toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // Envoi en 'price' pour être compatible avec le backend FastAPI réel
      'price': budget,
      'status': status.toJson(),
      'client_id': clientId,
      'assigned_to_id': assignedToId,
      'location': location,
      'deadline': deadline?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'TaskModel(id: $id, title: "$title", budget: $budget, status: ${status.name})';
}
