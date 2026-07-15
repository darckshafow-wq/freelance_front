class ApiEndpoints {
  static const String backendHost = String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: '10.187.97.48:8000',
  );

  static const String baseUrl = 'http://$backendHost/api/v1';

  // --- AUTH ---
  static const String login = '$baseUrl/login/access-token';
  static const String register = '$baseUrl/users/';
  static const String sendOtp = '$baseUrl/send-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';
  static const String me = '$baseUrl/users/me';
  static String userById(int userId) => '$baseUrl/users/$userId';

  // --- CLIENT ---
  static const String clientTasks = '$baseUrl/tasks/';
  static const String clientMyTasks = '$baseUrl/tasks/my-tasks';
  static String clientTaskDetail(int taskId) => '$baseUrl/tasks/$taskId';
  static String clientApplicationsByTask(int taskId) =>
      '$baseUrl/applications/task/$taskId';

  // --- FREELANCE ---
  static const String freelanceTasks = '$baseUrl/tasks/'; // Public feed
  static const String freelanceApplications = '$baseUrl/applications/';
  static const String freelanceMyApplications =
      '$baseUrl/applications/my-applications';
  static String freelanceStats(int userId) =>
      '$baseUrl/statistics/freelancer/$userId';

  // --- SHARED / NOTIFICATIONS ---
  static const String notifications = '$baseUrl/notifications';
  static String notificationRead(int id) => '$baseUrl/notifications/$id/read';
  static const String reviews = '$baseUrl/reviews/';
  static String reviewsByFreelancer(int freelancerId) =>
      '$baseUrl/reviews/?reviewee_id=$freelancerId';
  static const String messages = '$baseUrl/messages/';
  static String conversation(int otherUserId) =>
      '$baseUrl/messages/$otherUserId';

  // --- ADMIN ---
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminTasks = '$baseUrl/admin/tasks';
  static String adminUserStatus(int userId) =>
      '$baseUrl/admin/users/$userId/status';
  static const String adminStats = '$baseUrl/dashboard/stats';

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
