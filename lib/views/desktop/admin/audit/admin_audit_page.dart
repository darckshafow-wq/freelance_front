import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/admin/admin_controller.dart';
import '../../../../models/admin/audit_log_model.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminAuditPage extends StatefulWidget {
  const AdminAuditPage({super.key});

  @override
  State<AdminAuditPage> createState() => _AdminAuditPageState();
}

class _AdminAuditPageState extends State<AdminAuditPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAuditLogs();
    });
  }

  Future<void> _loadData() async {
    await context.read<AdminController>().fetchAuditLogs();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();

    return AdminDesktopScaffold(
      selectedIndex: 6,
      title: 'Audit Logs',
      body: adminController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(adminController),
                  const SizedBox(height: 24),
                  _buildRecentLogsCard(adminController),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit trail',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Visualisez les actions récentes des rôles administrateur, client et freelance.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildSummaryCards(AdminController controller) {
    final aggregated = controller.auditLogs?.aggregatedByRole ?? {};
    final roles = aggregated.keys.toList()..sort();

    if (roles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: const Text(
          'Aucune donnée d’audit disponible pour le moment.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: roles.map((role) {
        return SizedBox(
          width: 220,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  aggregated[role].toString(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'actions récentes',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentLogsCard(AdminController controller) {
    final recent = controller.auditLogs?.recent ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest activity',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Aucun événement d’audit n’a encore été enregistré.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, _) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final entry = recent[index];
                return _buildLogTile(entry);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogTile(AuditLogEntry entry) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Icon(Icons.receipt_long_outlined, color: AppColors.primary),
      ),
      title: Text(
        '${entry.method.toUpperCase()} ${entry.path}',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role: ${entry.role.isEmpty ? 'unknown' : entry.role}',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
            Text(
              'User: ${entry.userId ?? 'N/A'} • ${entry.createdAt.toLocal().toString().split('.').first}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          entry.method.toUpperCase(),
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ),
    );
  }
}
