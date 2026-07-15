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

  /// Postuler à une mission
  Future<bool> applyToTask({
    required int taskId,
    required double budget,
    String coverLetter = '',
  }) async {
    dev.log(
      '[ApplicationController] applyToTask(taskId: $taskId, budget: $budget, coverLetter: "$coverLetter") started',
    );
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.post<ApplicationModel>(
      endpoint: ApiEndpoints.freelanceApplications,
      body: {
        'task_id': taskId,
        'proposed_budget': budget,
        'cover_letter': coverLetter,
      },
      parser: (json) {
        dev.log('[ApplicationController] applyToTask - Raw JSON Response: $json');
        final model = ApplicationModel.fromJson(json as Map<String, dynamic>);
        dev.log('[ApplicationController] applyToTask - Parsed ApplicationModel: ID=${model.id}, TaskID=${model.taskId}, Budget=${model.proposedBudget}, Status=${model.status}');
        return model;
      },
    );

    _setLoading(false);
    dev.log(
      '[ApplicationController] applyToTask response: success=${response.isSuccess} / message=${response.message}',
    );

    if (response.isSuccess) {
      dev.log('[ApplicationController] applyToTask SUCCESS - Fetching notifications...');
      await _notificationController.fetchNotifications();
      return true;
    } else {
      dev.log('[ApplicationController] applyToTask FAILED: ${response.message}');
      _setError(response.message ?? 'Erreur lors de la candidature');
      return false;
    }
  }
}
