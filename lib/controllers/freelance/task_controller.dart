import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../models/client/task_model.dart';
import '../../models/freelance/application_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';

class FreelanceTaskController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<TaskModel> _homeTasks = [];
  List<TaskModel> _appliedTasks = [];
  List<TaskModel> _completedTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get homeTasks => _homeTasks;
  List<TaskModel> get appliedTasks => _appliedTasks;
  List<TaskModel> get completedTasks => _completedTasks;
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

  Future<void> fetchHomeTasks() async {
    dev.log('[FreelanceTaskController] fetchHomeTasks() started');
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      _homeTasks = [
        TaskModel(id: 10, title: 'UI/UX Design - Fintech', description: 'Design complet d\'une interface bancaire.', budget: 450000, status: TaskStatus.pending, clientId: 1),
        TaskModel(id: 11, title: 'Maintenance Serveur Linux', description: 'Optimisation et sécurisation.', budget: 200000, status: TaskStatus.pending, clientId: 1),
      ];
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<List<TaskModel>>(
      endpoint: ApiEndpoints.freelanceTasks,
      parser: (json) {
        dev.log(
          '[FreelanceTaskController] fetchHomeTasks - Parsing Raw JSON: $json',
        );
        if (json is List) {
          final tasks = json.map((item) {
            dev.log(
              '[FreelanceTaskController] fetchHomeTasks - Processing Raw Item: $item',
            );
            final model = TaskModel.fromJson(item as Map<String, dynamic>);
            dev.log(
              '[FreelanceTaskController] fetchHomeTasks - Parsed TaskModel: ID=${model.id}, Title="${model.title}", Budget=${model.budget}, Status=${model.status}',
            );
            return model;
          }).toList();
          return tasks;
        }
        dev.log(
          '[FreelanceTaskController] fetchHomeTasks - Warning: JSON is not a List!',
        );
        return <TaskModel>[];
      },
    );

    _setLoading(false);

    dev.log(
      '[FreelanceTaskController] fetchHomeTasks response: success=${response.isSuccess} / message=${response.message} / count=${response.data?.length ?? 0}',
    );

    if (response.isSuccess && response.data != null) {
      _homeTasks = response.data!;
      dev.log(
        '[FreelanceTaskController] fetchHomeTasks - Injected ${_homeTasks.length} tasks into state.',
      );
      notifyListeners();
    } else {
      dev.log(
        '[FreelanceTaskController] fetchHomeTasks - Failed: ${response.message}',
      );
      _setError(response.message ?? 'Impossible de charger les missions');
    }
  }

  Future<void> fetchAppliedTasks() async {
    dev.log('[FreelanceTaskController] fetchAppliedTasks() started');
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.get<List<TaskModel>>(
      endpoint: ApiEndpoints.freelanceMyApplications,
      parser: (json) {
        dev.log(
          '[FreelanceTaskController] fetchAppliedTasks - Parsing Raw JSON: $json',
        );
        if (json is List) {
          final tasks = json.map((item) {
            dev.log(
              '[FreelanceTaskController] fetchAppliedTasks - Processing Raw Item: $item',
            );
            final appModel = ApplicationModel.fromJson(
              item as Map<String, dynamic>,
            );
            final model = _mapApplicationToTask(appModel);
            dev.log(
              '[FreelanceTaskController] fetchAppliedTasks - Parsed TaskModel: ID=${model.id}, Title="${model.title}", Budget=${model.budget}, Status=${model.status}',
            );
            return model;
          }).toList();
          return tasks;
        }
        dev.log(
          '[FreelanceTaskController] fetchAppliedTasks - Warning: JSON is not a List!',
        );
        return <TaskModel>[];
      },
    );

    _setLoading(false);

    dev.log(
      '[FreelanceTaskController] fetchAppliedTasks response: success=${response.isSuccess} / message=${response.message} / count=${response.data?.length ?? 0}',
    );

    if (response.isSuccess && response.data != null) {
      _appliedTasks = response.data!;
      dev.log(
        '[FreelanceTaskController] fetchAppliedTasks - Injected ${_appliedTasks.length} applied tasks into state.',
      );
      notifyListeners();
    } else {
      dev.log(
        '[FreelanceTaskController] fetchAppliedTasks - Failed: ${response.message}',
      );
      _setError(response.message ?? 'Impossible de charger vos candidatures');
    }
  }

  Future<void> fetchCompletedTasks() async {
    dev.log('[FreelanceTaskController] fetchCompletedTasks() started');
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.get<List<TaskModel>>(
      endpoint: '${ApiEndpoints.freelanceApplications}?status=accepted',
      parser: (json) {
        dev.log(
          '[FreelanceTaskController] fetchCompletedTasks - Parsing Raw JSON: $json',
        );
        if (json is List) {
          final tasks = json.map((item) {
            dev.log(
              '[FreelanceTaskController] fetchCompletedTasks - Processing Raw Item: $item',
            );
            final appModel = ApplicationModel.fromJson(
              item as Map<String, dynamic>,
            );
            final model = _mapApplicationToTask(appModel);
            dev.log(
              '[FreelanceTaskController] fetchCompletedTasks - Parsed TaskModel: ID=${model.id}, Title="${model.title}", Budget=${model.budget}, Status=${model.status}',
            );
            return model;
          }).toList();
          return tasks;
        }
        dev.log(
          '[FreelanceTaskController] fetchCompletedTasks - Warning: JSON is not a List!',
        );
        return <TaskModel>[];
      },
    );

    _setLoading(false);

    dev.log(
      '[FreelanceTaskController] fetchCompletedTasks response: success=${response.isSuccess} / message=${response.message} / count=${response.data?.length ?? 0}',
    );

    if (response.isSuccess && response.data != null) {
      _completedTasks = response.data!;
      dev.log(
        '[FreelanceTaskController] fetchCompletedTasks - Injected ${_completedTasks.length} completed tasks into state.',
      );
      notifyListeners();
    } else {
      dev.log(
        '[FreelanceTaskController] fetchCompletedTasks - Failed: ${response.message}',
      );
      _setError(
        response.message ?? 'Impossible de charger les missions terminées',
      );
    }
  }

  TaskModel _mapApplicationToTask(ApplicationModel app) {
    return TaskModel(
      id: app.taskId,
      title: app.taskTitle ?? 'Mission #${app.taskId}',
      description: app.taskDescription ?? app.coverLetter,
      budget: app.proposedBudget,
      status: app.status == ApplicationStatus.accepted
          ? TaskStatus.executed
          : TaskStatus.pending,
      clientId: app.clientId ?? 0,
      createdAt: app.createdAt,
    );
  }
}
