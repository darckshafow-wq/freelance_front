import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/widgets/app_text_field.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/models/common/location_model.dart';
import 'package:freelance_front/core/models/admin/category_model.dart';
import 'package:freelance_front/core/services/common/location_service.dart';
import 'package:freelance_front/core/services/common/upload_service.dart';
import 'package:freelance_front/core/services/client/project_service.dart';

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
  final _skillsController = TextEditingController();
  
  DateTime? _executionDate;
  
  // Data
  List<CountryModel> _countries = [];
  List<CityModel> _cities = [];
  List<DistrictModel> _districts = [];
  List<CategoryModel> _categories = [];
  
  CategoryModel? _selectedCategory;
  CountryModel? _selectedCountry;
  CityModel? _selectedCity;
  DistrictModel? _selectedDistrict;
  
  bool _isLoadingData = true;
  File? _imageFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _executionDate = DateTime.now().add(const Duration(days: 30));
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final results = await Future.wait([
        LocationService().getCountries(),
        ProjectService().getClientCategories(),
      ]);
      
      _countries = results[0] as List<CountryModel>;
      _categories = results[1] as List<CategoryModel>;
      
      if (_countries.length == 1) {
        _onCountryChanged(_countries.first);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _onCountryChanged(CountryModel? country) async {
    setState(() {
      _selectedCountry = country;
      _selectedCity = null;
      _selectedDistrict = null;
      _cities = [];
      _districts = [];
      _isLoadingData = true;
    });
    if (country != null) {
      try {
        _cities = await LocationService().getCities(country.id);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _onCityChanged(CityModel? city) async {
    setState(() {
      _selectedCity = city;
      _selectedDistrict = null;
      _districts = [];
      _isLoadingData = true;
    });
    if (city != null) {
      try {
        _districts = await LocationService().getDistricts(city.id);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    if (mounted) setState(() => _isLoadingData = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _skillsController.dispose();
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
      body: Stack(
        children: [
          Column(
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
          if (_isSubmitting)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primaryGold)),
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
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Le projet', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Définissez les bases de votre besoin.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _titleController,
          label: 'Titre de la mission',
          hintText: 'Ex. Installation climatisation',
          prefixIcon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: 32),
        const Text('Catégorie', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_isLoadingData && _categories.isEmpty)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<CategoryModel>(
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.softWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryGold),
            ),
            value: _selectedCategory,
            hint: const Text('Choisir une catégorie'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
        const SizedBox(height: 32),
        const Text('Localisation', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_isLoadingData && _countries.isEmpty)
          const Center(child: CircularProgressIndicator())
        else ...[
          DropdownButtonFormField<CountryModel>(
            decoration: InputDecoration(
              labelText: 'Pays',
              filled: true,
              fillColor: AppColors.softWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.public, color: AppColors.primaryGold),
            ),
            value: _selectedCountry,
            items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
            onChanged: _onCountryChanged,
          ),
          const SizedBox(height: 16),
          if (_selectedCountry != null)
            DropdownButtonFormField<CityModel>(
              decoration: InputDecoration(
                labelText: 'Ville',
                filled: true,
                fillColor: AppColors.softWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.location_city, color: AppColors.primaryGold),
              ),
              value: _selectedCity,
              items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: _onCityChanged,
            ),
          const SizedBox(height: 16),
          if (_selectedCity != null)
            DropdownButtonFormField<DistrictModel>(
              decoration: InputDecoration(
                labelText: 'Quartier',
                filled: true,
                fillColor: AppColors.softWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.map, color: AppColors.primaryGold),
              ),
              value: _selectedDistrict,
              items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d.name))).toList(),
              onChanged: (val) => setState(() => _selectedDistrict = val),
            ),
        ],
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Détails & Photos', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Expliquez le contexte et les livrables attendus.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _descriptionController,
          label: 'Description détaillée',
          hintText: 'Décrivez votre besoin précisément...',
          prefixIcon: Icons.description_outlined,
          maxLines: 7,
        ),
        const SizedBox(height: 32),
        
        const Text('Photo descriptive (Optionnelle)', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        InkWell(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neutralGray.withValues(alpha: 0.1)),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.neutralGray),
                      SizedBox(height: 8),
                      Text('Ajouter une photo', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 32),

        const Text('Compétences requises', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        AppTextField(
          controller: _skillsController,
          label: 'Mots-clés (ex: Peinture, Électricité)',
          hintText: 'Séparez par des virgules',
          prefixIcon: Icons.psychology_outlined,
        ),
      ],
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget et planification', style: TextStyle(color: AppColors.deepBlack, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Dernière étape avant la publication.', style: TextStyle(color: AppColors.neutralGray)),
        const SizedBox(height: 32),
        AppTextField(
          controller: _budgetController,
          label: 'Budget indicatif (FCFA)',
          hintText: 'Ex. 50000',
          prefixIcon: Icons.payments_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(color: AppColors.softWhite, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const Icon(Icons.event_outlined, color: AppColors.primaryGold),
            title: const Text('Date d’exécution', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w700)),
            subtitle: Text(_formatDate(_executionDate ?? DateTime.now())),
            trailing: const Icon(Icons.calendar_month_rounded, color: AppColors.neutralGray),
            onTap: _selectExecutionDate,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryGold.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primaryGold),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Votre mission sera instantanément notifiée aux freelances qualifiés dans votre zone.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.deepBlack, height: 1.4),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 60,
                child: TextButton(
                  onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                  child: const Text('RETOUR', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 60,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : () {
                  if (!_validateCurrentStep()) return;
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _submit();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_currentStep == 0 && (_selectedCountry == null || _selectedCity == null || _selectedDistrict == null)) 
                      ? Colors.grey.withValues(alpha: 0.3) 
                      : AppColors.deepBlack,
                  foregroundColor: AppColors.primaryGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(_currentStep == 2 ? 'PUBLIER MAINTENANT' : 'CONTINUER', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    final message = switch (_currentStep) {
      0 when _titleController.text.trim().isEmpty || _selectedCategory == null => 'Titre et catégorie requis.',
      0 when _selectedCountry == null || _selectedCity == null || _selectedDistrict == null => 'Veuillez sélectionner le pays, la ville ET le quartier.',
      1 when _descriptionController.text.trim().isEmpty => 'Une description est nécessaire.',
      _ => null,
    };
    if (message == null) return true;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.errorRed, behavior: SnackBarBehavior.floating));
    return false;
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await UploadService().uploadImage(_imageFile!);
      }

      final project = ProjectModel(
        id: 0,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: 'OPEN',
        executionDate: _executionDate ?? DateTime.now(),
        countryId: _selectedCountry?.id,
        cityId: _selectedCity?.id,
        districtId: _selectedDistrict?.id,
        latitude: _selectedDistrict?.latitude ?? _selectedCity?.latitude,
        longitude: _selectedDistrict?.longitude ?? _selectedCity?.longitude,
        imageUrl: imageUrl,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        category: _selectedCategory?.name,
        categoryId: _selectedCategory?.id,
        skills: _skillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        proposalsCount: 0,
      );

      final success = await context.read<ProjectController>().createProject(project);
      if (success && mounted) {
        context.go(RouteNames.clientDashboard);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission publiée avec succès !'), backgroundColor: AppColors.successGreen));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}'), backgroundColor: AppColors.errorRed));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _selectExecutionDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _executionDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (selected != null && mounted) setState(() => _executionDate = selected);
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
