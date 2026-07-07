class ApiEndpoints {
  // Base API configuration.
  // - For Android Emulator: use default '10.0.2.2:8000'
  // - For iOS Simulator / Web / Linux: use 'localhost:8000'
  // - For physical devices: use your computer's local IP address (e.g. '192.168.1.50:8000')
  //
  // You can set this when launching the app:
  // flutter run --dart-define=BACKEND_HOST=192.168.1.50:8000
  static const String backendHost = String.fromEnvironment(
    'BACKEND_HOST',
    defaultValue: 'localhost:8000',
  );

  static const String baseUrl = 'http://$backendHost/api/v1';

  // Auth endpoints
  static const String login = '$baseUrl/login/access-token';
  static const String sendOtp = '$baseUrl/send-otp';
  static const String verifyOtp = '$baseUrl/verify-otp';

  // User endpoints
  // Backend n'a pas de /users/me, on utilise /users/{id} et /users/{id}/profile
  static const String usersBase = '$baseUrl/users';
  static String userById(int userId) => '$usersBase/$userId';
  static String userProfile(int userId) => '$usersBase/$userId/profile';
  static const String register = '$baseUrl/users/'; // POST /users/

  // Tasks/Missions endpoints
  static const String tasks = '$baseUrl/tasks/';
  static const String myTasks = '$baseUrl/tasks/my-tasks';
  static String taskDetail(int taskId) => '$baseUrl/tasks/$taskId';

  // Applications endpoints
  static const String applications = '$baseUrl/applications/';
  static String applicationsByTask(int taskId) => '$baseUrl/applications/task/$taskId';
  static const String myApplications = '$baseUrl/applications/my-applications';

  // Freelancer statistics
  static String freelancerStats(int userId) => '$baseUrl/statistics/freelancer/$userId';

  // Notifications
  static const String notifications = '$baseUrl/notifications/';

  // Admin endpoints
  static const String adminTasks = '$baseUrl/admin/tasks';
  static String adminTaskUpdate(int taskId) => '$baseUrl/admin/tasks/$taskId';

  // Dashboard
  static const String dashboardStats = '$baseUrl/dashboard/stats';

  // Messages
  static const String messages = '$baseUrl/messages/';
  static String conversation(int otherUserId) => '$baseUrl/messages/$otherUserId';

  // Reviews
  static const String reviews = '$baseUrl/reviews/';

  // Statistics
  static const String statistics = '$baseUrl/statistics/';
}
