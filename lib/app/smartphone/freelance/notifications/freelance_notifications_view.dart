import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/notification_controller.dart';
import 'package:freelance_front/core/models/common/notification_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class FreelanceNotificationsView extends StatefulWidget {
  const FreelanceNotificationsView({super.key});

  @override
  State<FreelanceNotificationsView> createState() => _FreelanceNotificationsViewState();
}

class _FreelanceNotificationsViewState extends State<FreelanceNotificationsView> {
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
        title: const Text('Centre de notifications', 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.deepBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.deepBlack, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<NotificationController>().loadNotifications(),
            icon: const Icon(Icons.sync_rounded, color: AppColors.deepBlack),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
          }

          if (controller.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.neutralGray.withValues(alpha: 0.1)),
                  ),
                  const SizedBox(height: 24),
                  const Text('Rien à signaler pour le moment', 
                    style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => controller.loadNotifications(),
            color: AppColors.primaryGold,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: controller.notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildNotificationCard(controller.notifications[index], index),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int index) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'PROPOSAL_ACCEPTED':
        icon = Icons.assignment_turned_in_rounded;
        color = Colors.blueAccent;
        break;
      case 'MESSAGE':
        icon = Icons.forum_rounded;
        color = AppColors.primaryGold;
        break;
      case 'SYSTEM':
        icon = Icons.auto_awesome_rounded;
        color = Colors.purpleAccent;
        break;
      case 'SUCCESS':
        icon = Icons.check_circle_rounded;
        color = Colors.greenAccent;
        break;
      case 'WARNING':
        icon = Icons.warning_amber_rounded;
        color = Colors.redAccent;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.neutralGray;
    }

    final bool isNew = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isNew ? Border.all(color: color.withValues(alpha: 0.2), width: 1.5) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isNew) {
              context.read<NotificationController>().markAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(notification.title, 
                              style: const TextStyle(
                                fontWeight: FontWeight.w900, 
                                fontSize: 15, 
                                color: AppColors.deepBlack,
                                letterSpacing: -0.3
                              )
                            ),
                          ),
                          Text(DateFormat('dd MMM').format(notification.createdAt ?? DateTime.now()), 
                            style: const TextStyle(color: Colors.black12, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.content,
                        style: TextStyle(
                          color: AppColors.neutralGray, 
                          fontSize: 13, 
                          height: 1.4,
                          fontWeight: isNew ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 8, top: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat()).fade(duration: 1.seconds),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.05);
  }
}
