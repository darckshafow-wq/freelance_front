import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'admin_broadcast_view.dart';

class AdminBroadcastsListView extends StatefulWidget {
  const AdminBroadcastsListView({super.key});

  @override
  State<AdminBroadcastsListView> createState() => _AdminBroadcastsListViewState();
}

class _AdminBroadcastsListViewState extends State<AdminBroadcastsListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchBroadcasts();
    });
  }

  void _openCreatePopup() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (context) => const AdminBroadcastView(isDialog: true),
    );

    if (success == true && mounted) {
      context.read<AdminController>().fetchBroadcasts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final broadcasts = controller.broadcasts;

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
                  const Text('Historique des Diffusions', 
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Annonces et notifications groupées envoyées', 
                    style: TextStyle(color: Colors.white38, fontSize: 14)),
                ],
              ).animate().fadeIn().slideX(begin: -0.1),
              ElevatedButton.icon(
                onPressed: _openCreatePopup,
                icon: const Icon(Icons.add_rounded),
                label: const Text('NOUVELLE DIFFUSION', style: TextStyle(fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(),
            ],
          ),
          const SizedBox(height: 48),
          Expanded(
            child: controller.isLoading && broadcasts.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _buildBroadcastsList(broadcasts),
          ),
        ],
      ),
    );
  }

  Widget _buildBroadcastsList(List<dynamic> broadcasts) {
    if (broadcasts.isEmpty) return const Center(child: Text('Aucune diffusion envoyée.', style: TextStyle(color: Colors.white24)));

    return ListView.separated(
      itemCount: broadcasts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final b = broadcasts[index];
        final date = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime.now();
        final target = b['target'] ?? 'ALL';

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
                  color: _getTargetColor(target).withValues(alpha: 0.1), 
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.campaign_rounded, color: _getTargetColor(target)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(b['title'] ?? 'Sans titre', 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTargetColor(target).withValues(alpha: 0.1), 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(target, 
                            style: TextStyle(color: _getTargetColor(target), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(b['content'] ?? '', 
                      style: const TextStyle(color: Colors.white54, fontSize: 14), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('dd MMM yyyy').format(date), 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(DateFormat('HH:mm').format(date), 
                    style: const TextStyle(color: Colors.white24, fontSize: 12)),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05);
      },
    );
  }

  Color _getTargetColor(String target) {
    switch (target) {
      case 'CLIENT': return Colors.blueAccent;
      case 'FREELANCE': return AppColors.primaryGold;
      default: return Colors.purpleAccent;
    }
  }
}
