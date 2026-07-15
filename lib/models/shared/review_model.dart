// ─────────────────────────────────────────────────────────────────────────────
// review_model.dart
// Représente un avis/commentaire laissé par un client après une mission.
//
// Correspond à l'endpoint backend : GET /api/v1/reviews/
// Structure JSON retournée par FastAPI :
// {
//   "id": 1,
//   "task_id": 5,
//   "reviewer_id": 2,
//   "reviewee_id": 7,
//   "rating": 4.5,
//   "comment": "Excellent travail, très professionnel.",
//   "created_at": "2026-06-15T10:20:00"
// }
// ─────────────────────────────────────────────────────────────────────────────

class ReviewModel {
  final int id;

  /// ID de la mission sur laquelle porte l'avis
  final int taskId;

  /// ID de l'utilisateur qui laisse l'avis (le client)
  final int reviewerId;

  /// ID de l'utilisateur qui reçoit l'avis (le freelance)
  final int revieweeId;

  /// Note sur 5
  final double rating;

  /// Commentaire textuel laissé par le client
  final String comment;

  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.taskId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int,
      taskId: json['task_id'] as int? ?? 0,
      reviewerId: json['reviewer_id'] as int? ?? 0,
      revieweeId: json['reviewee_id'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'reviewer_id': reviewerId,
      'reviewee_id': revieweeId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
