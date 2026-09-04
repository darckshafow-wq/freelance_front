import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/client/freelance_controller.dart';
import 'package:freelance_front/app/smartphone/client/widgets/freelance_card.dart';

class FreelanceDirectoryView extends StatefulWidget {
  const FreelanceDirectoryView({super.key});

  @override
  State<FreelanceDirectoryView> createState() => _FreelanceDirectoryViewState();
}

class _FreelanceDirectoryViewState extends State<FreelanceDirectoryView> {
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Design', 'Dév', 'Marketing', 'Vidéo'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FreelanceController>().fetchFreelances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Top Talents', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<FreelanceController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
             return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }
          return Column(
            children: [
              _buildCategoryFilter(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  itemCount: controller.freelances.length,
                  itemBuilder: (context, index) => FreelanceCard(
                    freelance: controller.freelances[index],
                    index: index,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.deepBlack : Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isSelected ? [] : [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.neutralGray,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
