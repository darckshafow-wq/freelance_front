import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminUsersListView extends StatefulWidget {
  const AdminUsersListView({super.key});

  @override
  State<AdminUsersListView> createState() => _AdminUsersListViewState();
}

class _AdminUsersListViewState extends State<AdminUsersListView> {
  String _searchQuery = '';
  String _roleFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchUsers();
    });
  }

  void _showActionDialog(BuildContext context, String action, String userName, Future<bool> Function() onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$action utilisateur', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment $action l\'utilisateur $userName ?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await onConfirm();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('L\'utilisateur $userName a été ${action.toLowerCase()} avec succès.'),
                    backgroundColor: action.contains('uspendre') ? AppColors.errorRed : AppColors.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: action.contains('uspendre') ? AppColors.errorRed : AppColors.successGreen),
            child: Text(action.toUpperCase()),
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
            'Gestion des Utilisateurs',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un utilisateur...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF1C1C1E),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(16)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _roleFilter,
                    dropdownColor: const Color(0xFF1C1C1E),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('Tous les rôles')),
                      DropdownMenuItem(value: 'CLIENT', child: Text('Client')),
                      DropdownMenuItem(value: 'FREELANCE', child: Text('Freelance')),
                    ],
                    onChanged: (v) => setState(() => _roleFilter = v!),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => controller.fetchUsers(),
                icon: const Icon(Icons.refresh),
                label: const Text('Actualiser'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          Expanded(
            child: controller.isLoading
                ? Center(
                    child: const CircularProgressIndicator(color: AppColors.primaryGold)
                        .animate()
                        .fadeIn(duration: 400.ms),
                  )
                : _buildUserTable(controller).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable(AdminController controller) {
    final filteredUsers = controller.users.where((u) {
      final matchesSearch = u.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                          u.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _roleFilter == 'ALL' || u.role == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.02)),
          dataRowMaxHeight: 70,
          columns: const [
            DataColumn(label: Text('NOM', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
            DataColumn(label: Text('EMAIL', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
            DataColumn(label: Text('RÔLE', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
            DataColumn(label: Text('STATUT', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
            DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))),
          ],
          rows: filteredUsers.map((user) {
            return DataRow(cells: [
              DataCell(Text(user.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataCell(Text(user.email, style: const TextStyle(color: Colors.white70))),
              DataCell(_buildRoleBadge(user.role)),
              DataCell(_buildStatusBadge(!user.isSuspended)), 
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(user.isSuspended ? Icons.play_arrow_rounded : Icons.block, color: user.isSuspended ? AppColors.successGreen : AppColors.errorRed),
                    onPressed: () => _showActionDialog(
                      context, 
                      user.isSuspended ? 'Réactiver' : 'Suspendre', 
                      user.fullName,
                      () => user.isSuspended ? controller.activateUser(user.id) : controller.suspendUser(user.id),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                    onPressed: () => context.push('/admin/user/${user.id}'),
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: role == 'CLIENT' ? Colors.blueAccent.withValues(alpha: 0.1) : AppColors.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(role, style: TextStyle(color: role == 'CLIENT' ? Colors.blueAccent : AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.greenAccent.withValues(alpha: 0.1) : AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(isActive ? 'ACTIF' : 'SUSPENDU', style: TextStyle(color: isActive ? Colors.greenAccent : AppColors.errorRed, fontSize: 11, fontWeight: FontWeight.w900)),
    );
  }
}
