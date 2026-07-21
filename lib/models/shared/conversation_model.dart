class ConversationContact {
  final int userId; // Réservé pour l'ID du client (si fourni plus tard)
  final int
  applicationId; // ID de la candidature (très important pour ton contexte)
  final int taskId; // ID de la tâche
  final String userName; // Le nom affiché (client_name)
  final String
  taskTitle; // Le titre de la tâche (utile pour l'affichage du contexte)
  final String lastMessage;
  final DateTime lastTimestamp;

  ConversationContact({
    required this.userId,
    required this.applicationId,
    required this.taskId,
    required this.userName,
    required this.taskTitle,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  factory ConversationContact.fromJson(Map<String, dynamic> json) {
    // Backend retourne : contact_id, contact_name, last_message, last_timestamp
    // associated_task_id, associated_task_title
    String lastMsg = json['last_message']?.toString() ?? 'Nouvelle discussion ouverte !';
    String? tsRaw = json['last_timestamp']?.toString();
    DateTime lastTime = tsRaw != null
        ? (DateTime.tryParse(tsRaw) ?? DateTime.now())
        : DateTime.now();

    return ConversationContact(
      userId: json['contact_id'] as int? ?? 0,
      applicationId: json['application_id'] as int? ?? 0,
      taskId: json['associated_task_id'] as int? ?? 0,
      userName: json['contact_name'] as String? ?? 'Inconnu',
      taskTitle: json['associated_task_title'] as String? ?? '',
      lastMessage: lastMsg,
      lastTimestamp: lastTime,
    );
  }
}
