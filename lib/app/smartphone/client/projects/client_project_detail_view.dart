import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';
import 'package:freelance_front/app/smartphone/client/popup/client_dialogs.dart';
import 'package:go_router/go_router.dart';

class ClientProjectDetailView extends StatefulWidget {
  final String id;
  final bool isClientMission;
  final ProjectModel? project;

  const ClientProjectDetailView({super.key, required this.id, this.isClientMission = false, this.project});

  @override
  State<ClientProjectDetailView> createState() => _ClientProjectDetailViewState();
}

class _ClientProjectDetailViewState extends State<ClientProjectDetailView> {
  late Future<ProjectModel> _projectFuture;

  @override
  void initState() {
    super.initState();
    _refreshProject();
  }

  void _refreshProject() {
    setState(() {
      if (widget.project != null) {
        _projectFuture = Future.value(widget.project!);
      } else {
        _projectFuture = ProjectService().getProjectById(int.tryParse(widget.id) ?? 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Ma Mission', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.deepBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<ProjectModel>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryGold),
                  const SizedBox(height: 16),
                  Text('Récupération des données...', style: TextStyle(color: AppColors.neutralGray, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) return _buildErrorState();
          return _buildDetails(snapshot.data!);
        },
      ),
      bottomNavigationBar: FutureBuilder<ProjectModel>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData && widget.isClientMission) {
            return _buildStickyBottomBar(snapshot.data!);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetails(ProjectModel project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: project.status),
                const SizedBox(height: 20),
                Text(project.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildHeaderInfo(Icons.payments_outlined, project.budget > 0 ? '${project.budget.toInt()} FCFA' : 'À définir', 'Budget'),
                    const SizedBox(width: 20),
                    _buildHeaderInfo(Icons.event_outlined, _formatDate(project.executionDate), 'Prévu le'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05),
          const SizedBox(height: 32),
          const Text('Localisation', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${project.district?.name ?? ""}, ${project.city?.name ?? ""}, ${project.country?.name ?? ""}',
                  style: const TextStyle(color: AppColors.neutralGray, fontSize: 15),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 32),
          const Text('Description de la mission', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(project.description, style: const TextStyle(color: AppColors.neutralGray, fontSize: 15, height: 1.6)).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          Text(project.description, style: const TextStyle(color: AppColors.neutralGray, fontSize: 15, height: 1.6)).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 32),
          const Text('Compétences requises', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (project.skills.isEmpty)
            const Text('Aucune compétence spécifique.', style: TextStyle(color: AppColors.neutralGray))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.skills.map(_buildSkill).toList(),
            ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProjectModel project) {
    final bool canClose = ['FINISHED'].contains(project.status.toUpperCase());
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canClose) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showCloseTaskDialog(context, project.title);
                  if (confirmed && context.mounted) {
                    try {
                      await ProjectService().validateProject(project.id);
                      if (context.mounted) {
                        final review = await showReviewDialog(context, 'le freelance');
                        if (review != null) {
                          await ProjectService().submitReview(
                            targetId: project.id,
                            rating: review['rating'] as int,
                            comment: review['comment'] as String,
                          );
                        }
                        _refreshProject();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission validée avec succès')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: \$e')));
                      }
                    }
                  }
                },
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Valider & Clôturer', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.successGreen,
                  side: const BorderSide(color: AppColors.successGreen, width: 2),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (['OPEN', 'IN_PROGRESS'].contains(project.status.toUpperCase()))
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.pushNamed(
                  'clientProjectProposals',
                  pathParameters: {'id': project.id.toString()},
                  queryParameters: {'title': project.title},
                ),
                icon: const Icon(Icons.people_outline_rounded),
                label: const Text('VOIR LES PROPOSITIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlack,
                  foregroundColor: AppColors.primaryGold,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: AppColors.primaryGold.withValues(alpha: 0.3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryGold),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildSkill(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralGray.withValues(alpha: 0.1)),
      ),
      child: Text(skill, style: const TextStyle(color: AppColors.deepBlack, fontSize: 13, fontWeight: FontWeight.w800)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.neutralGray),
          const SizedBox(height: 16),
          const Text('Erreur de chargement', style: TextStyle(fontWeight: FontWeight.bold)),
          TextButton(onPressed: _refreshProject, child: const Text('Réessayer')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
