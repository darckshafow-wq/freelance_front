import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/core/services/client/project_service.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';
import 'package:freelance_front/app/smartphone/client/popup/client_dialogs.dart';
import 'package:go_router/go_router.dart';

class ClientProjectDetailView extends StatefulWidget {
  final String id;
  final bool isClientMission;

  const ClientProjectDetailView({super.key, required this.id, this.isClientMission = false});

  @override
  State<ClientProjectDetailView> createState() => _ClientProjectDetailViewState();
}

class _ClientProjectDetailViewState extends State<ClientProjectDetailView> {
  late final Future<ProjectModel> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = ProjectService().getProjectById(int.tryParse(widget.id) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Détail de la mission', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Retour',
          onPressed: () => context.go(widget.isClientMission ? RouteNames.clientProjects : RouteNames.clientDashboard),
        ),
      ),
      body: FutureBuilder<ProjectModel>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _buildErrorState();
          }
          return _buildDetails(snapshot.data!);
        },
      ),
      bottomNavigationBar: FutureBuilder<ProjectModel>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildStickyBottomBar(snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetails(ProjectModel project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: project.status),
                const SizedBox(height: 18),
                Text(
                  project.title,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.15),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _buildHeaderInfo(Icons.payments_outlined, '${project.budget.toInt()}€', 'Budget'),
                    const SizedBox(width: 28),
                    _buildHeaderInfo(Icons.event_outlined, _formatDate(project.executionDate), 'Échéance'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.08),
          const SizedBox(height: 28),
          _buildSectionTitle('Description'),
          const SizedBox(height: 10),
          Text(
            project.description,
            style: const TextStyle(color: AppColors.neutralGray, fontSize: 15, height: 1.55),
          ).animate().fadeIn(delay: 120.ms),
          const SizedBox(height: 28),
          _buildSectionTitle('Compétences recherchées'),
          const SizedBox(height: 12),
          if (project.skills.isEmpty)
            const Text('Aucune compétence renseignée.', style: TextStyle(color: AppColors.neutralGray))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: project.skills.map(_buildSkill).toList(),
            ).animate().fadeIn(delay: 220.ms),
          if (widget.isClientMission && !['COMPLETED', 'CANCELLED'].contains(project.status.toUpperCase())) ...[
            const SizedBox(height: 100), // Espace pour ne pas cacher le contenu derrière la bottom bar
          ],
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProjectModel project) {
    if (!widget.isClientMission || ['COMPLETED', 'CANCELLED'].contains(project.status.toUpperCase())) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (['ACTIVE', 'IN_PROGRESS'].contains(project.status.toUpperCase()))
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showCloseTaskDialog(context, project.title);
                  if (confirmed && context.mounted) {
                    final validated = await ProjectService().validateProject(project.id);
                    if (!validated || !context.mounted) return;
                    final review = await showReviewDialog(context, 'le freelance');
                    if (review != null) {
                      await ProjectService().submitReview(
                        targetId: project.id,
                        rating: review['rating'] as int,
                        comment: review['comment'] as String,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Clôturer la mission', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.successGreen,
                  side: const BorderSide(color: AppColors.successGreen, width: 2),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (['ACTIVE', 'IN_PROGRESS'].contains(project.status.toUpperCase())) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                'clientProjectProposals',
                pathParameters: {'id': project.id.toString()},
                queryParameters: {'title': project.title},
              ),
              icon: const Icon(Icons.people_outline_rounded),
              label: const Text('Voir mes propositions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlack,
                foregroundColor: AppColors.primaryGold,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: AppColors.primaryGold.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGold),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                const SizedBox(height: 3),
                Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w800));
  }

  Widget _buildSkill(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutralGray.withValues(alpha: 0.12)),
      ),
      child: Text(skill, style: const TextStyle(color: AppColors.deepBlack, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.neutralGray),
            const SizedBox(height: 12),
            const Text('Mission introuvable', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Cette mission n’est plus disponible.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutralGray)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
