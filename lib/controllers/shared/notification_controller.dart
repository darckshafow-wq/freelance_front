import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../models/auth/user_model.dart';
import '../../services/api/api_core.dart';
import '../../services/api/api_endpoints.dart';
import '../../models/shared/notification_model.dart';

class NotificationController extends ChangeNotifier {
  UserRole? _role;
  NotificationController({UserRole? role}) : _role = role;

  set role(UserRole? value) {
    if (_role != value) {
      _role = value;
      notifyListeners();
    }
  }

  UserRole? get role => _role;

  final ApiClient _apiClient = ApiClient();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotificationModel> get unread =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get read =>
      _notifications.where((n) => n.isRead).toList();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Récupère les notifications depuis le backend si l’endpoint existe.
  /// Le backend actuel n’expose pas cette ressource ; on garde un état vide proprement.
  String get _notificationsEndpoint {
    switch (role) {
      case UserRole.client:
        return ApiEndpoints.clientNotifications;
      case UserRole.admin:
        return ApiEndpoints.adminNotifications;
      case UserRole.freelancer:
        return ApiEndpoints.freelanceNotifications;
      default:
        return ApiEndpoints.freelanceNotifications;
    }
  }

  String _notificationRead(int id) {
    switch (role) {
      case UserRole.client:
        return ApiEndpoints.clientNotificationRead(id);
      case UserRole.admin:
        return ApiEndpoints.adminNotificationRead(id);
      case UserRole.freelancer:
        return ApiEndpoints.freelanceNotificationRead(id);
      default:
        return ApiEndpoints.freelanceNotificationRead(id);
    }
  }

  String _notificationDelete(int id) {
    switch (role) {
      case UserRole.client:
        return ApiEndpoints.clientNotificationDelete(id);
      case UserRole.admin:
        return ApiEndpoints.adminNotificationDelete(id);
      case UserRole.freelancer:
        return ApiEndpoints.freelanceNotificationDelete(id);
      default:
        return ApiEndpoints.freelanceNotificationDelete(id);
    }
  }

  Future<void> fetchNotifications() async {
    dev.log('[NotificationController] fetchNotifications() started');
    _setLoading(true);
    _setError(null);

    if (ApiClient.mockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      _notifications = [
        NotificationModel(id: 1, title: 'Bienvenue !', body: 'Bienvenue sur la plateforme Freelance Expert.', type: NotificationType.system, isRead: false, createdAt: DateTime.now()),
        NotificationModel(id: 2, title: 'Profil validé', body: 'Votre profil a été vérifié avec succès.', type: NotificationType.missionValidated, isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 2))),
      ];
      _setLoading(false);
      notifyListeners();
      return;
    }

    final response = await _apiClient.get<List<NotificationModel>>(
      endpoint: _notificationsEndpoint,
      parser: (json) {
        dev.log(
          '[NotificationController] fetchNotifications - Raw JSON Response: $json',
        );
        if (json is List) {
          final list = json.map((item) {
            dev.log(
              '[NotificationController] fetchNotifications - Processing Item: $item',
            );
            final model = NotificationModel.fromJson(
              item as Map<String, dynamic>,
            );
            dev.log(
              '[NotificationController] fetchNotifications - Parsed NotificationModel: ID=${model.id}, Title="${model.title}", Type=${model.type}, Read=${model.isRead}',
            );
            return model;
          }).toList();
          return list;
        }
        dev.log(
          '[NotificationController] fetchNotifications - Warning: JSON is not a List!',
        );
        return [];
      },
    );

    _setLoading(false);

    dev.log(
      '[NotificationController] fetchNotifications response: success=${response.isSuccess} / message=${response.message} / count=${response.data?.length ?? 0}',
    );

    if (response.isSuccess && response.data != null) {
      _notifications = response.data!;
      dev.log(
        '[NotificationController] fetchNotifications SUCCESS - Injected ${_notifications.length} notifications.',
      );
    } else {
      dev.log(
        '[NotificationController] fetchNotifications FAILED: ${response.message}',
      );
      _notifications = [];
    }

    notifyListeners();
  }

  /// Marque une notification comme lue (localement + backend)
  Future<void> markAsRead(int notifId) async {
    dev.log('[NotificationController] markAsRead(notifId: $notifId) started');
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1 && !_notifications[idx].isRead) {
      // Mise à jour optimiste
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      dev.log(
        '[NotificationController] markAsRead - Optimistically marked notification $notifId as read.',
      );
      notifyListeners();

      // Persistance backend
      final response = await _apiClient.post(
        body: {},
        endpoint: _notificationRead(notifId),
        parser: (json) {
          dev.log(
            '[NotificationController] markAsRead API - Raw JSON Response: $json',
          );
          return json;
        },
      );
      dev.log(
        '[NotificationController] markAsRead API response: success=${response.isSuccess}',
      );
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    dev.log('[NotificationController] markAllAsRead() started');
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      dev.log(
        '[NotificationController] markAllAsRead - Marked all as read local.',
      );
      notifyListeners();
    }
  }

  /// Supprime une notification avec dismiss optimiste
  Future<void> deleteNotification(int notifId) async {
    dev.log(
      '[NotificationController] deleteNotification(notifId: $notifId) started',
    );
    _notifications.removeWhere((n) => n.id == notifId);
    dev.log(
      '[NotificationController] deleteNotification - Optimistically removed notification $notifId.',
    );
    notifyListeners();
    final response = await _apiClient.delete(
      endpoint: _notificationDelete(notifId),
      parser: (json) {
        dev.log(
          '[NotificationController] deleteNotification API - Raw JSON Response: $json',
        );
        return json;
      },
    );
    dev.log(
      '[NotificationController] deleteNotification API response: success=${response.isSuccess}',
    );
  }

  // ─── BROADCASTS (Admin) ────────────────────────────────────────────────
  List<NotificationModel> _broadcasts = [];
  List<NotificationModel> get broadcasts => _broadcasts;

  /// Récupère l'historique des notifications broadcast (Admin uniquement)
  Future<void> fetchBroadcasts() async {
    dev.log('[NotificationController] fetchBroadcasts() started');
    _setLoading(true);
    _setError(null);

    final response = await _apiClient.get<List<NotificationModel>>(
      endpoint: ApiEndpoints.adminNotificationsBroadcast,
      parser: (json) {
        if (json is List) {
          return json
              .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _broadcasts = response.data!;
      dev.log(
        '[NotificationController] fetchBroadcasts SUCCESS - ${_broadcasts.length} broadcasts.',
      );
    } else {
      dev.log(
        '[NotificationController] fetchBroadcasts FAILED: ${response.message}',
      );
      _broadcasts = [];
    }

    notifyListeners();
  }
}
