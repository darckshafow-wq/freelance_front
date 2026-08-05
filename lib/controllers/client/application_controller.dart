import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../models/client/task_model.dart';
import '../../models/freelance/application_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';

class ClientApplicationController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<ApplicationModel> _applications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ApplicationModel> get applications => _applications;
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

  Future<void> fetchApplications() async {
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 700));
      _applications = [
        ApplicationModel(id: 10, freelancerId: 99, taskId: 1, taskTitle: 'Création de Logo Premium', proposedBudget: 140000, coverLetter: 'Expert en branding, j\'ai hâte de travailler sur ce projet.', status: ApplicationStatus.interview, createdAt: DateTime.now()),
      ];
      _setLoading(false);
      return;
    }

    try {
      final tasksResponse = await _apiClient.get<List<TaskModel>>(
        endpoint: ApiEndpoints.clientTasks,
        parser: (json) {
          final list = json as List<dynamic>;
          return list
              .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );

      if (!tasksResponse.isSuccess || tasksResponse.data == null) {
        _setError(
          tasksResponse.message ?? 'Impossible de charger les missions',
        );
        _setLoading(false);
        return;
      }

      final tasks = tasksResponse.data!;
      final List<ApplicationModel> applications = [];

      for (final task in tasks) {
        final response = await _apiClient.get<List<ApplicationModel>>(
          endpoint: ApiEndpoints.clientApplicationsByTask(task.id),
          parser: (json) {
            final list = json as List<dynamic>;
            return list
                .map(
                  (item) =>
                      ApplicationModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          },
        );

        if (response.isSuccess && response.data != null) {
          applications.addAll(response.data!);
        } else {
          dev.log(
            '[ClientApplicationController] Impossible de charger les candidatures pour la mission ${task.id}: ${response.message}',
          );
        }
      }

      _applications = applications;
      _setLoading(false);
    } catch (error) {
      dev.log('[ClientApplicationController] Erreur: $error');
      _setError('Erreur lors du chargement des candidatures.');
      _setLoading(false);
    }
  }

  Future<bool> acceptApplication(int applicationId) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.clientApplicationAccept(applicationId),
      body: {},
      parser: (json) => json as Map<String, dynamic>,
    );

    _setLoading(false);

    if (response.isSuccess) {
      await fetchApplications();
      return true;
    }

    _setError(response.message ?? 'Impossible d\'accepter la candidature');
    return false;
  }

  Future<bool> rejectApplication(int applicationId) async {
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.post<Map<String, dynamic>>(
      endpoint: ApiEndpoints.clientApplicationReject(applicationId),
      body: {},
      parser: (json) => json as Map<String, dynamic>,
    );

    _setLoading(false);

    if (response.isSuccess) {
      await fetchApplications();
      return true;
    }

    _setError(response.message ?? 'Impossible de refuser la candidature');
    return false;
  }
}
