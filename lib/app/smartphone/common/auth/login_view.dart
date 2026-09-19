import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/auth_controller.dart';
import 'package:freelance_front/core/routes/route_names.dart';

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
      } else if (authController.currentUser?.role == 'FREELANCE') {
        context.go('/freelance/dashboard');
      } else {
        context.go('/admin/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    if (isDesktop) return _buildDesktopLayout();

    return _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    final authController = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: AppColors.primaryGold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pushNamed(RouteNames.register),
            child: const Text('Register', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign In', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5)).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                const Text('Dénichez les meilleurs talents ou proposez vos services en un clic.', 
                  style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600, height: 1.4)).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _mobileTextField(_emailController, 'Username', Icons.person_outline_rounded),
                      const SizedBox(height: 24),
                      _mobileTextField(_passwordController, 'Password', Icons.lock_outline_rounded, isPassword: true),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.pushNamed(RouteNames.forgotPassword),
                          child: const Text('Forgot Password?', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: ElevatedButton(
                          onPressed: authController.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            elevation: 0,
                          ),
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: AppColors.primaryGold)
                              : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(),
                      const SizedBox(height: 48),
                      _socialBtn('Continue with Google', Icons.g_mobiledata_rounded, Colors.redAccent),
                      const SizedBox(height: 16),
                      _socialBtn('Continue with Facebook', Icons.facebook_rounded, Colors.blueAccent),
                    ],
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0, duration: 800.ms, curve: Curves.easeOutQuart),
          ),
        ],
      ),
    );
  }

  Widget _mobileTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black12, fontWeight: FontWeight.w900),
        prefixIcon: Icon(icon, color: Colors.black12, size: 22),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black12), 
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) 
          : null,
        filled: true,
        fillColor: AppColors.softWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
      ),
    );
  }

  Widget _socialBtn(String label, IconData icon, Color color) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87, fontSize: 14))),
          const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.black12),
        ],
      ),
    );
  }

  // --- PREVIOUS DESKTOP LAYOUT ---
  Widget _buildDesktopLayout() {
    final authController = context.watch<AuthController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B14),
      body: Center(
        child: Container(
          width: 1000, height: 700,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back 👋', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 40),
                        _buildDesktopForm(authController),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network('https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=2064&auto=format&fit=crop', fit: BoxFit.cover, height: double.infinity),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopForm(AuthController authController) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _handleLogin, child: const Text('Log In')),
        ],
      ),
    );
  }
}
