class ConversationModel {
  final int id;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.avatarUrl,
    this.isOnline = false,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
  // Extraire l'objet freelance s'il existe
  final freelance = json['freelance'] as Map<String, dynamic>?;
  final profile = freelance?['profile'] as Map<String, dynamic>?;
  
  // Extraire le dernier message s'il existe
  final lastMsgMap = json['last_message'] as Map<String, dynamic>?;
  final lastMsgContent = lastMsgMap?['content'] as String? ?? 'Aucun message';

  // Récupérer la date du dernier message ou de mise à jour
  final rawDate = lastMsgMap?['created_at'] ?? json['updated_at'];
  final parsedDate = rawDate != null 
      ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
      : DateTime.now();

  return ConversationModel(
    id: json['project_id'] as int? ?? json['id'] as int? ?? 0,
    otherUserName: freelance?['full_name'] as String? ?? 'Utilisateur',
    lastMessage: lastMsgContent,
    lastMessageTime: parsedDate,
    avatarUrl: profile?['avatar_url'] as String? ?? '',
    isOnline: json['is_online'] as bool? ?? false,
    unreadCount: json['unread_count'] as int? ?? 0,
  );
}
}
