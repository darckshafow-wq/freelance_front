import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../routes/app_router.dart';
import '../../../../controllers/admin/admin_controller.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  AdminSidebar({super.key, required this.selectedIndex});

  final AdminController _controller = AdminController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF14142B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'VertexGuard',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'GENERAL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(
            context,
            0,
            Icons.grid_view_rounded,
            'Overview',
            AdminRouteNames.dashboard,
          ),
          _sidebarItem(
            context,
            1,
            Icons.people_outline_rounded,
            'Users',
            AdminRouteNames.users,
          ),
          _sidebarItem(
            context,
            2,
            Icons.assignment_outlined,
            'Missions',
            AdminRouteNames.tasks,
          ),

          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'COMMUNICATION',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _sidebarItem(
            context,
            3,
            Icons.notifications_none_rounded,
            'Notifications',
            AdminRouteNames.notifications,
          ),
          _sidebarItem(
            context,
            4,
            Icons.chat_bubble_outline_rounded,
            'Messages',
            AdminRouteNames.messages,
          ),
          // ── Nouvel Onglet Feedback ─────────────────────────────────────
          _sidebarItem(
            context,
            5,
            Icons.rate_review_outlined,
            'Feedbacks',
            AdminRouteNames.feedbackList,
          ),
          _sidebarItem(
            context,
            6,
            Icons.description_outlined,
            'Audit Logs',
            AdminRouteNames.auditLogs,
          ),

          const Spacer(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              'SYSTEM',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _sidebarItem(
            context,
            7,
            Icons.settings_outlined,
            'Settings',
            AdminRouteNames.profile,
          ),
          _sidebarItem(
            context,
            8,
            Icons.logout_rounded,
            'Log Out',
            AppRouteNames.landing,
            isLogout: true,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    BuildContext context,
    int index,
    IconData icon,
    String title,
    String route, {
    bool isLogout = false,
  }) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () {
        if (isLogout) {
          _controller.logout();
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
        } else {
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, route);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 4),
                )
              : null,
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
