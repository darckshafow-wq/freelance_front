import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freelance_front/services/api/api_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'persists and restores the auth token from shared preferences',
    () async {
      SharedPreferences.setMockInitialValues({});

      await ApiClient.clearToken();
      await ApiClient.setToken('persisted-token');

      final restoredToken = await ApiClient.getStoredToken();

      expect(restoredToken, 'persisted-token');
    },
  );
}
