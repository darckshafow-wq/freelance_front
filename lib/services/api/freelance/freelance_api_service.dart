// ─────────────────────────────────────────────────────────────────────────────
// freelance_api_service.dart
// Service d'accès à l'API pour les fonctionnalités Freelance.
//
// Chaque méthode correspond à un endpoint backend précis.
// Ce service ne contient PAS de logique métier — il fait juste les requêtes
// et retourne des ApiResponse. La logique est dans les contrôleurs.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer' as dev;
import '../api_core.dart';
import '../api_endpoints.dart';
import '../api_response.dart';
import '../../../models/freelance/application_model.dart';
import '../../../models/shared/review_model.dart';

class FreelanceApiService {
  final ApiClient _client = ApiClient();

  // ── 1. Statistiques chiffrées ─────────────────────────────────────────────
  /// GET /api/v1/statistics/freelancer/{userId}
  /// Retourne les compteurs (missions, candidatures, taux de succès).
  Future<ApiResponse<Map<String, dynamic>>> getFreelancerStats(
    int userId,
  ) async {
    dev.log('[FreelanceApiService] getFreelancerStats(userId: $userId)');
    return _client.get<Map<String, dynamic>>(
      endpoint: ApiEndpoints.freelanceStats(userId),
      parser: (json) => json as Map<String, dynamic>,
    );
  }

  // ── 2. Candidatures du freelance ──────────────────────────────────────────
  /// GET /api/v1/applications/my-applications
  /// Retourne la liste de toutes les candidatures soumises par le freelance connecté.
  Future<ApiResponse<List<ApplicationModel>>> getMyApplications() async {
    dev.log('[FreelanceApiService] getMyApplications()');
    return _client.get<List<ApplicationModel>>(
      endpoint: ApiEndpoints.freelanceMyApplications,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map(
              (item) => ApplicationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );
  }

  // ── 3. Avis / Commentaires reçus ──────────────────────────────────────────
  /// GET /api/v1/reviews/?reviewee_id={userId}
  /// Retourne la liste des avis laissés par des clients sur ce freelance.
  Future<ApiResponse<List<ReviewModel>>> getReviewsForFreelancer(
    int userId,
  ) async {
    dev.log('[FreelanceApiService] getReviewsForFreelancer(userId: $userId)');
    // Le backend /reviews/ accepte un query param reviewee_id pour filtrer
    final endpoint = '${ApiEndpoints.reviews}?reviewee_id=$userId';
    return _client.get<List<ReviewModel>>(
      endpoint: endpoint,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => ReviewModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
