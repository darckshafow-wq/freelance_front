// ─────────────────────────────────────────────────────────────────────────────
// profil_controller.dart
// Contrôleur du profil Freelance.
//
// Ce contrôleur charge en parallèle les 3 sources de données nécessaires
// pour afficher le profil complet d'un freelance :
//
//   ① Statistiques chiffrées  →  FreelanceApiService.getFreelancerStats()
//   ② Candidatures soumises   →  FreelanceApiService.getMyApplications()
//   ③ Avis / Commentaires     →  FreelanceApiService.getReviewsForFreelancer()
//
// Le résultat est un FreelanceStatsModel qui agrège les 3.
//
// Usage depuis la Vue :
//   final controller = ProfilController();
//   final stats = await controller.loadFullProfile(userId: 42);
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../models/freelance/freelance_stats_model.dart';
import '../../models/freelance/application_model.dart';
import '../../models/shared/review_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';
import '../../services/api/freelance/freelance_api_service.dart';

class ProfilController extends ChangeNotifier {
  final FreelanceApiService _service = FreelanceApiService();
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FreelanceStatsModel _stats = FreelanceStatsModel.empty();
  FreelanceStatsModel get stats => _stats;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static int? resolveUserId(String? rawUserId, {int? currentUserId}) {
    dev.log(
      '[ProfilController] resolveUserId called with rawUserId: $rawUserId, currentUserId: $currentUserId',
    );

    if (rawUserId == null || rawUserId.trim().isEmpty) {
      return currentUserId;
    }

    final normalized = rawUserId.trim().toLowerCase();
    if (normalized == 'me' || normalized == 'self' || normalized == 'null') {
      return currentUserId;
    }

    final parsed = int.tryParse(rawUserId);
    if (parsed != null && parsed > 0) {
      return parsed;
    }

    return currentUserId;
  }

  // ── Charge les informations de base de l'utilisateur ──────────────────────
  /// GET /api/v1/users/{userId} — ou /users/me si userId == 0 (fallback)
  /// Retourne le [UserModel] ou null en cas d'erreur.
  Future<UserModel?> getUserInfo(int userId) async {
    dev.log('[ProfilController] getUserInfo(userId: $userId) started');
    _setLoading(true);

    // Si userId <= 0, on résout d'abord l'utilisateur courant via /users/me
    if (userId <= 0) {
      dev.log(
        '[ProfilController] getUserInfo - userId invalide, fallback sur /users/me',
      );
      final user = await _fetchCurrentUserViaMe();
      _setLoading(false);
      return user;
    }

    final response = await _apiClient.get<UserModel>(
      endpoint: ApiEndpoints.userProfileById(userId),
      parser: (json) {
        dev.log('[ProfilController] getUserInfo - Raw JSON: $json');
        final model = UserModel.fromJson(json as Map<String, dynamic>);
        dev.log(
          '[ProfilController] getUserInfo - Parsed UserModel: ID=${model.id}, Name="${model.fullName}", Email="${model.email}"',
        );
        return model;
      },
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      dev.log(
        '[ProfilController] getUserInfo SUCCESS: ID=${response.data!.id}',
      );
      return response.data;
    }

    dev.log(
      '[ProfilController] getUserInfo FAILED for userId=$userId, trying /users/me fallback',
    );
    return await _fetchCurrentUserViaMe();
  }

