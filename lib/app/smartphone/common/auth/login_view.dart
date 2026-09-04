import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      if (authController.currentUser?.role == 'CLIENT') {
        context.go('/client/dashboard');
      } else if (authController.currentUser?.role == 'FREELANCER') {
        context.go('/projects'); // La route correcte vers le dashboard freelance
      } else {
        context.go('/admin/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // App Name
                Center(
                  child: Text(
                    'FreeFlow',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGold,
                      letterSpacing: 1,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 48),

                // Welcome Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Bienvenue sur',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutralGray,
                        ),
                      ),
                      Text(
                        'FreeFlow, connectez-vous !',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepBlack,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),

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
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    color: AppColors.deepBlack,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'exemple@email.com',
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
                  ),
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
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                  style: const TextStyle(
                    color: AppColors.deepBlack,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
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
                const SizedBox(height: 12),

                // Remember me + Forgot password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                            activeColor: AppColors.primaryGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: const BorderSide(color: AppColors.neutralGray),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Se souvenir de moi',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutralGray,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to forgot password
                      },
                      child: const Text(
                        'Mot de passe oubli\u00e9 ?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGold,
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

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: authController.isLoading ? null : _handleLogin,
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
                            'Connexion',
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

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ? ',
                      style: TextStyle(
                        color: AppColors.neutralGray,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: const Text(
                        'S\'inscrire',
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
