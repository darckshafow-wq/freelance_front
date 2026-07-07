import 'package:flutter/material.dart';

// Remonter de 4 niveaux pour aller chercher les contrôleurs et constantes
import '../../../../controllers/auth_controller.dart';
import '../../../../constants/app_colors.dart';

class CreateMissionView extends StatefulWidget {
  final AuthController authController;

  const CreateMissionView({super.key, required this.authController});

  @override
  State<CreateMissionView> createState() => _CreateMissionViewState();
}

class _CreateMissionViewState extends State<CreateMissionView> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs de saisie
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  // Fonction pour ouvrir le sélecteur de date natif
  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Limite à 1 an
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  // Soumission du formulaire
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La mission a été créée avec succès ! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context); // Retour au tableau de bord
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création : $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,

      // --- APP BAR ---
      appBar: AppBar(
        title: const Text(
          'Publier une Mission',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),

      // --- FORMULAIRE ---
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Décrivez votre besoin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ 1 : Titre de la mission
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration(
                        hintText: 'Ex: Développeur Full-Stack Laravel/Flutter',
                        labelText: 'Titre de la mission',
                        icon: Icons.assignment_outlined,
                        theme: theme,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer un titre pour la mission';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Champ 2 : Description détaillée
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      decoration: _buildInputDecoration(
                        hintText:
                            'Décrivez précisément les tâches à accomplir, les compétences requises et les livrables attendus...',
                        labelText: 'Description détaillée',
                        icon: Icons.description_outlined,
                        theme: theme,
                      ).copyWith(alignLabelWithHint: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez ajouter une description claire';
                        }
                        if (value.trim().length < 10) {
                          return 'La description est trop courte (10 car. minimum)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Budget & Conditions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Champ 3 : Budget en F CFA
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration(
                        hintText: 'Ex: 150000',
                        labelText: 'Budget (F CFA)',
                        icon: Icons.account_balance_wallet_outlined,
                        theme: theme,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le budget est obligatoire';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0) {
                          return 'Veuillez entrer un montant valide supérieur à 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Champ 4 : Date limite (Deadline)
                    InkWell(
                      onTap: () => _pickDeadline(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: theme.hintColor,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date limite de livraison',
                                    style: TextStyle(
                                      color: theme.hintColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedDeadline == null
                                        ? 'Aucune date sélectionnée (Optionnel)'
                                        : '${_selectedDeadline!.day.toString().padLeft(2, '0')}/${_selectedDeadline!.month.toString().padLeft(2, '0')}/${_selectedDeadline!.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _selectedDeadline == null
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: _selectedDeadline == null
                                          ? theme.hintColor
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: theme.hintColor),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- SECTION BASSE : BOUTON SOUUMISSION CONSTANT ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Publier la mission',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Décoration utilitaire pour uniformiser les champs textuels
  InputDecoration _buildInputDecoration({
    required String hintText,
    required String labelText,
    required IconData icon,
    required ThemeData theme,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: Icon(icon, size: 22),
      filled: true,
      fillColor: theme.colorScheme.surface,
      labelStyle: TextStyle(color: theme.hintColor),
      hintStyle: TextStyle(
        color: theme.hintColor.withValues(alpha: 0.6),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}
