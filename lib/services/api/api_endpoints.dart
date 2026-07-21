class ApiEndpoints {
  static const String backendHost = String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: '10.187.97.48:8000',
  );

  static const String baseUrl = 'http://$backendHost/api/v1';

  // --- AUTH / GLOBAL ---
  static const String login = '$baseUrl/login/access-token';
  static const String register = '$baseUrl/users/';
  static const String sendOtp = '$baseUrl/send-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String me = '$baseUrl/users/me';
  static String userById(int userId) => '$baseUrl/users/$userId';
  static String ws(String clientId) => 'ws://$backendHost/ws/$clientId';

  // --- CLIENT ---
  static const String clientTasks = '$baseUrl/client/tasks';
  static const String clientMyTasks = '$baseUrl/client/tasks';
  static String clientTaskDetail(int taskId) => '$baseUrl/client/tasks/$taskId';
  static String clientApplicationsByTask(int taskId) =>
      '$baseUrl/client/tasks/$taskId/applications';
  static String clientApplicationAccept(int id) =>
      '$baseUrl/client/applications/$id/accept';
  static String clientApplicationReject(int id) =>
      '$baseUrl/client/applications/$id/reject';

  static const String clientNotifications = '$baseUrl/client/notifications';
  static String clientNotificationRead(int id) =>
      '$baseUrl/client/notifications/$id/read';
  static String clientNotificationDelete(int id) =>
      '$baseUrl/client/notifications/$id';

  static const String clientReviews = '$baseUrl/client/reviews';

  // --- FREELANCE ---
  static const String freelanceTasks = '$baseUrl/freelance/tasks';
  static const String freelanceApply = '$baseUrl/freelance/apply';
  static const String freelanceApplications = '$baseUrl/freelance/applications';
  static const String freelanceMyApplications =
      '$baseUrl/freelance/applications';
  static const String freelanceConversations =
      '$baseUrl/freelance/conversations';
  static String freelanceMessages(int otherUserId) =>
      '$baseUrl/freelance/messages/$otherUserId';
  static const String freelanceMessagesPost = '$baseUrl/freelance/messages';
  static const String freelanceStats = '$baseUrl/freelance/stats';

  static const String freelanceNotifications =
      '$baseUrl/freelance/notifications';
  static String freelanceNotificationRead(int id) =>
      '$baseUrl/freelance/notifications/$id/read';
  static String freelanceNotificationDelete(int id) =>
      '$baseUrl/freelance/notifications/$id';

  static const String freelanceReviews = '$baseUrl/freelance/reviews';

  // --- ADMIN ---
  static const String adminStats = '$baseUrl/admin/dashboard/stats';
  static const String adminTasks = '$baseUrl/admin/tasks';
  static String adminTaskUpdate(int id) => '$baseUrl/admin/tasks/$id';
  static const String adminUsers = '$baseUrl/admin/users';
  static String adminUserDelete(int id) => '$baseUrl/admin/users/$id';

  static const String adminReviews = '$baseUrl/admin/reviews';
  static const String adminNotifications = '$baseUrl/admin/notifications';
  static String adminNotificationRead(int id) =>
      '$baseUrl/admin/notifications/$id/read';
  static String adminNotificationDelete(int id) =>
      '$baseUrl/admin/notifications/$id';

  // --- LEGACY / SHARED (À remplacer progressivement par les routes par rôle) ---
  static const String notifications = '$baseUrl/notifications';
  static String notificationRead(int id) => '$baseUrl/notifications/$id/read';
  static String notificationDelete(int id) => '$baseUrl/notifications/$id';
  static const String reviews = '$baseUrl/reviews/';
  static String reviewsByFreelancer(int freelancerId) =>
      '$baseUrl/reviews/?reviewee_id=$freelancerId';
  static const String messages = '$baseUrl/messages/';
  static String chatHistory(int userId) => '$baseUrl/messages/$userId';
  static String adminUserStatus(int userId) =>
      '$baseUrl/admin/users/$userId/status';

  // --- UTILITIES FOR TESTING / DYNAMIC HOSTS ---
  static List<String> candidateBaseUrls({String? platform}) {
    if (platform == 'android') {
      return [
        'http://10.0.2.2:8000/api/v1',
        'http://127.0.0.1:8000/api/v1',
        'http://localhost:8000/api/v1',
      ];
    }
    return ['http://localhost:8000/api/v1', 'http://127.0.0.1:8000/api/v1'];
  }

  static String resolveEndpoint(String relativePath) {
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    return '$baseUrl/$cleanPath';
  }
}
