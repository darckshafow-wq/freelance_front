import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminCategoriesView extends StatefulWidget {
  const AdminCategoriesView({super.key});

  @override
  State<AdminCategoriesView> createState() => _AdminCategoriesViewState();
}

class _AdminCategoriesViewState extends State<AdminCategoriesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchCategories();
    });
  }

  void _showCategoryDialog({int? id, String? initialName}) {
    final nameCtrl = TextEditingController(text: initialName);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEditing ? 'Modifier la catégorie' : 'Nouvelle catégorie', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom de la catégorie',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              final controller = context.read<AdminController>();
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              bool success;
              if (isEditing) {
                success = await controller.updateCategory(id, name, ''); // API might require description, sending empty for now
              } else {
                success = await controller.createCategory(name, '');
              }

              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEditing ? 'Catégorie mise à jour' : 'Catégorie créée'), behavior: SnackBarBehavior.floating)
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
            child: Text(isEditing ? 'ENREGISTRER' : 'CRÉER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final categories = controller.categories;

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catégories de Missions', 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  Text('${categories.length} catégories actives sur la plateforme', 
                    style: const TextStyle(color: Colors.white38, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: const Icon(Icons.add_rounded),
                label: const Text('AJOUTER UNE CATÉGORIE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold, 
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: controller.isLoading && categories.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _buildCategoriesGrid(categories),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(List<dynamic> categories) {
    if (categories.isEmpty) return const Center(child: Text('Aucune catégorie.', style: TextStyle(color: Colors.white24)));

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.category_rounded, color: AppColors.primaryGold, size: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white24, size: 20),
                    onPressed: () => _showCategoryDialog(id: cat.id, initialName: cat.name),
                  ),
                ],
              ),
              const Spacer(),
              Text(cat.name, 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              const Text('Missions variées', style: TextStyle(color: Colors.white24, fontSize: 12)),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
      },
    );
  }
}
