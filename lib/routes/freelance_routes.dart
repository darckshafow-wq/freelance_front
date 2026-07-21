// ─────────────────────────────────────────────────────────────────────────────
// freelance_routes.dart
// Toutes les routes réservées aux utilisateurs avec le rôle "Freelancer".
//
// Convention de nommage : toutes les constantes commencent par `/freelance/`
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/auth/user_model.dart';
import '../controllers/auth/auth_controller.dart';
import '../models/freelance/application_model.dart';

// Vues Freelance
import '../views/smartphone/freelance/home/freelance_home_page.dart';
import '../views/smartphone/freelance/applications/freelance_applications_page.dart';
import '../views/smartphone/freelance/applications/application_detail_page.dart';
import '../views/smartphone/freelance/profile/freelance_profile_page.dart';
import '../views/smartphone/freelance/dashboard/dashboard_view.dart';
import '../views/smartphone/freelance/tasks/detaille_task.dart';
import '../views/smartphone/freelance/chat/freelance_chat_page.dart';
import '../views/smartphone/freelance/chat/chat_list_page.dart';

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

  /// Page de profil du freelance — attend `Map<String, dynamic>` avec `userId`
  static const String profile = '/freelance/profile';

  /// Détail d'une candidature
  static const String applicationDetail = '/freelance/application-detail';

  /// Détail d'une offre / mission — attend les données via arguments
  static const String jobDetail = '/freelance/job-detail';

  /// Liste des conversations
  static const String chatList = '/freelance/chat-list';

  /// Conversation chat entre freelance et client
  static const String chat = '/freelance/chat';
}

// ─────────────────────────────────────────────────────────────────────────────
// Générateur des routes Freelance
// Appelé depuis AppRoutes.generateRoute(). Retourne null si la route
// n'appartient pas au périmètre freelance.
// ─────────────────────────────────────────────────────────────────────────────
class FreelanceRoutes {
  FreelanceRoutes._();

  /// Retourne une [Route] si [settings.name] est une route freelance connue,
  /// sinon retourne `null` pour laisser le routeur parent gérer.
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      // ── Accueil Freelance ────────────────────────────────────────────────
      case FreelanceRouteNames.home:
      case FreelanceRouteNames.homeAlias:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            // 1. Initialisation des variables par défaut
            AuthController? authController;
            String userId = 'me'; // Valeur de repli sécurisée

            // 2. Extraction intelligente des arguments passés lors de la navigation
            if (settings.arguments is AuthController) {
              authController = settings.arguments as AuthController;
              userId = authController.currentUser?.id.toString() ?? 'me';
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              authController = args['authController'] as AuthController?;
              userId =
                  args['userId']?.toString() ??
                  authController?.currentUser?.id.toString() ??
                  'me';
            }

            // 3. Retour de la page avec tous ses paramètres obligatoires
            return FreelanceHomePage(
              userId: userId,
              authController: authController,
            );
          },
        );
      // ── Tableau de bord (legacy DashboardView) ───────────────────────────
      case FreelanceRouteNames.dashboard:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return DashboardView(authController: auth);
          },
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
      // Attend : settings.arguments = Map<String, dynamic> { 'userId': int|String }
      case FreelanceRouteNames.profile:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final args = settings.arguments;
            String userId = 'me';
            AuthController? authController;

            if (args is Map<String, dynamic>) {
              userId =
                  args['userId']?.toString() ?? args['id']?.toString() ?? 'me';
              if (args['authController'] is AuthController) {
                authController = args['authController'] as AuthController;
              }
            } else if (args is AuthController && args.currentUser != null) {
              userId = args.currentUser!.id.toString();
              authController = args;
            }

            return FreelanceProfilePage(
              userId: userId,
              authController: authController,
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

      case FreelanceRouteNames.chatList:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            int currentUserId = 0;

            // Extraction de l'ID depuis l'AuthController ou la Map passée en arguments
            if (settings.arguments is AuthController) {
              final auth = settings.arguments as AuthController;
              currentUserId = auth.currentUser?.id ?? 0;
            } else if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final auth = args['authController'] as AuthController?;
              currentUserId =
                  args['currentUserId'] as int? ?? auth?.currentUser?.id ?? 0;
            }

            // On passe enfin le paramètre requis au constructeur
            return ChatListPage(currentUserId: currentUserId);
          },
        );

      case FreelanceRouteNames.chat:
        return _guardRoute(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final args = settings.arguments;
            int otherUserId = 0;
            String? otherUserName;

            if (args is int) {
              otherUserId = args;
            } else if (args is Map<String, dynamic>) {
              otherUserId =
                  args['otherUserId'] as int? ?? args['id'] as int? ?? 0;
              otherUserName = args['otherUserName'] as String?;
            }

            return FreelanceChatPage(
              otherUserId: otherUserId,
              otherUserName: otherUserName,
            );
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
    // Exemple :
    //   if (ApiClient.currentToken == null) {
    //     return MaterialPageRoute(
    //       builder: (_) => const _AccessDeniedPage(reason: 'Non connecté'),
    //     );
    //   }
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }
}
