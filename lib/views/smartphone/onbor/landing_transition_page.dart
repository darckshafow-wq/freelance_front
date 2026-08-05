import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../models/auth/user_model.dart';
import '../../../../routes/admin_routes.dart';
import '../../../../routes/client_routes.dart';
import '../../../../routes/freelance_routes.dart';

class LandingTransitionPage extends StatefulWidget {
  final Future<void> Function() onRestoreSession;
  final void Function(String routeName) onNavigateToRoute;

  const LandingTransitionPage({
    super.key,
    required this.onRestoreSession,
    required this.onNavigateToRoute,
  });

  @override
  State<LandingTransitionPage> createState() => _LandingTransitionPageState();
}

class _LandingTransitionPageState extends State<LandingTransitionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthController>();
      
      // 1. Démarrer la restauration de session
      await widget.onRestoreSession();
      
      // 2. Délai pour le design
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // 3. Résoudre la route basée sur le rôle réel
      final role = auth.currentUser?.role ?? UserRole.client;
      final route = resolveRedirectRoute(role);
      widget.onNavigateToRoute(route);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: AppColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chargement de votre espace de travail...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

String resolveRedirectRoute(UserRole role) {
  // FORCE CLIENT POUR LES TESTS
  return ClientRouteNames.home;
}