  /// Fallback interne : récupère l'utilisateur courant via /users/me
  Future<UserModel?> _fetchCurrentUserViaMe() async {
    dev.log('[ProfilController] _fetchCurrentUserViaMe - calling /users/me');
    final meResponse = await _apiClient.get<UserModel>(
      endpoint: ApiEndpoints.meProfile,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (meResponse.isSuccess && meResponse.data != null) {
      dev.log(
        '[ProfilController] _fetchCurrentUserViaMe SUCCESS: ID=${meResponse.data!.id}',
      );
      return meResponse.data;
    }
    dev.log(
      '[ProfilController] _fetchCurrentUserViaMe FAILED: ${meResponse.message}',
    );
    return null;
  }

  // ── Charge toutes les statistiques du freelance en parallèle ──────────────
  /// Fait 3 appels API simultanément avec Future.wait() pour être rapide.
  /// Retourne un [FreelanceStatsModel] même en cas d'erreur partielle
  /// (les sections qui ont échoué seront vides plutôt que de tout planter).
  Future<FreelanceStatsModel> loadFullProfile({required int userId}) async {
    dev.log('[ProfilController] loadFullProfile(userId: $userId) — démarrage');
    _setLoading(true);

    // Résolution de l'ID réel : si 0/null, on appelle /users/me
    int effectiveUserId = userId;
    if (effectiveUserId <= 0) {
      dev.log(
        '[ProfilController] loadFullProfile - userId invalide, résolution via /users/me',
      );
      final me = await _fetchCurrentUserViaMe();
      if (me == null || me.id <= 0) {
        dev.log(
          '[ProfilController] loadFullProfile - Impossible de résoudre userId, returning empty profile.',
        );
        _setLoading(false);
        return FreelanceStatsModel.empty();
      }
      effectiveUserId = me.id;
      dev.log(
        '[ProfilController] loadFullProfile - userId résolu depuis /users/me: $effectiveUserId',
      );
    }

    // ── Lance les 3 requêtes en parallèle ────────────────────────────────────
    dev.log(
      '[ProfilController] loadFullProfile - Dispatching parallel requests for stats, applications, and reviews...',
    );
    final results = await Future.wait([
      _service.getFreelancerStats(effectiveUserId), // [0] stats chiffrées
      _service.getMyApplications(), // [1] candidatures
      _service.getReviewsForFreelancer(effectiveUserId), // [2] avis reçus
    ]);

    final statsResponse = results[0];
    final applicationsResponse = results[1];
    final reviewsResponse = results[2];

    // ── Décode les résultats (tolère les erreurs partielles) ─────────────────
    Map<String, dynamic> statsJson = {};
    if (statsResponse.isSuccess && statsResponse.data != null) {
      statsJson = statsResponse.data! as Map<String, dynamic>;
      dev.log('[ProfilController] stats OK: $statsJson');
    } else {
      dev.log('[ProfilController] stats FAILED: ${statsResponse.message}');
    }

    List<ApplicationModel> applications = [];
    if (applicationsResponse.isSuccess && applicationsResponse.data != null) {
      applications = applicationsResponse.data! as List<ApplicationModel>;
      dev.log(
        '[ProfilController] candidatures OK: count=${applications.length}',
      );
      for (var app in applications) {
        dev.log(
          '[ProfilController] - Candidature: ID=${app.id}, TaskID=${app.taskId}, Budget=${app.proposedBudget}, Status=${app.status}',
        );
      }
    } else {
      dev.log(
        '[ProfilController] candidatures FAILED: ${applicationsResponse.message}',
      );
    }

    List<ReviewModel> reviews = [];
    if (reviewsResponse.isSuccess && reviewsResponse.data != null) {
      reviews = reviewsResponse.data! as List<ReviewModel>;
      dev.log('[ProfilController] avis OK: count=${reviews.length}');
      for (var rev in reviews) {
        dev.log(
          '[ProfilController] - Avis: ID=${rev.id}, TaskID=${rev.taskId}, Rating=${rev.rating}, Comment="${rev.comment}"',
        );
      }
    } else {
      dev.log('[ProfilController] avis FAILED: ${reviewsResponse.message}');
    }

    // ── Construit et retourne le modèle agrégé ────────────────────────────────
    _stats = FreelanceStatsModel.fromStatsJson(
      statsJson,
      applications: applications,
      reviews: reviews,
    );
    
    _setLoading(false);
    dev.log(
      '[ProfilController] loadFullProfile SUCCESS - Merged FreelanceStatsModel: completed=${_stats.tasksDone}, inProgress=${_stats.tasksInProgress}, rating=${_stats.averageRating}',
    );
    return _stats;
  }
}
