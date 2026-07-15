// ─────────────────────────────────────────────────────────────────────────────
// admin_routes.dart
// Toutes les routes réservées aux utilisateurs avec le rôle "Admin".
//
// Convention de nommage : toutes les constantes commencent par `/admin/`
// Note : Les vues admin seront créées au fur et à mesure.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

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
    switch (settings.name) {
      // ── Tableau de bord Admin ─────────────────────────────────────────────
      case AdminRouteNames.dashboard:
        return _guardRoute(
          settings: settings,
          builder: () => const _AdminDashboardPlaceholder(),
        );

      // ── Gestion Utilisateurs ──────────────────────────────────────────────
      case AdminRouteNames.users:
        return _guardRoute(
          settings: settings,
          builder: () => const _AdminPlaceholder(title: 'Gestion Utilisateurs'),
        );

      // ── Gestion Missions ──────────────────────────────────────────────────
      case AdminRouteNames.tasks:
        return _guardRoute(
          settings: settings,
          builder: () => const _AdminPlaceholder(title: 'Gestion Missions'),
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
    // TODO : Réactiver la vérification du token et du rôle admin en production.
    // Exemple :
    //   if (ApiClient.currentToken == null) {
    //     return MaterialPageRoute(builder: (_) => const LoginPage());
    //   }
    //   final role = /* récupérer le rôle depuis le store */;
    //   if (role != UserRole.admin) {
    //     return MaterialPageRoute(
    //       builder: (_) => const _AccessDeniedPage(reason: 'Réservé aux administrateurs'),
    //     );
    //   }
    return MaterialPageRoute(builder: (_) => builder(), settings: settings);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets temporaires (placeholders) — à remplacer par les vraies vues admin
// ─────────────────────────────────────────────────────────────────────────────

class _AdminDashboardPlaceholder extends StatelessWidget {
  const _AdminDashboardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 64, color: Color(0xFFFFB000)),
            SizedBox(height: 16),
            Text(
              'Tableau de bord Admin',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Vue en cours de développement',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  final String title;
  const _AdminPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF2D2D2D),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '$title — En développement',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
