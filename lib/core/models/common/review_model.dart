class ReviewModel {
  final int id;
  final int projectId;
  final int reviewerId;
  final int revieweeId;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final String? reviewerName;
  final String? reviewerAvatarUrl;
  final String? projectTitle;
  final DateTime? applicationDate;
  final DateTime? completionDate;

  const ReviewModel({
    required this.id,
    required this.projectId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.reviewerName,
    this.reviewerAvatarUrl,
    this.projectTitle,
    this.applicationDate,
    this.completionDate,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      reviewerId: json['reviewer_id'] as int? ?? 0,
      revieweeId: json['reviewee_id'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
        reviewerName: json['reviewer_name'] as String?,
        reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
        projectTitle: json['project_title'] as String?,
        applicationDate: json['application_date'] == null ? null : DateTime.tryParse(json['application_date'].toString()),
        completionDate: json['completion_date'] == null ? null : DateTime.tryParse(json['completion_date'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'reviewer_id': reviewerId,
        'reviewee_id': revieweeId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt?.toIso8601String(),
        'reviewer_name': reviewerName,
        'reviewer_avatar_url': reviewerAvatarUrl,
        'project_title': projectTitle,
        'application_date': applicationDate?.toIso8601String(),
        'completion_date': completionDate?.toIso8601String(),
      };
}
