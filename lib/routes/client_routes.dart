import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../controllers/auth/auth_controller.dart';
import '../utils/responsive.dart';

// Vues Client
import '../views/smartphone/client/home/client_home_view.dart';
import '../views/smartphone/client/missions/client_missions_page.dart';
import '../views/smartphone/client/missions/create_mission_view.dart';
import '../views/smartphone/client/missions/mission_detail_view.dart';
import '../views/smartphone/client/profile/client_profile_page.dart';
import '../views/smartphone/client/applications/client_applications_view.dart';
import '../views/smartphone/client/chat/client_chat_list_page.dart';
import '../views/smartphone/client/chat/client_chat_page.dart';
import '../views/smartphone/client/settings/settings_view.dart';

// Vues Desktop Responsive
import '../views/desktop/responsive/client/client_home_desktop.dart';

// ─────────────────────────────────────────────────────────────────────────────
// client_routes.dart
// Toutes les routes réservées aux utilisateurs avec le rôle "Client".
// ─────────────────────────────────────────────────────────────────────────────

class ClientRouteNames {
  ClientRouteNames._();

  /// Page d'accueil principale du client
  static const String home = '/client/home';

  /// Liste des missions créées par le client
  static const String missions = '/client/missions';

  /// Liste des conversations du client
  static const String chatList = '/client/chat-list';

  /// Conversation active du client
  static const String chat = '/client/chat';

  /// Alias vers la conversation active
  static const String chatDetail = '/client/chat';

  /// Liste des candidatures reçues sur les missions du client
  static const String applications = '/client/applications';

  /// Page de profil du client
  static const String profile = '/client/profile';

  /// Page de paramètres
  static const String settings = '/client/settings';

  /// Création d'une nouvelle mission
  static const String createMission =
      '/smartphone/client/missions/create_mission_view';

  /// Détail d'une mission — attend un [int] (taskId) en argument
  static const String missionDetail =
      '/smartphone/client/missions/mission_detail_view';
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur des routes Client
// ─────────────────────────────────────────────────────────────────────────────
class ClientRoutes {
  ClientRoutes._();

  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      // ── Accueil Client ───────────────────────────────────────────────────
      case ClientRouteNames.home:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const Responsive(
            mobile: ClientHomeView(),
            desktop: ClientHomeDesktop(),
          ),
        );

      // ── Missions ──────────────────────────────────────────────────────────
      case ClientRouteNames.missions:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientMissionsPage(),
        );

      case ClientRouteNames.applications:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientApplicationsView(),
        );

      // ── Liste des conversations Client ────────────────────────────────────
      case ClientRouteNames.chatList:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            int currentUserId = 0;

            if (settings.arguments is AuthController) {
              final auth = settings.arguments as AuthController;
              currentUserId = auth.currentUser?.id ?? 0;
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              currentUserId = args['currentUserId'] as int? ?? 0;
            }

            return ClientChatListPage(currentUserId: currentUserId);
          },
        );

      // ── Conversation active Client (/client/chat) ─────────────────────────
      case ClientRouteNames.chat:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final args = settings.arguments;
            int otherUserId = 0;
            String? otherUserName;
            int taskId = 0;
            int applicationId = 0;
            String? initialStatus;

            if (args is Map<String, dynamic>) {
              otherUserId = args['otherUserId'] as int? ?? 0;
              otherUserName = args['otherUserName'] as String?;
              taskId = args['taskId'] as int? ?? 0;
              applicationId = args['applicationId'] as int? ?? 0;
              initialStatus = args['initialStatus'] as String?;
            }

            return ClientChatPage(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              taskId: taskId,
              applicationId: applicationId,
              initialStatus: initialStatus,
            );
          },
        );

      // ── Profil Client ─────────────────────────────────────────────────────
      case ClientRouteNames.profile:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientProfilePage(),
        );

      case ClientRouteNames.settings:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const SettingsView(),
        );

      // ── Créer une Mission ─────────────────────────────────────────────────
      case ClientRouteNames.createMission:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const CreateMissionView(),
        );

      // ── Détail d'une Mission ──────────────────────────────────────────────
      case ClientRouteNames.missionDetail:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final args = settings.arguments;
            final int taskId = (args is int) ? args : 0;
            return MissionDetailView(taskId: taskId);
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
