import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/controllers/freelance/profil_controller.dart';
import 'package:freelance_front/models/auth/user_model.dart';
import 'package:freelance_front/models/freelance/application_model.dart';
import 'package:freelance_front/models/shared/review_model.dart';

void main() {
  group('Backend profile payload parsing', () {
    test('parses user profile payload using backend field names', () {
      final user = UserModel.fromJson({
        'id': 7,
        'email': 'freelance@example.com',
        'full_name': 'Awa Ndiaye',
        'location': 'Dakar',
        'is_freelancer': true,
      });

      expect(user.id, 7);
      expect(user.fullName, 'Awa Ndiaye');
      expect(user.email, 'freelance@example.com');
    });

    test('parses application payload using backend field names', () {
      final app = ApplicationModel.fromJson({
        'id': 11,
        'task_id': 22,
        'freelance_id': 7,
        'message': 'Je peux faire ce travail.',
        'status': 'accepted',
      });

      expect(app.id, 11);
      expect(app.taskId, 22);
      expect(app.freelancerId, 7);
      expect(app.coverLetter, 'Je peux faire ce travail.');
      expect(app.status, ApplicationStatus.accepted);
    });

    test('parses review payload using backend field names', () {
      final review = ReviewModel.fromJson({
        'id': 3,
        'task_id': 22,
        'reviewer_id': 1,
        'reviewee_id': 7,
        'rating': 4.5,
        'comment': 'Très bon travail',
        'created_at': '2026-07-10T10:00:00Z',
      });

      expect(review.id, 3);
      expect(review.rating, 4.5);
      expect(review.comment, 'Très bon travail');
      expect(review.revieweeId, 7);
    });

    test('resolves profile user ids without sending invalid values', () {
      expect(ProfilController.resolveUserId('me', currentUserId: 7), 7);
      expect(ProfilController.resolveUserId('0'), isNull);
      expect(ProfilController.resolveUserId('42'), 42);
    });
  });
}
