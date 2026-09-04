import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:freelance_front/core/constants/app_colors.dart';

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Stack(
        children: [
          // Image de fond (Partie supérieure)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.65,
            child: Stack(
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=2069&auto=format&fit=crop',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.deepBlack),
                ),
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AppColors.pureWhite,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 40,
                          color: AppColors.deepBlack,
                        ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack).rotate(delay: 200.ms),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'FREEFLOW',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                      const Text(
                        'Freelance Platform',
                        style: TextStyle(
                          color: AppColors.pureWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ).animate().fadeIn(delay: 600.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Carte de contenu (Partie inférieure)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  const Text(
                    'BIENVENUE',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepBlack,
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2),
                  const SizedBox(height: 16),
                  const Text(
                    'Trouvez votre prochaine mission, sentez-vous libre. Où le talent rencontre l\'opportunité.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.neutralGray,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepBlack,
                        foregroundColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Connexion',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.5),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepBlack,
                        side: const BorderSide(color: AppColors.neutralGray, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Inscription',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
