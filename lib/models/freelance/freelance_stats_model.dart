// ─────────────────────────────────────────────────────────────────────────────
// freelance_stats_model.dart
// Agrège toutes les données du profil d'un freelance en un seul objet.
//
// Ce modèle est rempli par ProfilController en combinant 3 appels API :
//   1. GET /statistics/freelancer/{id}   → compteurs (stats chiffrées)
//   2. GET /applications/my-applications → liste des candidatures
//   3. GET /reviews/?reviewee_id={id}    → liste des avis reçus
// ─────────────────────────────────────────────────────────────────────────────

import 'application_model.dart';
import '../shared/review_model.dart';

class FreelanceStatsModel {
  // ── Statistiques chiffrées (from /statistics/freelancer/{id}) ─────────────
  final int tasksDone;
  final int tasksInProgress;
  final int applicationsSent;
  final int applicationsAccepted;
  final int applicationsRejected;
  final double successRate;

  // ── Liste détaillée des candidatures (from /applications/my-applications) ──
  final List<ApplicationModel> applications;

  // ── Avis / Commentaires reçus (from /reviews/?reviewee_id={id}) ───────────
  final List<ReviewModel> reviews;

  FreelanceStatsModel({
    required this.tasksDone,
    required this.tasksInProgress,
    required this.applicationsSent,
    required this.applicationsAccepted,
    required this.applicationsRejected,
    required this.successRate,
    required this.applications,
    required this.reviews,
  });

  // ── Calculé : note moyenne sur tous les avis ──────────────────────────────
  double get averageRating {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }

  // ── Constructeur pour un état "vide" ou d'erreur ──────────────────────────
  factory FreelanceStatsModel.empty() {
    return FreelanceStatsModel(
      tasksDone: 0,
      tasksInProgress: 0,
      applicationsSent: 0,
      applicationsAccepted: 0,
      applicationsRejected: 0,
      successRate: 0.0,
      applications: [],
      reviews: [],
    );
  }

  /// Construit les compteurs depuis la réponse JSON de /statistics/freelancer/{id}
  factory FreelanceStatsModel.fromStatsJson(
    Map<String, dynamic> json, {
    List<ApplicationModel> applications = const [],
    List<ReviewModel> reviews = const [],
  }) {
    return FreelanceStatsModel(
      tasksDone: json['tasks_completed'] as int? ?? 0,
      tasksInProgress: json['tasks_in_progress'] as int? ?? 0,
      applicationsSent: json['applications_sent'] as int? ?? 0,
      applicationsAccepted: json['applications_accepted'] as int? ?? 0,
      applicationsRejected: json['applications_rejected'] as int? ?? 0,
      successRate: (json['success_rate'] as num?)?.toDouble() ?? 0.0,
      applications: applications,
      reviews: reviews,
    );
  }
}
