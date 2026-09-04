import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/notification_controller.dart';
import 'package:freelance_front/core/models/common/notification_model.dart';

class ClientNotificationsView extends StatefulWidget {
  const ClientNotificationsView({super.key});

  @override
  State<ClientNotificationsView> createState() => _ClientNotificationsViewState();
}

class _ClientNotificationsViewState extends State<ClientNotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Notifications', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationController>().markAllAsRead(),
            child: const Text('Tout lire', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.neutralGray.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('Aucune notification pour le moment', 
                    style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) => _buildNotificationItem(controller.notifications[index], index),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'PROPOSAL':
        icon = Icons.description_outlined;
        color = Colors.blue;
        break;
      case 'MESSAGE':
        icon = Icons.chat_bubble_outline;
        color = AppColors.primaryGold;
        break;
      case 'SYSTEM':
        icon = Icons.info_outline;
        color = Colors.green;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = Colors.purple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white.withValues(alpha: 0.7) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: notification.isRead ? null : Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationController>().markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notification.title, 
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.bold : FontWeight.w900, 
                              fontSize: 15, 
                              color: AppColors.deepBlack
                            )
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.content,
                        style: TextStyle(
                          color: AppColors.neutralGray.withValues(alpha: 0.8), 
                          fontSize: 13, 
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600, 
                          height: 1.3
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
  }
}
