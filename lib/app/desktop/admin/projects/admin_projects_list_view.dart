import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminProjectsListView extends StatefulWidget {
  const AdminProjectsListView({super.key});

  @override
  State<AdminProjectsListView> createState() => _AdminProjectsListViewState();
}

class _AdminProjectsListViewState extends State<AdminProjectsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchProjects();
    });
  }

  void _confirmDelete(BuildContext context, int projectId, String title, AdminController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer la mission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment supprimer la mission "$title" ? Cette action est irréversible.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await controller.deleteProject(projectId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mission supprimée avec succès.'),
                    backgroundColor: AppColors.errorRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion des Missions',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 32),
          Expanded(
            child: controller.isLoading
                ? Center(
                    child: const CircularProgressIndicator(color: AppColors.primaryGold)
                        .animate()
                        .fadeIn(duration: 400.ms),
                  )
                : _buildProjectGrid(controller),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(AdminController controller) {
    if (controller.projects.isEmpty) {
      return const Center(child: Text('Aucune mission trouvée', style: TextStyle(color: Colors.white54)));
    }
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.6,
      ),
      itemCount: controller.projects.length,
      itemBuilder: (context, index) {
        final p = controller.projects[index];
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: p.status),
                  Text('#${p.id}', style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
              const Spacer(),
              Text(
                p.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.localisation ?? 'Non spécifié',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${p.budget.toInt()} FCFA',
                  style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.errorRed, size: 22),
                    onPressed: () => _confirmDelete(context, p.id, p.title, controller),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueAccent, size: 22),
                    onPressed: () => context.push('/admin/project/${p.id}'),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.1);
      },
    );
  }
}
