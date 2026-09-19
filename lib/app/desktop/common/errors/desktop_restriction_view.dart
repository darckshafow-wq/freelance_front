import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:provider/provider.dart';

class DesktopRestrictionView extends StatelessWidget {
  const DesktopRestrictionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: SingleChildScrollView( // FIXED OVERFLOW
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phonelink_lock_rounded,
                    color: AppColors.primaryGold,
                    size: 64,
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 40),
                const Text(
                  'Version Desktop en cours',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 16),
                const Text(
                  'Désolé, l\'interface Client et Freelance est optimisée pour une utilisation mobile pour le moment afin de vous garantir la meilleure expérience de suivi en temps réel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.read<AuthController>().logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('RETOUR AU LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
