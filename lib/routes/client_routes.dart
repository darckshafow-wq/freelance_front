// ─────────────────────────────────────────────────────────────────────────────
// client_routes.dart
// Toutes les routes réservées aux utilisateurs avec le rôle "Client".
//
// Convention de nommage : toutes les constantes commencent par `/client/`
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../controllers/auth/auth_controller.dart';

// Vues Client
import '../views/smartphone/client/home/client_home_view.dart';
import '../views/smartphone/client/missions/client_missions_page.dart';
import '../views/smartphone/client/missions/create_mission_view.dart';
import '../views/smartphone/client/missions/mission_detail_view.dart';
import '../views/smartphone/client/profile/client_profile_page.dart';
import '../views/smartphone/client/applications/client_applications_view.dart';
import '../views/smartphone/client/chat/client_chat_list_page.dart';
import '../views/smartphone/client/chat/client_chat_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constantes des noms de routes Client
// ─────────────────────────────────────────────────────────────────────────────
class ClientRouteNames {
  ClientRouteNames._();

  /// Page d'accueil principale du client
  static const String home = '/client/home';

  /// Alias court vers /client/home
  static const String homeAlias = '/client';

  /// Dashboard client (vue legacy)
  static const String dashboard = '/dashboard';

  /// Liste des missions créées par le client
  static const String missions = '/client/missions';

  /// Liste des conversations du client
  static const String chat = '/client/chat-list';

  /// Conversation active du client
  static const String chatDetail = '/client/chat';

  /// Liste des candidatures reçues sur les missions du client
  static const String applications = '/client/applications';

  /// Page de profil du client
  static const String profile = '/client/profile';

  /// Création d'une nouvelle mission — attend un [AuthController] en argument
  static const String createMission =
      '/smartphone/client/missions/create_mission_view';

  /// Détail d'une mission — attend un [int] (taskId) en argument
  static const String missionDetail =
      '/smartphone/client/missions/mission_detail_view';
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur des routes Client
// Appelé depuis AppRoutes.generateRoute(). Retourne null si la route
// n'appartient pas au périmètre client.
// ─────────────────────────────────────────────────────────────────────────────
class ClientRoutes {
  ClientRoutes._();

  /// Retourne une [Route] si [settings.name] est une route client connue,
  /// sinon retourne `null` pour laisser le routeur parent gérer.
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      // ── Accueil Client ───────────────────────────────────────────────────
      case ClientRouteNames.home:
      case ClientRouteNames.homeAlias:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return ClientHomeView(authController: auth);
          },
        );

      // ── Dashboard Client (legacy ClientHomePage) ──────────────────────────
      case ClientRouteNames.dashboard:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return ClientHomeView(authController: auth);
          },
        );

      // ── Missions ──────────────────────────────────────────────────────────
      case ClientRouteNames.missions:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            return const ClientMissionsPage();
          },
        );

      case ClientRouteNames.applications:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientApplicationsView(),
        );

      // ── Conversations / Chat Client ─────────────────────────────────────────
      case ClientRouteNames.chat:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth = settings.arguments as AuthController?;
            final currentUserId = auth?.currentUser?.id ?? 0;
            return ClientChatListPage(currentUserId: currentUserId);
          },
        );

      case ClientRouteNames.chatDetail:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final args = settings.arguments;
            int otherUserId = 0;
            String? otherUserName;
            int? taskId;

            if (args is Map<String, dynamic>) {
              otherUserId = args['otherUserId'] as int? ?? 0;
              otherUserName = args['otherUserName'] as String?;
              taskId = args['taskId'] as int?;
            }

            return ClientChatPage(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
              taskId: taskId,
            );
          },
        );

      // ── Profil Client ─────────────────────────────────────────────────────
      case ClientRouteNames.profile:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return ClientProfilePage(authController: auth);
          },
        );

      // ── Créer une Mission ─────────────────────────────────────────────────
      // Attend : settings.arguments = AuthController
      case ClientRouteNames.createMission:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return CreateMissionView(authController: auth);
          },
        );

      // ── Détail d'une Mission ──────────────────────────────────────────────
      // Attend : settings.arguments = int (taskId)
      case ClientRouteNames.missionDetail:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final taskId = settings.arguments as int? ?? 0;
            return MissionDetailView(taskId: taskId);
          },
        );

      default:
        return null; // Route non gérée ici
    }
  }

  // ── Guard interne : pour l'instant laisse tout passer (mode dev) ──────────
  static Route<dynamic> _guardRoute({
    required RouteSettings settings,
    required UserRole requiredRole,
    required Widget Function() builder,
  }) {
    // TODO : Réactiver la vérification du token et du rôle en production.
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }
}
