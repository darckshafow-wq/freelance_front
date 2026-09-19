import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminAuditLogsView extends StatefulWidget {
  const AdminAuditLogsView({super.key});

  @override
  State<AdminAuditLogsView> createState() => _AdminAuditLogsViewState();
}

class _AdminAuditLogsViewState extends State<AdminAuditLogsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final logs = controller.auditLogs;

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
                  const Text(
                    'Journaux d\'Audit',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suivi en temps réel des actions sensibles sur la plateforme',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => controller.fetchAuditLogs(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('ACTUALISER LES LOGS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          
          Expanded(
            child: controller.isLoading && logs.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
                    ),
                    child: logs.isEmpty
                        ? const Center(child: Text('Aucun log trouvé', style: TextStyle(color: Colors.white24)))
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(32),
                              itemCount: logs.length,
                              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 48),
                              itemBuilder: (context, index) {
                                final log = logs[index];
                                final action = log['action'] ?? 'ACTION_INCONNUE';
                                final details = log['details'] ?? 'Pas de détails fournis';
                                final date = DateTime.tryParse(log['created_at'] ?? '') ?? DateTime.now();
                                final targetType = log['target_type'] ?? 'N/A';

                                return ExpansionTile(
                                  backgroundColor: Colors.white.withValues(alpha: 0.01),
                                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                                  leading: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getActionColor(action).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(_getActionIcon(action), color: _getActionColor(action), size: 20),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        action.replaceAll('_', ' '),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          targetType,
                                          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    DateFormat('dd MMM yyyy - HH:mm:ss').format(date),
                                    style: const TextStyle(color: Colors.white24, fontSize: 12),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(72, 0, 32, 24),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white10),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('DÉTAILS DE L\'ACTION', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                            const SizedBox(height: 12),
                                            Text(
                                              details,
                                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5, fontFamily: 'monospace'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05);
                              },
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    if (action.contains('SUSPEND') || action.contains('DELETE') || action.contains('FAIL') || action.contains('DISPUTE')) return AppColors.errorRed;
    if (action.contains('VERIFY') || action.contains('SUCCESS') || action.contains('CREATE') || action.contains('ACTIVATE')) return Colors.greenAccent;
    if (action.contains('BROADCAST') || action.contains('REPLY')) return Colors.blueAccent;
    return Colors.amberAccent;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('SUSPEND')) return Icons.block_flipped;
    if (action.contains('DELETE')) return Icons.delete_sweep_rounded;
    if (action.contains('LOGIN')) return Icons.vpn_key_rounded;
    if (action.contains('VERIFY')) return Icons.verified_user_rounded;
    if (action.contains('CREATE')) return Icons.add_circle_outline_rounded;
    if (action.contains('BROADCAST')) return Icons.campaign_rounded;
    if (action.contains('REPLY')) return Icons.reply_all_rounded;
    return Icons.security_rounded;
  }
}
