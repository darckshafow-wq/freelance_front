class ProposalModel {
  final int id;
  final int projectId;
  final int freelanceId;
  final String message;
  final double proposedPrice;
  final bool isDirectOffer;
  final bool offeredByClient;
  final String status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  const ProposalModel({
    required this.id,
    required this.projectId,
    required this.freelanceId,
    required this.message,
    required this.proposedPrice,
    required this.isDirectOffer,
    required this.offeredByClient,
    required this.status,
    this.createdAt,
    this.respondedAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id'] as int? ?? 0,
      projectId: json['project_id'] as int? ?? 0,
      freelanceId: json['freelance_id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      proposedPrice: (json['proposed_price'] as num?)?.toDouble() ?? 0.0,
      isDirectOffer: json['is_direct_offer'] as bool? ?? false,
      offeredByClient: json['offered_by_client'] as bool? ?? false,
      status: (json['status'] as String?)?.toUpperCase() ?? 'PENDING',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      respondedAt: json['responded_at'] == null
          ? null
          : DateTime.tryParse(json['responded_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'freelance_id': freelanceId,
        'message': message,
        'proposed_price': proposedPrice,
        'is_direct_offer': isDirectOffer,
        'offered_by_client': offeredByClient,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'responded_at': respondedAt?.toIso8601String(),
      };
}
