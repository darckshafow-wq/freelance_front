import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/controllers/shared/feedback_controller.dart';
import 'package:freelance_front/models/auth/user_model.dart';
import 'package:freelance_front/models/shared/feedback_model.dart';
import 'package:freelance_front/services/api/api_response.dart';
import 'package:freelance_front/services/api/shared/feedback_api_service.dart';

class FakeFeedbackApiService extends FeedbackApiService {
  final ApiResponse<FeedbackModel> response;

  FakeFeedbackApiService(this.response);

  @override
  Future<ApiResponse<FeedbackModel>> submitFeedback({
    required UserRole role,
    required String content,
    required FeedbackCategory category,
  }) async {
    return response;
  }
}

void main() {
  group('FeedbackController', () {
    test(
      'returns false and surfaces the backend message for invalid submissions',
      () async {
        final controller = FeedbackController(
          apiService: FakeFeedbackApiService(
            ApiResponse.error('Le backend a rejeté la requête'),
          ),
        );

        final result = await controller.submitFeedback(
          role: UserRole.client,
          content: '  ',
          category: FeedbackCategory.general,
        );

        expect(result, isFalse);
        expect(controller.error, 'Veuillez saisir un message');
      },
    );

    test('returns true and adds the feedback when the API succeeds', () async {
      final createdFeedback = FeedbackModel(
        id: 42,
        content: 'Bonjour',
        category: FeedbackCategory.general,
        status: FeedbackStatus.pending,
        createdAt: DateTime.now(),
        userId: 7,
      );

      final controller = FeedbackController(
        apiService: FakeFeedbackApiService(
          ApiResponse.success(createdFeedback),
        ),
      );

      final result = await controller.submitFeedback(
        role: UserRole.client,
        content: 'Bonjour',
        category: FeedbackCategory.general,
      );

      expect(result, isTrue);
      expect(controller.myFeedbacks, contains(createdFeedback));
    });
  });
}
