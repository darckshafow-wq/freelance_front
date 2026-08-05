import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/client/task_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../../routes/client_routes.dart';
import '../../../shared/widgets/mission_grid_card.dart';
import '../shared/desktop_scaffold.dart';
import '../../../smartphone/client/missions/client_missions_page.dart';
import '../../../smartphone/client/applications/client_applications_view.dart';
import '../../../smartphone/client/profile/client_profile_page.dart';
import 'client_chat_desktop.dart';

class ClientHomeDesktop extends StatefulWidget {
  const ClientHomeDesktop({super.key});

  @override
  State<ClientHomeDesktop> createState() => _ClientHomeDesktopState();
}

class _ClientHomeDesktopState extends State<ClientHomeDesktop> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final taskController = context.watch<TaskController>();

    return DesktopScaffold(
      selectedIndex: _currentIndex,
      isClient: true,
      title: _getTitle(),
      onItemSelected: (index) => setState(() => _currentIndex = index),
      actions: [
        if (_currentIndex == 0)
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, ClientRouteNames.createMission),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nouvelle Mission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
      ],
      body: _buildBody(authController, taskController),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Tableau de Bord';
      case 1: return 'Mes Missions';
      case 2: return 'Candidatures';
      case 3: return 'Messagerie';
      case 4: return 'Mon Profil';
      default: return 'Accueil';
    }
  }

  Widget _buildBody(AuthController auth, TaskController tasks) {
    switch (_currentIndex) {
      case 0: return _buildDashboardTab(tasks);
      case 1: return const ClientMissionsPage();
      case 2: return const ClientApplicationsView();
      case 3: return const ClientChatDesktop();
      case 4: return const ClientProfilePage();
      default: return _buildDashboardTab(tasks);
    }
  }

  Widget _buildDashboardTab(TaskController taskController) {
    if (taskController.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black));
    }

    final tasks = taskController.tasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue sur votre espace Client',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildQuickStats(),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Missions récentes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('Voir tout')),
            ],
          ),
          const SizedBox(height: 20),
          if (tasks.isEmpty)
             const Center(child: Text('Aucune mission publiée pour le moment.'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              itemCount: tasks.length > 4 ? 4 : tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return MissionGridCard(
                  task: task,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/smartphone/client/missions/mission_detail_view',
                    arguments: task.id,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatCard('Missions actives', '12', Icons.work_outline_rounded, Colors.blue),
        const SizedBox(width: 20),
        _buildStatCard('Candidatures', '48', Icons.people_outline_rounded, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Budget engagé', '450k', Icons.payments_outlined, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
