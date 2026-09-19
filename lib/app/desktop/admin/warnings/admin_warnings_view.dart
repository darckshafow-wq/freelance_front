import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AdminWarningsView extends StatefulWidget {
  const AdminWarningsView({super.key});

  @override
  State<AdminWarningsView> createState() => _AdminWarningsViewState();
}

class _AdminWarningsViewState extends State<AdminWarningsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchSystemWarnings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final warnings = controller.systemWarnings;

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
                  const Text('Alertes & Sécurité', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Incidents détectés par le système de surveillance', style: TextStyle(color: Colors.white38, fontSize: 14)),
                ],
              ),
              IconButton(
                onPressed: () => controller.fetchSystemWarnings(), 
                icon: const Icon(Icons.sync_rounded, color: AppColors.primaryGold, size: 28)
              ),
            ],
          ),
          const SizedBox(height: 48),
          
          Expanded(
            child: controller.isLoading && warnings.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _buildWarningsList(controller, warnings),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsList(AdminController controller, List<dynamic> warnings) {
    if (warnings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline_rounded, color: Colors.green.withValues(alpha: 0.2), size: 80),
            const SizedBox(height: 24),
            const Text('Tout va bien ! Aucune alerte active.', style: TextStyle(color: Colors.white24, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: warnings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final w = warnings[index];
        final bool isResolved = w['is_resolved'] ?? false;
        final type = w['warning_type'] ?? 'SECURITY';
        final date = DateTime.tryParse(w['created_at'] ?? '') ?? DateTime.now();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isResolved ? Colors.green.withValues(alpha: 0.1) : AppColors.errorRed.withValues(alpha: 0.1)),
            boxShadow: isResolved ? null : [
              BoxShadow(color: AppColors.errorRed.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isResolved ? Colors.green.withValues(alpha: 0.1) : AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isResolved ? Icons.verified_user_rounded : Icons.warning_rounded, 
                  color: isResolved ? Colors.green : AppColors.errorRed,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(type.toString().replaceAll('_', ' '), 
                          style: TextStyle(color: isResolved ? Colors.green : AppColors.errorRed, fontWeight: FontWeight.w900, fontSize: 13)),
                        const SizedBox(width: 12),
                        Text(DateFormat('dd/MM HH:mm').format(date), 
                          style: const TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(w['description'] ?? '', 
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              if (!isResolved)
                ElevatedButton(
                  onPressed: () async {
                    final success = await controller.resolveWarning(w['id']);
                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alerte marquée comme résolue'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating)
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('IGNORER / RÉSOUDRE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                )
              else
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
            ],
          ),
        ).animate().fadeIn(delay: (index * 60).ms).slideY(begin: 0.1);
      },
    );
  }
}
