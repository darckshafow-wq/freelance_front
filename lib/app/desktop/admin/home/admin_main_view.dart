import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/widgets/app_sidebar.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';

class AdminMainView extends StatefulWidget {
  final Widget child;
  const AdminMainView({super.key, required this.child});

  @override
  State<AdminMainView> createState() => _AdminMainViewState();
}

class _AdminMainViewState extends State<AdminMainView> {
  final List<SidebarItem> _sidebarItems = [
    SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', routeName: RouteNames.adminDashboard, name: 'adminDashboard'),
    SidebarItem(icon: Icons.people_rounded, label: 'Utilisateurs', routeName: RouteNames.adminUsers, name: 'adminUsers'),
    SidebarItem(icon: Icons.work_rounded, label: 'Missions', routeName: RouteNames.adminProjects, name: 'adminProjects'),
    SidebarItem(icon: Icons.category_rounded, label: 'Catégories', routeName: RouteNames.adminCategories, name: 'adminCategories'),
    SidebarItem(icon: Icons.star_rounded, label: 'Avis', routeName: RouteNames.adminReviews, name: 'adminReviews'),
    SidebarItem(icon: Icons.report_problem_rounded, label: 'Signalements', routeName: RouteNames.adminReports, name: 'adminReports'),
    SidebarItem(icon: Icons.history_rounded, label: 'Audit Logs', routeName: RouteNames.adminAuditLogs, name: 'adminAuditLogs'),
    SidebarItem(icon: Icons.campaign_rounded, label: 'Diffusions', routeName: RouteNames.adminBroadcastsList, name: 'adminBroadcastsList'),
    SidebarItem(icon: Icons.warning_amber_rounded, label: 'Alertes Système', routeName: RouteNames.adminWarnings, name: 'adminWarnings'),
    SidebarItem(icon: Icons.feedback_rounded, label: 'Feedbacks', routeName: RouteNames.adminFeedback, name: 'adminFeedback'),
    SidebarItem(icon: Icons.location_on_rounded, label: 'Localisations', routeName: RouteNames.adminLocations, name: 'adminLocations'),
    SidebarItem(icon: Icons.monetization_on_rounded, label: 'Finances', routeName: RouteNames.adminFinancials, name: 'adminFinancials'),
    SidebarItem(icon: Icons.settings_rounded, label: 'Paramètres', routeName: RouteNames.adminSettings, name: 'adminSettings'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Row(
        children: [
          AppSidebar(
            items: _sidebarItems,
            headerTitle: 'FreeFlow',
            headerIcon: Icons.auto_awesome_mosaic_rounded,
            onLogout: () async {
              final auth = context.read<AuthController>();
              await auth.logout();
              if (mounted) context.go(RouteNames.login);
            },
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
