import 'package:flutter/material.dart';
import '../../../controllers/auth_controller.dart';
import 'app_bottom_navigation.dart.dart';

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
      // L'AppBar s'affiche uniquement sur mobile/tablette
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text(title),
              centerTitle: false,
              elevation: 0,
              actions: [
                // Bouton déconnexion rapide dans l'AppBar sur Mobile
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authController.logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            ),

      // 2. AJOUT DE LA BOTTOM NAVIGATION SUR MOBILE UNIQUEMENT
      bottomNavigationBar: isLargeScreen
          ? null // Rien en bas sur ordinateur
          : AppBottomNavigation(
              authController: authController,
              currentRoute: currentRoute,
            ),

      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          // Sidebar persistante uniquement pour les grands écrans
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

          // Contenu principal de la page
          Expanded(
            child: Container(
              // Correction au passage: 'background' est obsolète, on utilise 'surface'
              color: theme.colorScheme.surface,
              child: isLargeScreen
                  ? SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Barre de titre haut de page (Desktop) avec déconnexion
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
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                                // Bouton déconnexion version Desktop
                                TextButton.icon(
                                  onPressed: () {
                                    authController.logout();
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  icon: Icon(
                                    Icons.logout,
                                    color: theme.colorScheme.error,
                                  ),
                                  label: Text(
                                    'Déconnexion',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
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
                  : body,
            ),
          ),
        ],
      ),
    );
  }
}
