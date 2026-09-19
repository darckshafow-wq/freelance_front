import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final reports = controller.reports;

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Signalements & Litiges',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              IconButton(
                onPressed: () => controller.fetchReports(),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: controller.isLoading && reports.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _buildReportsList(controller, reports),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList(AdminController controller, List<dynamic> reports) {
    if (reports.isEmpty) {
      return const Center(child: Text('Aucun signalement en att.ente', style: TextStyle(color: Colors.white24)));
    }

    return ListView.separated(
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final r = reports[index];
        final bool isResolved = r['resolved'] ?? false;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isResolved ? Colors.green.withValues(alpha: 0.1) : AppColors.errorRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isResolved ? Icons.check_circle_outline : Icons.report_problem_outlined,
                  color: isResolved ? Colors.green : AppColors.errorRed,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['reason'] ?? 'Signalement sans motif', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Signalé par: User #${r['reporter_id']}', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(r['description'] ?? 'Pas de description supplémentaire', style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              const Spacer(),
              if (!isResolved)
                ElevatedButton(
                  onPressed: () => _resolveReport(r['id'], controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('RÉSOUDRE'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _resolveReport(int id, AdminController controller) async {
    final success = await controller.resolveReport(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signalement marqué comme résolu.')));
    }
  }
}
