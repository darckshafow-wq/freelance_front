import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiEndpoints {
  static String _resolvedBackendHost = '';
  static bool _backendHostResolved = false;

  static String get _fallbackBackendHost {
    const envHost = String.fromEnvironment('BACKEND_HOST', defaultValue: '');
    if (envHost.isNotEmpty) {
      return envHost;
    }

    const webHost = String.fromEnvironment(
      'BACKEND_HOST_WEB',
      defaultValue: '',
    );
    if (kIsWeb && webHost.isNotEmpty) {
      return webHost;
    }

    const androidHost = String.fromEnvironment(
      'BACKEND_HOST_ANDROID',
      defaultValue: '',
    );
    if (!kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android &&
        androidHost.isNotEmpty) {
      return androidHost;
    }

    if (kIsWeb) {
      const webHost = String.fromEnvironment(
        'BACKEND_HOST_WEB',
        defaultValue: '',
      );
      if (webHost.isNotEmpty) {
        return webHost;
      }
      return 'localhost:8000';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2:8000';
    }

    return 'localhost:8000';
  }

  static String get backendHost {
    if (_backendHostResolved && _resolvedBackendHost.isNotEmpty) {
      return _resolvedBackendHost;
    }
    return _fallbackBackendHost;
  }

  static String buildBaseUrl({bool? isWeb}) {
    final useWebRelative = isWeb ?? kIsWeb;
    if (useWebRelative) {
      final baseUri = Uri.base;
      if (baseUri.hasScheme && baseUri.host.isNotEmpty) {
        // Keep the SAME port as the page (8080 = cors_proxy.py).
        // The proxy forwards /api/v1/* to the backend — that's how CORS is handled.
        // IMPORTANT: build from scratch to avoid Uri.replace() preserving
        // Flutter's hash-router fragment (e.g. #/login) which corrupts API URLs.
        return Uri(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.port, // 8080 → proxy, NOT 8000 (direct backend)
          path: '/api/v1',
        ).toString();
      }
      return 'http://localhost:8080/api/v1';
    }
    return 'http://$backendHost/api/v1';
  }

  static String get baseUrl => buildBaseUrl();

  // --- AUTH / GLOBAL ---
  static String get login => '$baseUrl/login/access-token';
  static String get register => '$baseUrl/users/';
  static String get sendOtp => '$baseUrl/send-otp';
  static String get verifyOtp => '$baseUrl/verify-otp';
  static String get me => '$baseUrl/users/me';
  static String get meProfile => '$baseUrl/users/me/profile';
  static String userById(int userId) => '$baseUrl/users/$userId';
  static String userProfileById(int userId) => '$baseUrl/users/$userId/profile';
  static String get userReviews => '$baseUrl/users/reviews/';
  static String ws(String clientId) {
    if (kIsWeb) {
      // WebSocket must bypass the HTTP proxy (cors_proxy.py) because it cannot
      // handle the WS upgrade handshake → 502. Connect directly to the backend.
      // WebSocket is not blocked by CORS the same way as HTTP fetch.
      return 'ws://${Uri.base.host}:8000/ws/$clientId';
    }
    return 'ws://$backendHost/ws/$clientId';
  }

  // --- CLIENT ---
  static String get clientTasks => '$baseUrl/client/tasks';
  static String get clientMyTasks => '$baseUrl/client/tasks';
  static String clientTaskDetail(int taskId) => '$baseUrl/client/tasks/$taskId';
  static String clientApplicationsByTask(int taskId) =>
      '$baseUrl/client/tasks/$taskId/applications';
  static String clientApplicationAccept(int id) =>
      '$baseUrl/client/applications/$id/accept';
  static String clientApplicationReject(int id) =>
      '$baseUrl/client/applications/$id/reject';
  static String get clientFeedback => '$baseUrl/client/feedback';

  static String get clientNotifications => '$baseUrl/client/notifications';
  static String clientNotificationRead(int id) =>
      '$baseUrl/client/notifications/$id/read';
  static String clientNotificationDelete(int id) =>
      '$baseUrl/client/notifications/$id';

  static String get clientReviews => '$baseUrl/client/reviews';
  static String get clientConversations => '$baseUrl/messages/';
  static String clientMessages(int otherUserId) =>
      '$baseUrl/messages/$otherUserId';

  static String get clientMessagesPost => '$baseUrl/messages/';

  // --- FREELANCE ---
  static String get freelanceTasks => '$baseUrl/freelance/tasks';
  static String get freelanceApply => '$baseUrl/freelance/apply';
  static String get freelanceApplications => '$baseUrl/freelance/applications';
  static String get freelanceMyApplications =>
      '$baseUrl/freelance/applications';
  static String get freelanceConversations => '$baseUrl/messages/';
  static String freelanceMessages(int otherUserId) =>
      '$baseUrl/messages/$otherUserId';

  static String get freelanceMessagesPost => '$baseUrl/messages/';
  static String get freelanceStats => '$baseUrl/freelance/stats';

  static String get freelanceNotifications =>
      '$baseUrl/freelance/notifications';
  static String freelanceNotificationRead(int id) =>
      '$baseUrl/freelance/notifications/$id/read';
  static String freelanceNotificationDelete(int id) =>
      '$baseUrl/freelance/notifications/$id';

  static String get freelanceReviews => '$baseUrl/freelance/reviews';
  static String get freelanceFeedback => '$baseUrl/freelance/feedback';

  // --- ADMIN ---
  static String get adminStats => '$baseUrl/admin/dashboard/stats';
  static String get adminAudit => '$baseUrl/admin/audit';
  static String get adminTasks => '$baseUrl/admin/tasks';
  static String adminTaskUpdate(int id) => '$baseUrl/admin/tasks/$id';
  static String get adminUsers => '$baseUrl/admin/users';
  static String adminUserDelete(int id) => '$baseUrl/admin/users/$id';

  static String get adminReviews => '$baseUrl/admin/reviews';
  static String get adminNotifications => '$baseUrl/admin/notifications';
  static String get adminNotificationsBroadcast =>
      '$baseUrl/admin/notifications/broadcast';
  static String get adminFeedback => '$baseUrl/admin/feedbacks';
  static String adminReplyFeedback(int id) =>
      '$baseUrl/admin/feedbacks/$id/reply';
  static String adminDetailFeedback(int id) => '$baseUrl/admin/feedbacks/$id';
  static String adminNotificationRead(int id) =>
      '$baseUrl/admin/notifications/$id/read';
  static String adminNotificationDelete(int id) =>
      '$baseUrl/admin/notifications/$id';

  static String adminUserStatus(int userId) =>
      '$baseUrl/admin/users/$userId/status';
  static String adminVerifyUser(int userId) =>
      '$baseUrl/admin/users/$userId/verify';

  // --- UTILITIES FOR TESTING / DYNAMIC HOSTS ---
  static List<String> candidateBaseUrls({String? platform}) {
    if (platform == 'android') {
      return [
        'http://localhost:8000/api/v1',
        'http://10.0.2.2:8000/api/v1',
        'http://127.0.0.1:8000/api/v1',
      ];
    }
    return ['http://localhost:8000/api/v1', 'http://127.0.0.1:8000/api/v1'];
  }

  static Future<String> resolveBackendHost({
    Future<bool> Function(String url)? probeHost,
  }) async {
    if (_backendHostResolved && _resolvedBackendHost.isNotEmpty) {
      return _resolvedBackendHost;
    }

    // On web, the host is derived directly from Uri.base in buildBaseUrl().
    // Probing localhost/127.0.0.1 from a network IP origin (e.g. 192.168.1.80)
    // always fails with CORS errors — skip it entirely.
    if (kIsWeb) {
      final host = '${Uri.base.host}:8000';
      _resolvedBackendHost = host;
      _backendHostResolved = true;
      return host;
    }

    final candidates = <String>{
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
        '10.0.2.2:8000',
      'localhost:8000',
      '127.0.0.1:8000',
    }.toList();

    for (final candidate in candidates) {
      final probeUrl = 'http://$candidate/api/v1';
      final isReachable =
          await (probeHost?.call(probeUrl) ?? _probeHost(probeUrl));
      if (isReachable) {
        _resolvedBackendHost = candidate;
        _backendHostResolved = true;
        return candidate;
      }
    }

    _resolvedBackendHost = _fallbackBackendHost;
    _backendHostResolved = true;
    return _resolvedBackendHost;
  }

  static Future<bool> _probeHost(String url) async {
    try {
      final response = await http
          .get(Uri.parse('$url/docs'))
          .timeout(const Duration(seconds: 2));
      return response.statusCode < 500;
    } catch (e) {
      dev.log('Backend probe failed for $url: $e');
      return false;
    }
  }

  static String resolveEndpoint(String relativePath) {
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseUrl/$cleanPath';
  }
}
