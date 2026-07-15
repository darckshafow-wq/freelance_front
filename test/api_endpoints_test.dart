import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/services/api/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('candidate base urls include emulator and localhost fallbacks', () {
      final candidates = ApiEndpoints.candidateBaseUrls(platform: 'android');

      expect(candidates, contains('http://10.0.2.2:8000/api/v1'));
      expect(candidates, contains('http://127.0.0.1:8000/api/v1'));
      expect(candidates, contains('http://localhost:8000/api/v1'));
    });

    test('relative endpoints resolve to an absolute API URL', () {
      final resolved = ApiEndpoints.resolveEndpoint('/tasks/');

      expect(resolved.startsWith('http://'), isTrue);
      expect(resolved.contains('/api/v1/tasks/'), isTrue);
    });
  });
}
