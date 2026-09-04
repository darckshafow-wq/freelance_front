class FeedbackModel {
  final int id;
  final int userId;
  final String subject;
  final String content;
  final String adminReply;
  final String status;
  final DateTime? createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.content,
    required this.adminReply,
    required this.status,
    this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      adminReply: json['admin_reply'] as String? ?? '',
      status: (json['status'] as String?)?.toUpperCase() ?? 'PENDING',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'subject': subject,
        'content': content,
        'admin_reply': adminReply,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
      };
}
