import 'package:flutter/material.dart';
import '../../models/client/task_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';

class TaskController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TaskModel> get tasks => _tasks;
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

  // Fetch all tasks from backend
  Future<void> fetchTasks() async {
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 600));
      _tasks = [
        TaskModel(id: 1, title: 'Création de Logo Premium', description: 'Besoin d\'un logo moderne pour une startup tech.', budget: 150000, status: TaskStatus.pending, clientId: 1, createdAt: DateTime.now()),
        TaskModel(id: 2, title: 'Développement App Mobile', description: 'Application de livraison de repas avec Flutter.', budget: 850000, status: TaskStatus.validated, clientId: 1, createdAt: DateTime.now().subtract(const Duration(days: 2))),
        TaskModel(id: 3, title: 'Audit Sécurité Web', description: 'Vérification des vulnérabilités d\'un site e-commerce.', budget: 300000, status: TaskStatus.executed, clientId: 1, createdAt: DateTime.now().subtract(const Duration(days: 5))),
      ];
      _setLoading(false);
      return;
    }

    final response = await _apiClient.get<List<TaskModel>>(
      endpoint: ApiEndpoints.clientTasks,
      parser: (json) {
        if (json is List) {
          return json
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _tasks = response.data!;
    } else {
      _setError(
        response.message ?? 'Erreur lors de la récupération des tâches',
      );
    }
  }

  // Create a new task
  Future<bool> createTask({
    required String title,
    required String description,
    required double budget,
    String? location,
    DateTime? deadline,
  }) async {
    _setLoading(true);
    _setError(null);

    final body = <String, dynamic>{
      'title': title,
      'price': budget,
      if (description.isNotEmpty) 'description': description,
      if (location != null && location.trim().isNotEmpty)
        'location': location.trim(),
      // Le schéma OpenAPI TaskCreate n'inclut pas de champ deadline.
      // Ne pas envoyer deadline pour éviter les 422 liés à des champs inconnus.
    };

    final response = await _apiClient.post<TaskModel>(
      endpoint: ApiEndpoints.clientTasks,
      body: body,
      parser: (json) => TaskModel.fromJson(json as Map<String, dynamic>),
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _tasks.insert(0, response.data!); // Add new task to the top of the list
      notifyListeners();
      return true;
    } else {
      _setError(response.message ?? 'Impossible de créer la tâche');
      return false;
    }
  }

  // Update a task
  Future<bool> updateTask(int taskId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.put<TaskModel>(
      endpoint: ApiEndpoints.clientTaskDetail(taskId),
      body: updates,
      parser: (json) => TaskModel.fromJson(json as Map<String, dynamic>),
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = response.data!;
        notifyListeners();
      }
      return true;
    } else {
      _setError(response.message ?? 'Impossible de modifier la tâche');
      return false;
    }
  }

  // Delete a task
  Future<bool> deleteTask(int taskId) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.delete<Map<String, dynamic>>(
      endpoint: ApiEndpoints.clientTaskDetail(taskId),
      parser: (json) => json as Map<String, dynamic>,
    );

    _setLoading(false);

    if (response.isSuccess) {
      _tasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      return true;
    } else {
      _setError(response.message ?? 'Impossible de supprimer la tâche');
      return false;
    }
  }
}
