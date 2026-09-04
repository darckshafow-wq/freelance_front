import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String _selectedRole = 'CLIENT';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      context.pushNamed(
        RouteNames.otpVerification,
        extra: {
          'email': _emailController.text.trim(),
          'type': 'verification',
        },
      );
    }
  }

  InputDecoration _fieldDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.neutralGrayDark.withValues(alpha: 0.6),
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.softWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.neutralGrayDark.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryGold,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.deepBlack, size: 20),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'FreeFlow',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryGold,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Title
                const Center(
                  child: Text(
                    'Cr\u00e9er un Compte',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepBlack,
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.1),
                const SizedBox(height: 8),

                // Role Selector
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRoleChip('Client', 'CLIENT'),
                        const SizedBox(width: 4),
                        _buildRoleChip('Freelance', 'FREELANCER'),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),

                // Name Label
                const Text(
                  'Nom',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlack,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.deepBlack, fontSize: 15),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                  decoration: _fieldDecoration(hintText: 'Jean Dupont'),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),
                const SizedBox(height: 20),

                // Email Label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlack,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.deepBlack, fontSize: 15),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                  decoration: _fieldDecoration(hintText: 'exemple@email.com'),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                const SizedBox(height: 20),

                // Password Label
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepBlack,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.deepBlack, fontSize: 15),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Le mot de passe doit faire au moins 6 caract\u00e8res';
                    }
                    return null;
                  },
                  decoration: _fieldDecoration(
                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.neutralGray,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),
                const SizedBox(height: 16),

                // Terms checkbox
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                        activeColor: AppColors.primaryGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        side: const BorderSide(color: AppColors.neutralGray),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          text: 'J\'accepte les ',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutralGray,
                          ),
                          children: [
                            TextSpan(
                              text: 'Conditions d\'utilisation',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 24),

                // Error message
                if (authController.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.errorRed, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authController.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorRed,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authController.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepBlack,
                      foregroundColor: AppColors.primaryGold,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authController.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryGold,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Cr\u00e9er un compte',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
                const SizedBox(height: 28),

                // Or Sign in with
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppColors.neutralGrayDark.withValues(alpha: 0.3)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Ou continuer avec',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutralGray,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppColors.neutralGrayDark.withValues(alpha: 0.3)),
                    ),
                  ],
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 20),

                // Social Login Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.facebook, const Color(0xFF1877F2)),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.g_mobiledata_rounded, AppColors.errorRed),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.apple, AppColors.deepBlack),
                  ],
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

                // Already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'D\u00e9j\u00e0 un compte ? ',
                      style: TextStyle(
                        color: AppColors.neutralGray,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1000.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String label, String role) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryGold : AppColors.neutralGray,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralGrayDark.withValues(alpha: 0.15),
        ),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
