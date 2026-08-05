import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../controllers/auth/auth_controller.dart';
import '../models/freelance/application_model.dart';
import '../utils/responsive.dart';

// Vues Freelance Smartphone
import '../views/smartphone/freelance/home/freelance_home_page.dart';
import '../views/smartphone/freelance/applications/freelance_applications_page.dart';
import '../views/smartphone/freelance/applications/application_detail_page.dart';
import '../views/smartphone/freelance/profile/freelance_profile_page.dart';
import '../views/smartphone/freelance/dashboard/dashboard_view.dart';
import '../views/smartphone/freelance/tasks/detaille_task.dart';
import '../views/smartphone/freelance/chat/freelance_chat_page.dart';
import '../views/smartphone/freelance/chat/chat_list_page.dart';

// Vues Freelance Desktop
import '../views/desktop/responsive/freelance/freelance_home_desktop.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constantes des noms de routes Freelance
// ─────────────────────────────────────────────────────────────────────────────
class FreelanceRouteNames {
  FreelanceRouteNames._();

  /// Page d'accueil principale du freelance
  static const String home = '/freelance/home';

  /// Alias court vers /freelance/home
  static const String homeAlias = '/freelance';

  /// Tableau de bord (vue détaillée, legacy)
  static const String dashboard = '/freelance/dashboard';

  /// Liste des candidatures soumises par le freelance
  static const String applications = '/freelance/applications';

  /// Page de profil du freelance
  static const String profile = '/freelance/profile';

  /// Détail d'une candidature
  static const String applicationDetail = '/freelance/application-detail';

  /// Détail d'une offre / mission — attend les données via arguments
  static const String jobDetail = '/freelance/job-detail';

  /// Liste des conversations
  static const String chatList = '/freelance/chat-list';

  /// Conversation chat entre freelance et client
  static const String chat = '/freelance/chat';

  /// Alias vers la conversation chat (pour compatibilité)
  static const String chatDetail = '/freelance/chat';
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur des routes Freelance
// ─────────────────────────────────────────────────────────────────────────────
class FreelanceRoutes {
  FreelanceRoutes._();

  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      // ── Accueil Freelance ────────────────────────────────────────────────
      case FreelanceRouteNames.home:
      case FreelanceRouteNames.homeAlias:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            // 1. Extraction intelligente des arguments
            String userId = 'me'; 

            if (settings.arguments is AuthController) {
              final authController = settings.arguments as AuthController;
              userId = authController.currentUser?.id.toString() ?? 'me';
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final authController = args['authController'] as AuthController?;
              userId =
                  args['userId']?.toString() ??
                  authController?.currentUser?.id.toString() ??
                  'me';
            }

            // 2. Retour de la page responsive
            return Responsive(
              mobile: FreelanceHomePage(userId: userId),
              desktop: const FreelanceHomeDesktop(),
            );
          },
        );

      // ── Tableau de bord (legacy DashboardView) ───────────────────────────
      case FreelanceRouteNames.dashboard:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const DashboardView(),
        );

      // ── Candidatures ─────────────────────────────────────────────────────
      case FreelanceRouteNames.applications:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceApplicationsPage(),
        );

      case FreelanceRouteNames.applicationDetail:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final appModel = settings.arguments as ApplicationModel;
            return ApplicationDetailPage(application: appModel);
          },
        );

      // ── Profil Freelance ─────────────────────────────────────────────────
      case FreelanceRouteNames.profile:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final args = settings.arguments;
            String userId = 'me';

            if (args is Map<String, dynamic>) {
              userId =
                  args['userId']?.toString() ?? args['id']?.toString() ?? 'me';
            } else if (args is AuthController && args.currentUser != null) {
              userId = args.currentUser!.id.toString();
            }

            return FreelanceProfilePage(
              userId: userId,
            );
          },
        );

      // ── Détail d'une offre ───────────────────────────────────────────────
      case FreelanceRouteNames.jobDetail:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceJobDetailPage(),
        );

      // ── Liste des chats ─────────────────────────────────────────────────
      case FreelanceRouteNames.chatList:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            int currentUserId = 0;

            if (settings.arguments is AuthController) {
              final auth = settings.arguments as AuthController;
              currentUserId = auth.currentUser?.id ?? 0;
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final auth = args['authController'] as AuthController?;
              currentUserId =
                  args['currentUserId'] as int? ?? auth?.currentUser?.id ?? 0;
            }

            return ChatListPage(currentUserId: currentUserId);
          },
        );

      // ── Chat actif ──────────────────────────────
      case FreelanceRouteNames.chat:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final args = settings.arguments;
            int otherUserId = 0;
            String? otherUserName;
            int taskId = 0;
            int applicationId = 0;
            String? initialStatus;

            if (args is int) {
              otherUserId = args;
            } else if (args is Map<String, dynamic>) {
              otherUserId = (args['otherUserId'] is int) ? args['otherUserId'] : (args['id'] is int ? args['id'] : 0);
              otherUserName = args['otherUserName'] as String?;
              taskId = (args['taskId'] is int) ? args['taskId'] : 0;
              applicationId = (args['applicationId'] is int) ? args['applicationId'] : 0;
              initialStatus = args['initialStatus'] as String?;
            }

            return FreelanceChatPage(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              taskId: taskId,
              applicationId: applicationId,
              initialStatus: initialStatus,
            );
          },
        );

      default:
        return null;
    }
  }

  static Route<dynamic> _guardRoute({
    required RouteSettings settings,
    required UserRole requiredRole,
    required Widget Function() builder,
  }) {
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }
}
