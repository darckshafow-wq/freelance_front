import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/app/smartphone/client/widgets/mission_card.dart';

class ClientProjectListView extends StatefulWidget {
  const ClientProjectListView({super.key});

  @override
  State<ClientProjectListView> createState() => _ClientProjectListViewState();
}

class _ClientProjectListViewState extends State<ClientProjectListView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchClientProjects();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Mes Missions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepBlack,
          unselectedLabelColor: AppColors.neutralGray,
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(width: 4, color: AppColors.primaryGold),
            borderRadius: BorderRadius.circular(2),
            insets: const EdgeInsets.symmetric(horizontal: 40),
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Ouvertes'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: Consumer<ProjectController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }

          if (controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(controller.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.fetchClientProjects(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProjectList(controller.clientProjects.where((p) => ['ACTIVE', 'IN_PROGRESS'].contains(p.status.toUpperCase())).toList()),
              _buildProjectList(controller.clientProjects.where((p) => p.status.toUpperCase() == 'OPEN').toList()),
              _buildProjectList(controller.clientProjects.where((p) => p.status.toUpperCase() == 'COMPLETED').toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProjectList(List<ProjectModel> projects) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.neutralGray.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text('Aucun projet trouvé.', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: projects.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: MissionCard(project: projects[index], index: index, showImage: false, isClientMission: true),
      ),
    );
  }
}
