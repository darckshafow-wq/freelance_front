import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/client/task_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/app_router.dart';
import '../../../../routes/client_routes.dart';
import '../../../../controllers/shared/notification_controller.dart';
import '../../../shared/widgets/mission_grid_card.dart';
import '../../../shared/widgets/app_bottom_navigation.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final taskController = context.read<TaskController>();
      final notificationController = context.read<NotificationController>();

      notificationController.role = auth.currentUser?.role;
      taskController.fetchTasks();
      notificationController.fetchNotifications();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Contenu principal scrollable
          _buildHomeTab(),

          // 2. Navigation flottante superposée tout en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavigation(
              authController: authController,
              currentRoute:
                  '/dashboard', // Ajustez selon votre constante de route
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    final authController = context.watch<AuthController>();
    final taskController = context.watch<TaskController>();
    final notificationController = context.watch<NotificationController>();
    final user = authController.currentUser;

    return RefreshIndicator(
      onRefresh: () => taskController.fetchTasks(),
      color: Colors.black,
      backgroundColor: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Top Bar Premium
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // New Premium Location Selector
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LOCALISATION',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Abidjan, CIV',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ],
                        ),
                      ],
                    ),
                    // Notifications & Profile
                    Row(
                      children: [
                        _buildHeaderAction(
                          icon: Icons.notifications_none_rounded,
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouteNames.notifications,
                            arguments: authController,
                          ),
                          hasBadge: notificationController.unreadCount > 0,
                        ),
                        const SizedBox(width: 12),
                        _buildProfileButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Discover Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salut, ${user?.fullName.split(' ')[0] ?? 'Expert'} 👋',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Trouvez vos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    'Meilleurs Talents',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.2,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher un talent...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          icon: Icon(Icons.search_rounded, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Grid Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Missions à proximité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Voir tout',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Grid Content
          _buildGridContent(),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGridContent() {
    final taskController = context.watch<TaskController>();
    if (taskController.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final tasks = taskController.tasks;
    if (tasks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            'Aucune mission trouvée',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final task = tasks[index];
          return MissionGridCard(
            task: task,
            onTap: () => Navigator.pushNamed(
              context,
              ClientRouteNames.missionDetail,
              arguments: task.id,
            ),
          );
        }, childCount: tasks.length),
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 22),
            if (hasBadge)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton() {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 22,
      ),
    );
  }
}
