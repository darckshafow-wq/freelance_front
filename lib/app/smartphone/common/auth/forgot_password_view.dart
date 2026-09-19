import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/widgets/app_text_field.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    context.pushNamed(
      RouteNames.otpVerification,
      extra: {
        'email': _emailController.text.trim(),
        'type': 'forgot_password',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.softWhite : AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.deepBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            width: isDesktop ? 500 : double.infinity,
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 50 : 32.0),
            decoration: isDesktop ? BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) const SizedBox(height: 50),
                const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepBlack,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 12),
                const Text(
                  'Pas de soucis ! Entrez votre adresse e-mail et nous vous enverrons un code de réinitialisation.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.neutralGray,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 48),

                AppTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  prefixIcon: Icons.email_outlined,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepBlack,
                      foregroundColor: AppColors.primaryGold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Envoyer le code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms).scale(),
                if (isDesktop) const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
