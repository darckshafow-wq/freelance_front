// ─────────────────────────────────────────────────────────────────────────────
// app_router.dart
// Point d'entrée central du routage de l'application.
//
// Ce fichier :
//   1. Déclare toutes les constantes de routes PUBLIQUES (landing, login, etc.)
//   2. Délègue les routes privées à :
//        - FreelanceRoutes  →  freelance_routes.dart
//        - ClientRoutes     →  client_routes.dart
//        - AdminRoutes      →  admin_routes.dart
//
// Usage depuis n'importe quelle vue :
//   Navigator.pushNamed(context, AppRouteNames.login);
//   Navigator.pushNamed(context, FreelanceRouteNames.profile, arguments: {'userId': 42});
//   Navigator.pushNamed(context, ClientRouteNames.createMission, arguments: authController);
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// Sous-routeurs par rôle
import 'freelance_routes.dart';
import 'client_routes.dart';
import 'admin_routes.dart';

// Vues publiques / partagées
import '../views/smartphone/onbor/landing.dart';
import '../views/smartphone/auth_smartphone/reconnection/login_page.dart';
import '../views/smartphone/auth_smartphone/reconnection/verification_page.dart';
import '../views/smartphone/auth_smartphone/reconnection/forget_password_page.dart';
import '../views/smartphone/auth_smartphone/creation/create_account_page.dart';
import '../views/smartphone/auth_smartphone/creation/role_selection_page.dart';
import '../views/smartphone/notification/liste_notification.dart';
import '../views/smartphone/notification/detaille_notification.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constantes des routes PUBLIQUES (accessibles sans authentification)
// ─────────────────────────────────────────────────────────────────────────────
class AppRouteNames {
  AppRouteNames._();

  /// Page d'accueil / Onboarding
  static const String landing = '/landing';

  /// Page de connexion
  static const String login = '/login';

  /// Inscription (alias de createAccount)
  static const String register = '/register';

  /// Création de compte — attend un [String] (role) en argument
  static const String createAccount = '/create-account';

  /// Sélection du rôle (client ou freelance)
  static const String roleSelection = '/role-selection';

  /// Vérification du code OTP — attend un [String] (email) en argument
  static const String verification = '/verification';

  /// Mot de passe oublié
  static const String forgetPassword = '/forget-password';

  /// Liste des notifications (toutes les rôles)
  static const String notifications = '/notifications';

  /// Détail d'une notification (toutes les rôles)
  static const String notificationDetail = '/notifications/detail';
}

// ─────────────────────────────────────────────────────────────────────────────
// Page affichée en cas d'accès refusé
// ─────────────────────────────────────────────────────────────────────────────
class AccessDeniedPage extends StatelessWidget {
  final String reason;
  const AccessDeniedPage({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Color(0xFFFFB000),
              ),
              const SizedBox(height: 24),
              const Text(
                'Accès refusé',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouteNames.login,
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB000),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Se connecter',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Routeur principal — AppRoutes
// ─────────────────────────────────────────────────────────────────────────────
class AppRoutes {
  AppRoutes._();

  // ── Redirige les constantes pour rétrocompatibilité ───────────────────────
  // (évite de casser les fichiers qui utilisaient encore AppRoutes.landing etc.)
  static const String landing = AppRouteNames.landing;
  static const String login = AppRouteNames.login;
  static const String register = AppRouteNames.register;
  static const String verification = AppRouteNames.verification;
  static const String forgetPassword = AppRouteNames.forgetPassword;
  static const String createAccount = AppRouteNames.createAccount;
  static const String roleSelection = AppRouteNames.roleSelection;
  static const String notifications = AppRouteNames.notifications;
  static const String notificationDetail = AppRouteNames.notificationDetail;

  // Routes Freelance (rétrocompatibilité)
  static const String freelanceHome = FreelanceRouteNames.home;
  static const String freelanceDashboard = FreelanceRouteNames.dashboard;
  static const String freelanceApplications = FreelanceRouteNames.applications;
  static const String freelanceProfile = FreelanceRouteNames.profile;
  static const String freelanceJobDetailPage = FreelanceRouteNames.jobDetail;

  // Routes Client (rétrocompatibilité)
  static const String clientHome = ClientRouteNames.home;
  static const String clientMissions = ClientRouteNames.missions;
  static const String clientProfile = ClientRouteNames.profile;
  static const String dashboard = ClientRouteNames.dashboard;
  static const String createMission = ClientRouteNames.createMission;
  static const String missionDetail = ClientRouteNames.missionDetail;

  // ────────────────────────────────────────────────────────────────────────────
  // generateRoute — Délègue dans l'ordre :
  //   1. Routes publiques (gérées ici)
  //   2. Routes Freelance  →  FreelanceRoutes.generate()
  //   3. Routes Client     →  ClientRoutes.generate()
  //   4. Routes Admin      →  AdminRoutes.generate()
  //   5. Fallback 404
  // ────────────────────────────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // ── 1. Routes Publiques ──────────────────────────────────────────────────
    switch (settings.name) {
      case AppRouteNames.landing:
        return MaterialPageRoute(
          builder: (_) => const LandingView(),
          settings: settings,
        );

      case AppRouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRouteNames.register:
      case AppRouteNames.createAccount:
        return MaterialPageRoute(
          builder: (_) {
            final role = settings.arguments as String? ?? 'client';
            return CreateAccountPage(role: role);
          },
          settings: settings,
        );

      case AppRouteNames.verification:
        return MaterialPageRoute(
          builder: (_) {
            final email = settings.arguments as String? ?? '';
            return VerificationPage(email: email);
          },
          settings: settings,
        );

      case AppRouteNames.forgetPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgetPasswordPage(),
          settings: settings,
        );

      case AppRouteNames.roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionPage(),
          settings: settings,
        );

      case AppRouteNames.notifications:
        return MaterialPageRoute(
          builder: (_) => const ListeNotificationView(),
          settings: settings,
        );

      case AppRouteNames.notificationDetail:
        return MaterialPageRoute(
          builder: (_) => const DetailleNotificationView(),
          settings: settings,
        );
    }

    // ── 2. Délégation aux sous-routeurs par rôle ─────────────────────────────
    final freelanceRoute = FreelanceRoutes.generate(settings);
    if (freelanceRoute != null) return freelanceRoute;

    final clientRoute = ClientRoutes.generate(settings);
    if (clientRoute != null) return clientRoute;

    final adminRoute = AdminRoutes.generate(settings);
    if (adminRoute != null) return adminRoute;

    // ── 3. Fallback : aliases legacy & routes en développement ───────────────
    switch (settings.name) {
      case '/tasks':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Mes Missions')),
            body: const Center(
              child: Text('Page des missions (En développement)'),
            ),
          ),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Profil')),
            body: const Center(
              child: Text('Page de profil (En développement)'),
            ),
          ),
          settings: settings,
        );

      // ── 4. Erreur 404 ───────────────────────────────────────────────────────
      default:
        return MaterialPageRoute(
          builder: (ctx) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Page introuvable',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aucune route définie pour "${settings.name}"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      ctx,
                      AppRouteNames.landing,
                      (r) => false,
                    ),
                    child: const Text('Retour à l\'accueil'),
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
}
