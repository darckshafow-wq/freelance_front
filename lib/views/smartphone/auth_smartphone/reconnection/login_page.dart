import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import 'forget_password_page.dart';
import 'verification_page.dart';
import '../creation/role_selection_page.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../models/auth/user_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Accédez à votre espace en quelques secondes.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.white70,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgetPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });

                                // Import the AuthController & UserModel if not imported at top
                                // We'll add imports at the top
                                final authController = AuthController();
                                dev.log(
                                  '[LoginPage] login() start email=${_emailController.text}',
                                );
                                final success = await authController.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                dev.log(
                                  '[LoginPage] login() result success=$success error=${authController.errorMessage}',
                                );

                                if (!context.mounted) return;

                                if (success) {
                                  final user = authController.currentUser;
                                  final role = user?.role;

                                  // DEBUG
                                  print("=== DEBUG LOGIN ===");
                                  print("User email: ${user?.email}");
                                  print("User role: $role");
                                  print(
                                    "Raw flags - isAdmin: ${user?.isAdmin}, isClient: ${user?.isClient}, isFreel: ${user?.isFreelancer}",
                                  );
                                  print("=====================");

                                  if (user != null && !user.isVerified) {
                                    dev.log(
                                      '[LoginPage] User requires OTP verification role=${user.role} email=${user.email}',
                                    );
                                    // Demande de l'OTP
                                    final otpSent = await authController
                                        .sendOtp(user.email);
                                    dev.log(
                                      '[LoginPage] sendOtp() result otpSent=$otpSent error=${authController.errorMessage}',
                                    );
                                    if (!context.mounted) return;

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VerificationPage(
                                          email: user.email,
                                          authController: authController,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (role == UserRole.client) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/client/home',
                                      (route) => false,
                                      arguments: authController,
                                    );
                                  } else if (role == UserRole.freelancer) {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/freelance/home',
                                      (route) => false,
                                      arguments: authController,
                                    );
                                  } else {
                                    // Admin or other
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/dashboard', // Adjust if you have an admin home
                                      (route) => false,
                                      arguments: authController,
                                    );
                                  }
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                    _errorMessage =
                                        authController.errorMessage ??
                                        'Erreur de connexion';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
