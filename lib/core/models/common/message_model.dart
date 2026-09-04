class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Parsing sécurisé de la date depuis created_at
    final rawDate = json['created_at'] ?? json['createdAt'];
    final parsedDate = rawDate != null 
        ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now()
        : DateTime.now();

    return MessageModel(
      id: json['id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? json['senderId'] as int? ?? 0,
      receiverId: json['receiver_id'] as int? ?? json['receiverId'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      createdAt: parsedDate,
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
    );
  }
}