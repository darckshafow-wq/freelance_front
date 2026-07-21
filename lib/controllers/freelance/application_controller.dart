import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../models/freelance/application_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';
import '../shared/notification_controller.dart';

class ApplicationController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final NotificationController _notificationController =
      NotificationController();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Postuler à une mission (Reste un POST sur /api/v1/applications/)
  Future<bool> applyToTask({
    required int taskId,
    required double budget,
    String coverLetter = '',
  }) async {
    dev.log(
      '[ApplicationController] applyToTask(taskId: $taskId, budget: $budget) started',
    );
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.post<ApplicationModel>(
      endpoint: ApiEndpoints.freelanceApply, // -> /freelance/apply
      body: {
        'task_id': taskId,
        'proposed_budget': budget,
        'cover_letter': coverLetter,
      },
      parser: (json) {
        return ApplicationModel.fromJson(json as Map<String, dynamic>);
      },
    );

    _setLoading(false);

    if (response.isSuccess) {
      await _notificationController.fetchNotifications();
      return true;
    } else {
      _setError(response.message ?? 'Erreur lors de la candidature');
      return false;
    }
  }

  List<ApplicationModel> _applications = [];
  // Correction de la petite typo "post" -> "get"
  List<ApplicationModel> get applications => _applications;

  /// Charger mes candidatures (Fait un GET sur /api/v1/applications/my-applications)
  Future<void> fetchApplications() async {
    dev.log('[ApplicationController] fetchApplications() started');
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.get<List<ApplicationModel>>(
      endpoint: ApiEndpoints
          .freelanceMyApplications, // -> /api/v1/applications/my-applications
      parser: (json) {
        final list = json as List;
        return list
            .map(
              (item) => ApplicationModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      },
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _applications = response.data!;
      notifyListeners();
    } else {
      _setError(response.message ?? 'Impossible de charger vos candidatures');
    }
  }
}
