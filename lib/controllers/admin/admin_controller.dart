import 'package:flutter/material.dart';
import '../../models/admin/admin_stats_model.dart';
import '../../models/admin/audit_log_model.dart';
import '../../models/auth/user_model.dart';
import '../../models/client/task_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';

class AdminController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  AdminStatsModel? _stats;
  List<UserModel> _users = [];
  List<TaskModel> _tasks = [];
  AuditLogResponse? _auditLogs;

  bool _isLoading = false;
  String? _errorMessage;

  AdminStatsModel? get stats => _stats;
  List<UserModel> get users => _users;
  List<TaskModel> get tasks => _tasks;
  AuditLogResponse? get auditLogs => _auditLogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // --- STATS ---
  Future<void> fetchDashboardStats() async {
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      _stats = _getMockStats();
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<AdminStatsModel>(
      endpoint: ApiEndpoints.adminStats,
      parser: (json) => AdminStatsModel.fromJson(json as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      _stats = response.data;
    } else {
      _stats = _getMockStats();
    }
    _setLoading(false);
  }

  // --- USERS ---
  Future<void> fetchUsers() async {
    _setLoading(true);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      _users = [
        UserModel(id: 1, email: 'admin@test.com', fullName: 'Admin User', role: UserRole.admin),
        UserModel(id: 2, email: 'client@test.com', fullName: 'Client User', role: UserRole.client),
        UserModel(id: 3, email: 'freelance@test.com', fullName: 'Freelance User', role: UserRole.freelancer),
      ];
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<List<UserModel>>(
      endpoint: ApiEndpoints.adminUsers,
      parser: (json) =>
          (json as List).map((e) => UserModel.fromJson(e)).toList(),
    );

    if (response.isSuccess && response.data != null) {
      _users = response.data!;
    }
    _setLoading(false);
  }

  Future<bool> deleteUser(int userId) async {
    _setLoading(true);
    final response = await _apiClient.delete(
      endpoint: ApiEndpoints.adminUserDelete(userId),
      parser: (json) => json,
    );
    _setLoading(false);
    if (response.isSuccess) {
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> verifyUser(int userId) async {
    _setLoading(true);
    final response = await _apiClient.put<Map<String, dynamic>>(
      endpoint: ApiEndpoints.adminVerifyUser(userId),
      body: {},
      parser: (json) => json as Map<String, dynamic>,
    );
    _setLoading(false);

    if (response.isSuccess) {
      final idx = _users.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        _users[idx] = UserModel(
          id: _users[idx].id,
          email: _users[idx].email,
          fullName: _users[idx].fullName,
          role: _users[idx].role,
          phoneNumber: _users[idx].phoneNumber,
          location: _users[idx].location,
          createdAt: _users[idx].createdAt,
          isActive: _users[idx].isActive,
          isClient: _users[idx].isClient,
          isFreelancer: _users[idx].isFreelancer,
          isAdmin: _users[idx].isAdmin,
          isVerified: true,
        );
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  Future<void> fetchAuditLogs() async {
    _setLoading(true);
    final response = await _apiClient.get<AuditLogResponse>(
      endpoint: ApiEndpoints.adminAudit,
      parser: (json) => AuditLogResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.isSuccess && response.data != null) {
      _auditLogs = response.data;
    } else {
      _auditLogs = AuditLogResponse(
        aggregatedByRole: {'admin': 0, 'client': 0},
        recent: const [],
      );
    }
    _setLoading(false);
  }

  // --- TASKS ---
  Future<void> fetchTasks() async {
    _setLoading(true);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      _tasks = [
        TaskModel(id: 1, title: 'Mock Task 1', description: 'Desc 1', budget: 100, status: TaskStatus.pending, clientId: 1),
        TaskModel(id: 2, title: 'Mock Task 2', description: 'Desc 2', budget: 200, status: TaskStatus.validated, clientId: 1),
      ];
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<List<TaskModel>>(
      endpoint: ApiEndpoints.adminTasks,
      parser: (json) =>
          (json as List).map((e) => TaskModel.fromJson(e)).toList(),
    );

    if (response.isSuccess && response.data != null) {
      _tasks = response.data!;
    }
    _setLoading(false);
  }

  Future<bool> updateTaskStatus(int taskId, String status) async {
    _setLoading(true);
    final response = await _apiClient.put<TaskModel>(
      endpoint: ApiEndpoints.adminTaskUpdate(taskId),
      body: {'status': status},
      parser: (json) => TaskModel.fromJson(json as Map<String, dynamic>),
    );
    _setLoading(false);
    if (response.isSuccess && response.data != null) {
      final idx = _tasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) _tasks[idx] = response.data!;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> broadcastNotification(
    String title,
    String content,
    String targetRole,
  ) async {
    _setLoading(true);
    final encodedTitle = Uri.encodeComponent(title);
    final encodedContent = Uri.encodeComponent(content);
    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint:
          '${ApiEndpoints.adminNotificationsBroadcast}?title=$encodedTitle&content=$encodedContent&target_role=$targetRole',
      body: {}, // Body is empty as args are in query
      parser: (json) => json as Map<String, dynamic>,
    );
    _setLoading(false);
    return response.isSuccess;
  }

  void logout() {
    ApiClient.clearToken();
    _stats = null;
    _users = [];
    _tasks = [];
    _auditLogs = null;
    notifyListeners();
  }

  AdminStatsModel _getMockStats() {
    return AdminStatsModel(
      users: UsersStats(
        total: 1240,
        freelancers: 800,
        clients: 400,
        admins: 40,
      ),
      tasks: TasksStats(
        total: 856,
        pending: 120,
        validated: 700,
        appliedTo: 600,
      ),
      applications: ApplicationsStats(total: 2500, pending: 350),
      messages: MessagesStats(total: 15400),
      percentages: PercentagesStats(
        siteActivity: 85.5,
        registration: RegistrationPercentages(freelancers: 64.5, clients: 32.2),
        tasks: TasksPercentages(validated: 81.7, applied: 70.1),
      ),
      activityHistory: [
        MonthlyActivity(name: 'Jan', tasks: 45, users: 12),
        MonthlyActivity(name: 'Fév', tasks: 52, users: 15),
        MonthlyActivity(name: 'Mar', tasks: 48, users: 18),
        MonthlyActivity(name: 'Avr', tasks: 70, users: 25),
        MonthlyActivity(name: 'Mai', tasks: 65, users: 22),
        MonthlyActivity(name: 'Juin', tasks: 85, users: 30),
      ],
    );
  }
}
