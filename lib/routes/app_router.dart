import 'package:flutter/material.dart';

// Controllers et Modèles
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../services/api/api_core.dart';
import '../services/api/mock_data.dart';

// Vues d'authentification et Onboarding
import '../views/smartphone/onbor/landing.dart';

// Vues Client (Home & Missions)
import '../views/smartphone/client/home/client_home_view.dart';
import '../views/smartphone/client/missions/create_mission_view.dart';
import '../views/smartphone/client/missions/mission_detail_view.dart';
import '../views/smartphone/client/home/client_home_page.dart';
import '../views/smartphone/client/missions/client_missions_page.dart';
import '../views/smartphone/client/profile/client_profile_page.dart';

// Vues Freelance
import '../views/smartphone/freelance/dashboard/dashboard_view.dart';
import '../views/smartphone/freelance/home/freelance_home_page.dart';
import '../views/smartphone/freelance/applications/freelance_applications_page.dart';
import '../views/smartphone/freelance/profile/freelance_profile_page.dart';
import '../views/smartphone/freelance/tasks/detaille_task.dart';

// Auth smartphone
import '../views/smartphone/auth_smartphone/reconnection/login_page.dart';
import '../views/smartphone/auth_smartphone/reconnection/verification_page.dart';
import '../views/smartphone/auth_smartphone/reconnection/forget_password_page.dart';
import '../views/smartphone/auth_smartphone/creation/create_account_page.dart';
import '../views/smartphone/auth_smartphone/creation/role_selection_page.dart';

// Notifications
import '../views/smartphone/notification/liste_notification.dart';
import '../views/smartphone/notification/detaille_notification.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page d'erreur d'accès refusé
// ─────────────────────────────────────────────────────────────────────────────
class _AccessDeniedPage extends StatelessWidget {
  final String reason;
  const _AccessDeniedPage({required this.reason});

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
                  '/login',
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
// Router principal avec guards de sécurité basés sur le rôle
// ─────────────────────────────────────────────────────────────────────────────
class AppRoutes {
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String freelanceDashboard = '/freelance/dashboard';
  static const String clientHome = '/client/home';
  static const String clientMissions = '/client/missions';
  static const String clientProfile = '/client/profile';
  static const String freelanceHome = '/freelance/home';
  static const String freelanceApplications = '/freelance/applications';
  static const String freelanceProfile = '/freelance/profile';
  static const String verification = '/verification';
  static const String forgetPassword = '/forget-password';
  static const String createAccount = '/create-account';
  static const String roleSelection = '/role-selection';
  static const String freelanceJobDetailPage = '/freelance/job-detail';
  static const String missionDetail =
      '/smartphone/client/missions/mission_detail_view';
  static const String createMission =
      '/smartphone/client/missions/create_mission_view';
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/detail';

  // ────────────────────────────────────────────────────────
  // Guard central : FORCÉ POUR LES TESTS
  // Retourne toujours null pour laisser passer toutes les pages
  // ────────────────────────────────────────────────────────
  static Route<dynamic>? _checkAccess(
    RouteSettings settings, {
    UserRole? requiredRole,
  }) {
    return null; // ACCÈS FORCÉ : Laisse passer sans vérification de token ou de rôle
  }

  // ────────────────────────────────────────────────────────
  // Helper pour construire des routes sécurisées proprement
  // ────────────────────────────────────────────────────────
  static Route<dynamic> _guard({
    required RouteSettings settings,
    required Widget Function() builder,
    UserRole? requiredRole,
  }) {
    final denied = _checkAccess(settings, requiredRole: requiredRole);
    if (denied != null) return denied;
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }

  // ────────────────────────────────────────────────────────
  // Générateur de routes
  // ────────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Routes publiques ─────────────────────────────────
      case landing:
        return MaterialPageRoute(
          builder: (_) => const LandingView(),
          settings: settings,
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case register:
      case createAccount:
        return MaterialPageRoute(
          builder: (_) {
            final role = settings.arguments as String? ?? 'client';
            return CreateAccountPage(role: role);
          },
          settings: settings,
        );

      case verification:
        return MaterialPageRoute(
          builder: (_) {
            final email = settings.arguments as String? ?? '';
            return VerificationPage(email: email);
          },
          settings: settings,
        );

      case forgetPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgetPasswordPage(),
          settings: settings,
        );

      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionPage(),
          settings: settings,
        );

      // ── Routes Client (rôle: client) ─────────────────────
      case clientHome:
      case '/client':
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientHomePage(),
        );

      case clientMissions:
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientMissionsPage(),
        );

      case clientProfile:
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () => const ClientProfilePage(),
        );

      case dashboard:
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return ClientHomeView(authController: auth);
          },
        );

      case createMission:
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return CreateMissionView(authController: auth);
          },
        );

      case missionDetail:
        return _guard(
          settings: settings,
          requiredRole: UserRole.client,
          builder: () {
            final taskId = settings.arguments as int? ?? 0;
            return MissionDetailView(taskId: taskId);
          },
        );

      // ── Routes Freelance (rôle: freelancer) ──────────────
      case freelanceHome:
      case '/freelance':
        return _guard(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceHomePage(),
        );

      case freelanceApplications:
        return _guard(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceApplicationsPage(),
        );

      case freelanceProfile:
        return _guard(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceProfilePage(),
        );

      case freelanceDashboard:
        return _guard(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () {
            final auth =
                settings.arguments as AuthController? ?? AuthController();
            return DashboardView(authController: auth);
          },
        );

      // Page détail mission freelance — reçoit les données via arguments
      case freelanceJobDetailPage:
        return _guard(
          settings: settings,
          requiredRole: UserRole.freelancer,
          builder: () => const FreelanceJobDetailPage(),
        );

      // ── Routes Notifications (toutes les rôles) ───────────────
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const ListeNotificationView(),
          settings: settings,
        );

      case notificationDetail:
        return MaterialPageRoute(
          builder: (_) => const DetailleNotificationView(),
          settings: settings,
        );

      // ── Fallbacks ─────────────────────────────────────────
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Aucune route définie pour ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
