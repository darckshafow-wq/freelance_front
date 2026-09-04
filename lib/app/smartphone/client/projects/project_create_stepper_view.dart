import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/widgets/app_text_field.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class ProjectCreateStepperView extends StatefulWidget {
  const ProjectCreateStepperView({super.key});

  @override
  State<ProjectCreateStepperView> createState() => _ProjectCreateStepperViewState();
}

class _ProjectCreateStepperViewState extends State<ProjectCreateStepperView> {
  int _currentStep = 0;
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _categoryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _localisationController = TextEditingController();
  DateTime? _executionDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _categoryController.dispose();
    _skillsController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Créer une mission', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.deepBlack),
          onPressed: () => context.go(RouteNames.clientDashboard),
        ),
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = _currentStep >= index;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryGold : AppColors.softWhite,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Décrivez votre besoin', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Un titre précis attire les meilleurs freelances.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _titleController,
          label: 'Titre de la mission',
          hintText: 'Ex. Refonte d’un tableau de bord mobile',
          prefixIcon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: 32),
        const Text('Catégorie', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AppTextField(
          controller: _categoryController,
          label: 'Catégorie',
          hintText: 'Ex. Design, Développement...',
          prefixIcon: Icons.category_outlined,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _localisationController,
          label: 'Localisation',
          hintText: 'Ex. Paris 15e ou à distance',
          prefixIcon: Icons.location_on_outlined,
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Le résultat attendu', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Expliquez le contexte et les livrables attendus.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _descriptionController,
          label: 'Description détaillée',
          hintText: 'Décrivez votre besoin...',
          prefixIcon: Icons.description_outlined,
          maxLines: 7,
        ),
        const SizedBox(height: 32),
        const Text('Compétences recherchées', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AppTextField(
          controller: _skillsController,
          label: 'Compétences',
          hintText: 'Ex. Flutter, Python...',
          prefixIcon: Icons.psychology_outlined,
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget et publication', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Indiquez le budget total de la mission.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _budgetController,
          label: 'Budget total (€)',
          hintText: 'Ex. 1500',
          prefixIcon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined, color: AppColors.primaryGold),
          title: const Text('Date de fin souhaitée', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w700)),
          subtitle: Text(_formatDate(_executionDate ?? _defaultExecutionDate)),
          trailing: const Icon(Icons.chevron_right),
          onTap: _selectExecutionDate,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primaryGold),
              SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Une fois publiée, votre mission sera visible par tous les freelances du réseau.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFF0F2F5)))),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 56,
                child: TextButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Précédent', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (!_validateCurrentStep()) return;
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _submit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlack,
                  foregroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(_currentStep == 2 ? 'Publier la Mission' : 'Suivant', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    final message = switch (_currentStep) {
      0 when _titleController.text.trim().isEmpty || _categoryController.text.trim().isEmpty || _localisationController.text.trim().isEmpty => 'Ajoutez un titre, une catégorie et une localisation.',
      1 when _descriptionController.text.trim().isEmpty => 'Ajoutez une description de la mission.',
      2 when (double.tryParse(_budgetController.text.trim()) ?? 0) <= 0 => 'Saisissez un budget supérieur à zéro.',
      _ => null,
    };
    if (message == null) return true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    return false;
  }

  void _submit() async {
    final project = ProjectModel(
      id: 0,
      title: _titleController.text,
      description: _descriptionController.text,
      status: 'OPEN',
      executionDate: _executionDate ?? _defaultExecutionDate,
      localisation: _localisationController.text.trim(),
      budget: double.tryParse(_budgetController.text) ?? 0.0,
      category: _categoryController.text,
      skills: _skillsController.text.split(','),
      proposalsCount: 0,
    );

    final success = await context.read<ProjectController>().createProject(project);
    if (success && mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission publiée avec succès !')));
    }
  }

  Future<void> _selectExecutionDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _executionDate ?? _defaultExecutionDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected != null && mounted) setState(() => _executionDate = selected);
  }

  DateTime get _defaultExecutionDate => DateTime.now().add(const Duration(days: 30));

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
