import 'package:flutter/material.dart';

// ─── ÉNUMS ASSOCIÉS ─────────────────────────────────────────────────────────

enum FeedbackCategory {
  general,
  bug,
  featureRequest,
  other;

  factory FeedbackCategory.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'bug':
        return FeedbackCategory.bug;
      case 'feature_request':
      case 'featurerequest':
        return FeedbackCategory.featureRequest;
      case 'other':
        return FeedbackCategory.other;
      default:
        return FeedbackCategory.general;
    }
  }

  String toServerString() {
    switch (this) {
      case FeedbackCategory.bug:
        return 'BUG';
      case FeedbackCategory.featureRequest:
        return 'FEATURE_REQUEST';
      case FeedbackCategory.other:
        return 'OTHER';
      case FeedbackCategory.general:
        return 'GENERAL';
    }
  }

  String get label {
    switch (this) {
      case FeedbackCategory.bug:
        return 'Signaler un bug';
      case FeedbackCategory.featureRequest:
        return 'Suggestion';
      case FeedbackCategory.other:
        return 'Autre';
      case FeedbackCategory.general:
        return 'Général';
    }
  }
}

enum FeedbackStatus {
  pending,
  answered,
  closed;

  factory FeedbackStatus.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'answered':
        return FeedbackStatus.answered;
      case 'closed':
        return FeedbackStatus.closed;
      default:
        return FeedbackStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case FeedbackStatus.answered:
        return 'Répondu';
      case FeedbackStatus.closed:
        return 'Fermé';
      case FeedbackStatus.pending:
        return 'En attente';
    }
  }

  Color get color {
    switch (this) {
      case FeedbackStatus.answered:
        return Colors.green;
      case FeedbackStatus.closed:
        return Colors.grey;
      case FeedbackStatus.pending:
        return Colors.orange;
    }
  }
}

// ─── MODÈLE PRINCIPAL (FeedbackSchema) ──────────────────────────────────────

class FeedbackModel {
  final int id;
  final String content;
  final FeedbackCategory category;
  final FeedbackStatus status;
  final DateTime createdAt;
  final String? adminReply;
  final DateTime? repliedAt;
  final int userId;
  final int? repliedBy;

  FeedbackModel({
    required this.id,
    required this.content,
    required this.category,
    required this.status,
    required this.createdAt,
    this.adminReply,
    this.repliedAt,
    required this.userId,
    this.repliedBy,
  });

  /// Factory pour convertir le JSON de l'API (FeedbackSchema)
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    final categoryValue = json['category']?.toString() ?? 'GENERAL';
    final statusValue = json['status']?.toString() ?? 'PENDING';

    return FeedbackModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      content: json['content']?.toString() ?? '',
      category: FeedbackCategory.fromString(categoryValue),
      status: FeedbackStatus.fromString(statusValue),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      adminReply: json['admin_reply']?.toString(),
      repliedAt: json['replied_at'] != null
          ? DateTime.tryParse(json['replied_at'].toString())
          : null,
      userId: int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      repliedBy: json['replied_by'] != null
          ? int.tryParse(json['replied_by'].toString())
          : null,
    );
  }

  /// Convertit le modèle en JSON complet
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'category': category.toServerString(),
      'status': status.name.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'admin_reply': adminReply,
      'replied_at': repliedAt?.toIso8601String(),
      'user_id': userId,
      'replied_by': repliedBy,
    };
  }

  /// Pratique pour la route de création (FeedbackCreate)
  static Map<String, dynamic> toCreateJson({
    required String content,
    FeedbackCategory category = FeedbackCategory.general,
  }) {
    return {'content': content, 'category': category.toServerString()};
  }
}
