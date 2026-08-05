import 'package:flutter/material.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../routes/app_router.dart';
import 'app_bottom_navigation.dart';

class MainLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final AuthController authController;
  final String currentRoute;
  final Widget? floatingActionButton;

  // Constructeur modernisé
  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    required this.authController,
    required this.currentRoute,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      // AppBar uniquement sur mobile/tablette
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text(title),
              centerTitle: false,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authController.logout();
                    Navigator.pushReplacementNamed(context, AppRouteNames.login);
                  },
                ),
              ],
            ),

      // Pas de bottomNavigationBar natif — on utilise un Stack
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          // Sidebar desktop
          if (isLargeScreen)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AppBottomNavigation(
                authController: authController,
                currentRoute: currentRoute,
              ),
            ),

          Expanded(
            child: Container(
              color: theme.colorScheme.surface,
              child: isLargeScreen
                  ? SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    authController.logout();
                                    Navigator.pushReplacementNamed(context, AppRouteNames.login);
                                  },
                                  icon: Icon(Icons.logout, color: theme.colorScheme.error),
                                  label: Text(
                                    'Déconnexion',
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(child: body),
                        ],
                      ),
                    )
                  // ── Mobile : Stack pour la nav flottante ──────────────
                  : Stack(
                      children: [
                        // Contenu avec padding bas pour que la nav ne recouvre pas
                        Padding(
                          padding: const EdgeInsets.only(bottom: 88),
                          child: body,
                        ),
                        // Nav flottante en bas
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AppBottomNavigation(
                            authController: authController,
                            currentRoute: currentRoute,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
