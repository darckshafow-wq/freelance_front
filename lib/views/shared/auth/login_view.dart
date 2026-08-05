import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../utils/validators.dart';
import '../../../utils/ui/ui_utils.dart';
import '../../../routes/app_router.dart';
import '../../../routes/freelance_routes.dart';
import '../../../models/auth/user_model.dart';
import '../../smartphone/onbor/landing_transition_page.dart'; 
import 'custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = context.read<AuthController>();
      final success = await authController.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;

      if (success) {
        final role = authController.currentUser?.role ?? UserRole.client;
        Navigator.pushReplacementNamed(
          context,
          resolveRedirectRoute(role),
        );
      } else if (authController.errorMessage != null) {
        UIUtils.showError(context, authController.errorMessage!);
      }
    } else {
      UIUtils.showInfo(context, 'Veuillez compléter tous les champs correctement.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding
                  Icon(
                    Icons.work_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Freelance Platform',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous à votre espace personnel',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Fields
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Adresse e-mail',
                    hintText: 'exemple@domaine.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: 'Se connecter',
                    isLoading: authController.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 12),

                  // Bypass Buttons for Layout Testing
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/client/home',
                          );
                        },
                        child: const Text('Aperçu Client'),
                      ),
                      const Text('|'),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            FreelanceRouteNames.dashboard,
                          );
                        },
                        child: const Text('Aperçu Freelance'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Register Redirection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nouveau sur la plateforme ?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouteNames.register);
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
