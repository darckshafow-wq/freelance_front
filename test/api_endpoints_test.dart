import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/services/api/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('candidate base urls include emulator and localhost fallbacks', () {
      final candidates = ApiEndpoints.candidateBaseUrls(platform: 'android');

      expect(candidates.first, 'http://localhost:8000/api/v1');
      expect(candidates, contains('http://127.0.0.1:8000/api/v1'));
      expect(candidates, contains('http://localhost:8000/api/v1'));
    });

    test('relative endpoints resolve to an absolute API URL', () {
      final resolved = ApiEndpoints.resolveEndpoint('/tasks/');

      expect(resolved.startsWith('http://'), isTrue);
      expect(resolved.contains('/api/v1/tasks/'), isTrue);
    });

    test('web builds same-origin API URLs to work with the local proxy', () {
      final resolved = ApiEndpoints.buildBaseUrl(isWeb: true);

      expect(resolved.endsWith('/api/v1'), isTrue);
      expect(resolved.startsWith('http') || resolved.startsWith('/'), isTrue);
    });

    test('resolveBackendHost prefers a reachable candidate host', () async {
      final resolved = await ApiEndpoints.resolveBackendHost(
        probeHost: (String url) async => url.contains('10.0.2.2'),
      );

      expect(resolved, '10.0.2.2:8000');
    });

    test('profile endpoints use backend-specific profile routes', () {
      expect(ApiEndpoints.meProfile, endsWith('/users/me/profile'));
      expect(ApiEndpoints.userProfileById(42), endsWith('/users/42/profile'));
    });
  });
}
