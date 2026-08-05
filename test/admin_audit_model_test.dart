import 'package:flutter_test/flutter_test.dart';
import 'package:freelance_front/models/admin/audit_log_model.dart';
import 'package:freelance_front/services/api/api_endpoints.dart';

void main() {
  group('AuditLogResponse parsing', () {
    test('parses aggregated counts and recent entries', () {
      final response = AuditLogResponse.fromJson({
        'aggregated_by_role': {'admin': 12, 'client': 3},
        'recent': [
          {
            'user_id': 42,
            'path': '/api/v1/admin/users/42',
            'method': 'GET',
            'role': 'admin',
            'created_at': '2026-08-01T10:15:00Z',
          },
        ],
      });

      expect(response.aggregatedByRole['admin'], 12);
      expect(response.aggregatedByRole['client'], 3);
      expect(response.recent, hasLength(1));
      expect(response.recent.first.path, '/api/v1/admin/users/42');
      expect(response.recent.first.role, 'admin');
    });
  });

  group('Admin user verification endpoint', () {
    test('builds the verify endpoint for a given user', () {
      final endpoint = ApiEndpoints.adminVerifyUser(7);
      expect(endpoint, endsWith('/admin/users/7/verify'));
    });
  });
}
