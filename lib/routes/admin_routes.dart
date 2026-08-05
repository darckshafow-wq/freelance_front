// ─────────────────────────────────────────────────────────────────────────────
// admin_routes.dart
// Toutes les routes réservées aux utilisateurs avec le rôle "Admin".
//
// Convention de nommage : toutes les constantes commencent par `/admin/`
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

// Vues Admin Desktop
import '../views/desktop/admin/dashboard/dashboard.dart';
import '../views/desktop/admin/tasks/task_detail.dart';
import '../views/desktop/admin/users/user_detail.dart';
import '../views/desktop/admin/users/user_list.dart';
import '../views/desktop/admin/tasks/task_list.dart';
import '../views/desktop/admin/profile/admin_profile.dart';
import '../views/desktop/admin/notification/admin_notification.dart';
import '../views/desktop/admin/messages/admin_messages.dart';
import '../views/desktop/admin/feedback/liste_feedback.dart';
import '../views/desktop/admin/feedback/detail_feedback.dart';
import '../views/desktop/admin/feedback/response_feedback.dart';
import '../views/desktop/admin/audit/admin_audit_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constantes des noms de routes Admin
// ─────────────────────────────────────────────────────────────────────────────
class AdminRouteNames {
  AdminRouteNames._();

  /// Tableau de bord principal de l'admin
  static const String dashboard = '/admin/dashboard';

  /// Gestion des utilisateurs
  static const String users = '/admin/users';

  /// Gestion des missions/tâches
  static const String tasks = '/admin/tasks';

  /// Détail d'un utilisateur — attend un [int] (userId) en argument
  static const String userDetail = '/admin/users/detail';

  /// Détail d'une mission — attend un [int] (taskId) en argument
  static const String taskDetail = '/admin/tasks/detail';

  /// Profil de l'admin
  static const String profile = '/admin/profile';

  /// Notifications admin
  static const String notifications = '/admin/notifications';

  /// Messages admin
  static const String messages = '/admin/messages';

  /// Liste des feedbacks
  static const String feedbackList = '/admin/feedback';

  /// Journal d'audit admin
  static const String auditLogs = '/admin/audit';

  /// Détail d'un feedback — attend un [int] (feedbackId) en argument
  static const String feedbackDetail = '/admin/feedback/detail';

  /// Réponse à un feedback — attend un [int] (feedbackId) en argument
  static const String feedbackReply = '/admin/feedback/reply';
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur des routes Admin
// Appelé depuis AppRoutes.generateRoute(). Retourne null si la route
// n'appartient pas au périmètre admin.
// ─────────────────────────────────────────────────────────────────────────────
class AdminRoutes {
  AdminRoutes._();

  /// Retourne une [Route] si [settings.name] est une route admin connue,
  /// sinon retourne `null` pour laisser le routeur parent gérer.
  static Route<dynamic>? generate(RouteSettings settings) {
    // Debug log pour voir quel nom de route arrive ici
    debugPrint('[AdminRoutes] generate() name=${settings.name}');

    switch (settings.name) {
      // ── Tableau de bord Admin ─────────────────────────────────────────────
      case AdminRouteNames.dashboard:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminDashboard(),
        );

      // ── Gestion Utilisateurs / Liste ──────────────────────────────────────
      case AdminRouteNames.users:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminUserList(),
        );

      // ── Gestion Utilisateurs / Détail ─────────────────────────────────────
      case AdminRouteNames.userDetail:
        final args = settings.arguments;
        final int userId = (args is int) ? args : 0;
        return _guardRoute(
          settings: settings,
          builder: () => AdminUserDetail(userId: userId),
        );

      // ── Gestion Missions / Liste ──────────────────────────────────────────
      case AdminRouteNames.tasks:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminTaskList(),
        );

      // ── Gestion Missions / Détail ─────────────────────────────────────────
      case AdminRouteNames.taskDetail:
        final args = settings.arguments;
        final int taskId = (args is int) ? args : 0;
        return _guardRoute(
          settings: settings,
          builder: () => AdminTaskDetail(taskId: taskId),
        );

      // ── Profil Admin ──────────────────────────────────────────────────────
      case AdminRouteNames.profile:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminProfile(),
        );

      // ── Notifications Admin ───────────────────────────────────────────────
      case AdminRouteNames.notifications:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminNotification(),
        );

      // ── Messages Admin ────────────────────────────────────────────────────
      case AdminRouteNames.messages:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminMessages(),
        );

      // ── Feedbacks Admin / Liste ───────────────────────────────────────────
      case AdminRouteNames.feedbackList:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminFeedbackList(),
        );

      // ── Audit logs Admin ────────────────────────────────────────────────
      case AdminRouteNames.auditLogs:
        return _guardRoute(
          settings: settings,
          builder: () => const AdminAuditPage(),
        );

      // ── Feedbacks Admin / Détail ──────────────────────────────────────────
      case AdminRouteNames.feedbackDetail:
        final args = settings.arguments;
        final int feedbackId = (args is int) ? args : 0;
        return _guardRoute(
          settings: settings,
          builder: () => AdminFeedbackDetail(feedbackId: feedbackId),
        );

      // ── Feedbacks Admin / Réponse ─────────────────────────────────────────
      case AdminRouteNames.feedbackReply:
        final args = settings.arguments;
        final int feedbackId = (args is int) ? args : 0;
        return _guardRoute(
          settings: settings,
          builder: () => AdminFeedbackReply(feedbackId: feedbackId),
        );

      default:
        return null; // Route non gérée ici
    }
  }

  // ── Guard Admin : vérifie que l'utilisateur est un admin ──────────────────
  static Route<dynamic> _guardRoute({
    required RouteSettings settings,
    required Widget Function() builder,
  }) {
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }
}
