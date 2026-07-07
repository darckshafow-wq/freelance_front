import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api/mock_data.dart';

class NotificationController extends ChangeNotifier {
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

  /// Récupère les notifications depuis le mock
  Future<void> fetchNotifications() async {
    _setLoading(true);
    _setError(null);

    final response = await MockData.getNotifications();

    _setLoading(false);

    if (response.isSuccess && response.data != null) {
      _notifications = response.data!;
      notifyListeners();
    } else {
      _setError(response.message ?? 'Impossible de charger les notifications');
    }
  }

  /// Marque une notification comme lue (localement + mock)
  Future<void> markAsRead(int notifId) async {
    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1 && !_notifications[idx].isRead) {
      // Mise à jour optimiste
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
      // Persistance mock
      await MockData.markNotificationAsRead(notifId);
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      await MockData.markAllNotificationsAsRead();
    }
  }

  /// Supprime une notification avec dismiss optimiste
  Future<void> deleteNotification(int notifId) async {
    _notifications.removeWhere((n) => n.id == notifId);
    notifyListeners();
    await MockData.deleteNotification(notifId);
  }
}
