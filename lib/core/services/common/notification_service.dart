import 'package:dio/dio.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:freelance_front/core/models/common/notification_model.dart';

class NotificationService {
  final Dio _dio = ApiClient.instance;

  Future<List<NotificationModel>> getNotifications({int skip = 0, int limit = 50}) async {
    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    return (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<NotificationModel> getNotification(int id) async {
    final response = await _dio.get(ApiEndpoints.notification(id));
    return NotificationModel.fromJson(response.data);
  }

  Future<NotificationModel> markAsRead(int id) async {
    final response = await _dio.patch(ApiEndpoints.notificationRead(id));
    return NotificationModel.fromJson(response.data['notification']);
  }

  Future<void> markAllAsRead() async {
    await _dio.patch(ApiEndpoints.notificationsReadAll);
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get(ApiEndpoints.notificationsUnreadCount);
    return response.data['unread_count'] as int;
  }
}
