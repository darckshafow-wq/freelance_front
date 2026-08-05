import 'dart:developer' as dev;
import '../api_core.dart';
import '../api_endpoints.dart';
import '../api_response.dart';
import '../../../models/shared/feedback_model.dart';
import '../../../models/auth/user_model.dart';

class FeedbackApiService {
  final ApiClient _client = ApiClient();

  /// Soumettre un feedback (Freelance ou Client)
  Future<ApiResponse<FeedbackModel>> submitFeedback({
    required UserRole role,
    required String content,
    required FeedbackCategory category,
  }) async {
    final endpoint = role == UserRole.freelancer
        ? ApiEndpoints.freelanceFeedback
        : ApiEndpoints.clientFeedback;

    dev.log('[FeedbackApiService] submitFeedback (role: $role)');

    final payload = FeedbackModel.toCreateJson(
      content: content,
      category: category,
    );

    // Match the backend schema exactly:
    // {"content": "...", "category": "GENERAL"}

    dev.log('[FeedbackApiService] submitFeedback payload: $payload');

    return _client.post<FeedbackModel>(
      endpoint: endpoint,
      body: payload,
      parser: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Lister les feedbacks envoyés (Freelance ou Client)
  Future<ApiResponse<List<FeedbackModel>>> getMyFeedbacks(UserRole role) async {
    final endpoint = role == UserRole.freelancer
        ? ApiEndpoints.freelanceFeedback
        : ApiEndpoints.clientFeedback;

    dev.log('[FeedbackApiService] getMyFeedbacks (role: $role)');

    return _client.get<List<FeedbackModel>>(
      endpoint: endpoint,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => FeedbackModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// (Admin) Lister tous les feedbacks, filtre optionnel
  Future<ApiResponse<List<FeedbackModel>>> getAllFeedbacks({
    String? status,
  }) async {
    dev.log('[FeedbackApiService] getAllFeedbacks (admin)');

    String endpoint = ApiEndpoints.adminFeedback;
    if (status != null) {
      endpoint += '?status=$status';
    }

    return _client.get<List<FeedbackModel>>(
      endpoint: endpoint,
      parser: (json) {
        final list = json as List<dynamic>;
        return list
            .map((item) => FeedbackModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// (Admin) Récupérer le détail d'un feedback
  Future<ApiResponse<FeedbackModel>> getFeedbackDetail(int feedbackId) async {
    dev.log('[FeedbackApiService] getFeedbackDetail (admin, id: $feedbackId)');
    return _client.get<FeedbackModel>(
      endpoint: ApiEndpoints.adminDetailFeedback(feedbackId),
      parser: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// (Admin) Répondre à un feedback
  Future<ApiResponse<FeedbackModel>> replyToFeedback({
    required int feedbackId,
    required String adminReply,
    required FeedbackStatus status,
  }) async {
    dev.log('[FeedbackApiService] replyToFeedback (admin, id: $feedbackId)');

    return _client.put<FeedbackModel>(
      endpoint: ApiEndpoints.adminReplyFeedback(feedbackId),
      body: {'admin_reply': adminReply, 'status': status.name.toLowerCase()},
      parser: (json) => FeedbackModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
