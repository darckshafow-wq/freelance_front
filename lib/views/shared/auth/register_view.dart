import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../models/auth/user_model.dart';
import '../../../utils/validators.dart';
import '../../../utils/ui/ui_utils.dart';
import 'custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.freelancer;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authController = context.read<AuthController>();
      final success = await authController.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        role: _selectedRole,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        UIUtils.showSuccess(context, 'Inscription réussie ! Connectez-vous.');
        Navigator.pop(context); // Retour à la vue de connexion
      } else if (authController.errorMessage != null) {
        UIUtils.showError(context, authController.errorMessage!);
      }
    } else {
      UIUtils.showInfo(context, 'Veuillez corriger les champs invalides.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authController = context.watch<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Rejoignez-nous !',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre compte en quelques secondes',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nom complet
                  CustomTextField(
                    controller: _fullNameController,
                    labelText: 'Nom complet',
                    hintText: 'ex: Alice Martin',
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (v) =>
                        Validators.required(v, fieldName: 'Le nom complet'),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Adresse e-mail',
                    hintText: 'exemple@domaine.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // Téléphone (optionnel)
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Téléphone (optionnel)',
                    hintText: 'ex: +33612345678',
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    validator: Validators.phoneNumber,
                  ),
                  const SizedBox(height: 16),

                  // Choix du rôle
                  Text(
                    'Type de profil',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Freelance')),
                          selected: _selectedRole == UserRole.freelancer,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedRole == UserRole.freelancer
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: _selectedRole == UserRole.freelancer
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRole = UserRole.freelancer;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Client')),
                          selected: _selectedRole == UserRole.client,
                          selectedColor: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          labelStyle: TextStyle(
                            color: _selectedRole == UserRole.client
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                            fontWeight: _selectedRole == UserRole.client
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRole = UserRole.client;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mot de passe
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

                  // Bouton d'inscription
                  CustomButton(
                    text: 'Créer mon compte',
                    isLoading: authController.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),

                  // Redirection connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà inscrit ?',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Se connecter',
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
