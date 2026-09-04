import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class OtpVerificationView extends StatefulWidget {
  final String email;
  final String type; // 'verification' or 'forgot_password'

  const OtpVerificationView({
    super.key,
    required this.email,
    required this.type,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onVerify() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) return;

    if (widget.type == 'forgot_password') {
      context.pushNamed(RouteNames.resetPassword);
    } else {
      // Inscription réussie -> Dashboard
      context.go('/client/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.deepBlack),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Vérification',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.deepBlack,
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  text: 'Entrez le code à 4 chiffres envoyé à ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.neutralGray,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppColors.deepBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 48),

              // OTP Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 48),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepBlack,
                    foregroundColor: AppColors.primaryGold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Vérifier',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).scale(),

              const SizedBox(height: 32),
              
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Renvoyer le code',
                    style: TextStyle(
                      color: AppColors.deepBlack,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
