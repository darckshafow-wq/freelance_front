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

    final authController = context.read<AuthController>();
    final success = await authController.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (success && mounted) {
      context.pushNamed(RouteNames.otpVerification, extra: {
        'email': _emailController.text.trim(),
        'type': 'verification',
      });
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
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Sign In', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign Up', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900)).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                const Text('Créez votre compte pour rejoindre l\'élite du freelancing.', style: TextStyle(color: Colors.black54, fontSize: 14)).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Role Selector
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.softWhite, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            _roleButton('CLIENT'),
                            _roleButton('FREELANCE'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _mobileTextField(_nameController, 'Nom complet', Icons.person_outline_rounded),
                      const SizedBox(height: 20),
                      _mobileTextField(_emailController, 'Email', Icons.email_outlined),
                      const SizedBox(height: 20),
                      _mobileTextField(_passwordController, 'Mot de passe', Icons.lock_outline_rounded, isPassword: true),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: authController.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: authController.isLoading
                              ? const CircularProgressIndicator(color: AppColors.primaryGold)
                              : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ).animate().fadeIn(delay: 400.ms).scale(),
                    ],
                  ),
                ),
              ),
            ).animate().slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutQuart),
          ),
        ],
      ),
    );
  }

  Widget _roleButton(String role) {
    final active = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
          ),
          alignment: Alignment.center,
          child: Text(role, style: TextStyle(color: active ? Colors.black : Colors.grey, fontWeight: FontWeight.w900, fontSize: 13)),
        ),
      ),
    );
  }

  Widget _mobileTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPassword = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.black12),
        suffixIcon: isPassword 
          ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.black12), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) 
          : null,
        filled: true,
        fillColor: AppColors.softWhite,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
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
          width: 1000, height: 750,
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
                        const Text('Sign Up 👋', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
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
                    child: Image.network('https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=2070&auto=format&fit=crop', fit: BoxFit.cover, height: double.infinity),
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
          TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 16),
          TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 16),
          TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _handleRegister, child: const Text('Create Account')),
        ],
      ),
    );
  }
}
