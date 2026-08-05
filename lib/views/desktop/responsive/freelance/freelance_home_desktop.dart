import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/freelance/task_controller.dart';
import '../../../../controllers/freelance/profil_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../shared/widgets/mission_grid_card.dart';
import '../shared/desktop_scaffold.dart';
import '../../../smartphone/freelance/applications/freelance_applications_page.dart';
import '../../../smartphone/freelance/profile/freelance_profile_page.dart';
import 'freelance_chat_desktop.dart';

class FreelanceHomeDesktop extends StatefulWidget {
  const FreelanceHomeDesktop({super.key});

  @override
  State<FreelanceHomeDesktop> createState() => _FreelanceHomeDesktopState();
}

class _FreelanceHomeDesktopState extends State<FreelanceHomeDesktop> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context.read<ProfilController>().loadFullProfile(userId: auth.currentUser!.id);
        context.read<FreelanceTaskController>().fetchHomeTasks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final taskController = context.watch<FreelanceTaskController>();
    final profilController = context.watch<ProfilController>();

    return DesktopScaffold(
      selectedIndex: _currentIndex,
      isClient: false,
      title: _getTitle(),
      onItemSelected: (index) => setState(() => _currentIndex = index),
      body: _buildBody(authController, taskController, profilController),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Tableau de Bord';
      case 1: return 'Mes Demandes';
      case 2: return 'Messagerie';
      case 3: return 'Mon Profil';
      default: return 'Accueil';
    }
  }

  Widget _buildBody(AuthController auth, FreelanceTaskController tasks, ProfilController profil) {
    switch (_currentIndex) {
      case 0: return _buildDashboardTab(tasks, profil);
      case 1: return const FreelanceApplicationsPage();
      case 2: return const FreelanceChatDesktop();
      case 3: return FreelanceProfilePage(userId: auth.currentUser?.id.toString() ?? 'me');
      default: return _buildDashboardTab(tasks, profil);
    }
  }

  Widget _buildDashboardTab(FreelanceTaskController taskController, ProfilController profilController) {
    if (taskController.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    final tasks = taskController.homeTasks;
    final stats = profilController.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Espace Freelance',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          _buildQuickStats(stats),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Missions recommandées',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {}, child: const Text('Toutes les missions')),
            ],
          ),
          const SizedBox(height: 20),
          if (tasks.isEmpty)
             const Center(child: Text('Aucune mission disponible pour le moment.'))
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.4,
              ),
              itemCount: tasks.length > 6 ? 6 : tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return MissionGridCard(
                  task: task,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/freelance/job-detail',
                      arguments: {
                        'id': task.id,
                        'title': task.title,
                        'description': task.description,
                        'budget': '${task.budget.toStringAsFixed(0)} F CFA',
                        'budgetValue': task.budget,
                        'deadline': task.deadline?.toIso8601String(),
                        'clientId': task.clientId,
                        'location': task.location,
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(dynamic stats) {
    return Row(
      children: [
        _buildStatCard('Missions finies', '${stats.tasksDone}', Icons.check_circle_outline_rounded, Colors.green),
        const SizedBox(width: 20),
        _buildStatCard('En cours', '${stats.tasksInProgress}', Icons.hourglass_top_rounded, Colors.orange),
        const SizedBox(width: 20),
        _buildStatCard('Succès', '${stats.successRate}%', Icons.trending_up_rounded, Colors.purple),
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
