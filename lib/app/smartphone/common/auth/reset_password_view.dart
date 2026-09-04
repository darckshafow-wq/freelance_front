import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';

import 'package:freelance_front/core/widgets/app_text_field.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleReset() {
    // Simuler le succès et rediriger vers le login
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe réinitialisé avec succès !')),
    );
    context.goNamed(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Nouveau mot de passe',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepBlack,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 12),
              const Text(
                'Créez un nouveau mot de passe sécurisé pour votre compte.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.neutralGray,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),

              // New Password
              AppTextField(
                controller: _passwordController,
                label: 'Nouveau mot de passe',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.neutralGray,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 20),

              // Confirm Password
              AppTextField(
                controller: _confirmController,
                label: 'Confirmer le mot de passe',
                prefixIcon: Icons.lock_reset_outlined,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.neutralGray,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlack,
                    foregroundColor: AppColors.primaryGold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(),
            ],
          ),
        ),
      ),
    );
  }
}
