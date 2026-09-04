import 'package:flutter/material.dart';
import 'package:freelance_front/core/models/common/notification_model.dart';
import 'package:freelance_front/core/services/common/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  bool isLoading = false;
  String? errorMessage;
  List<NotificationModel> notifications = [];
  int unreadCount = 0;

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();
    try {
      notifications = await _service.getNotifications();
      unreadCount = await _service.getUnreadCount();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _service.markAsRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = notifications[index];
        notifications[index] = NotificationModel(
          id: current.id,
          userId: current.userId,
          title: current.title,
          content: current.content,
          type: current.type,
          isRead: true,
          createdAt: current.createdAt,
        );
        unreadCount = (unreadCount > 0) ? unreadCount - 1 : 0;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      notifications = notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          content: n.content,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      unreadCount = 0;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
