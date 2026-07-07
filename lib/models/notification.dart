/// Types de notifications possibles dans l'application.
enum NotificationType {
  newApplication, // Un freelance a postulé sur une mission
  applicationAccepted, // Ta candidature a été acceptée
  applicationRejected, // Ta candidature a été refusée
  missionValidated, // Une mission a été validée
  missionCompleted, // Une mission est terminée
  newMessage, // Nouveau message reçu
  paymentReceived, // Paiement reçu
  system; // Notification système

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.system,
    );
  }

  String toJson() => name;
}

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  /// ID de la ressource liée (ex: id de la mission ou de la candidature)
  final int? relatedId;

  /// Route à ouvrir lors du tap sur la notification
  final String? actionRoute;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.actionRoute,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      relatedId: relatedId,
      actionRoute: actionRoute,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String? ?? 'system'),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      relatedId: json['related_id'] as int?,
      actionRoute: json['action_route'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toJson(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'related_id': relatedId,
      'action_route': actionRoute,
    };
  }
}
