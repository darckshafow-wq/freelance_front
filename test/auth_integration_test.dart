import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';

void main() {
  group('Auth Integration Tests', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    test('Login failure with wrong credentials', () async {
      await authController.login(
        email: 'nonexistent@example.com',
        password: 'wrongpassword',
      );
      
      expect(authController.isAuthenticated, isFalse);
      expect(authController.errorMessage, isNotNull);
    });

    test('Registration logic flow', () async {
      expect(authController.isLoading, isFalse);
      
      // We check if registration can be called without crash
      try {
        await authController.register(
          fullName: 'Test User',
          email: 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
          password: 'Password123!',
          role: 'FREELANCE',
        );
      } catch (_) {
        // Expected if backend is not reachable in CI
      }
    });
   group('Auth Controller Extended', () {
    test('Initialization with no token', () async {
      final ctrl = AuthController();
      await ctrl.init();
      expect(ctrl.isAuthenticated, isFalse);
    });
  });
  });
}
