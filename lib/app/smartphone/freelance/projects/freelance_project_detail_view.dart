import "package:freelance_front/core/services/freelance/freelance_project_service.dart";
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';

class FreelanceProjectDetailView extends StatefulWidget {
  final String id;
  final ProjectModel? project;

  const FreelanceProjectDetailView({super.key, required this.id, this.project});

  @override
  State<FreelanceProjectDetailView> createState() => _FreelanceProjectDetailViewState();
}

class _FreelanceProjectDetailViewState extends State<FreelanceProjectDetailView> {
  late Future<ProjectModel> _projectFuture;
  final _messageController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _projectFuture = Future.value(widget.project!);
    } else {
      _projectFuture = ProjectService().getProject(int.parse(widget.id));
    }
  }

  void _showApplicationPopup(ProjectModel project) {
    _priceController.text = project.budget.toInt().toString();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Postuler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepBlack)),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Votre offre tarifaire (FCFA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neutralGray)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Budget prévu: ${project.budget.toInt()} FCFA',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: AppColors.softWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.primaryGold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Message / Motivation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neutralGray)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Pourquoi devrions-nous vous choisir ?',
                        hintStyle: const TextStyle(color: Colors.black26),
                        filled: true,
                        fillColor: AppColors.softWhite,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () async {
                          final priceStr = _priceController.text.trim();
                          final message = _messageController.text.trim();
                          if (priceStr.isEmpty || message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir tous les champs')));
                            return;
                          }
                          final price = double.tryParse(priceStr);
                          if (price == null) return;
                          
                          setStateModal(() => _isSubmitting = true);
                          try {
                            final success = await ProjectService().submitProposal(project.id, price, message);
                            if (success && context.mounted) {
                              Navigator.pop(context);
                              _showSuccessPopup();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Fermer le popup de saisie
                              
                              String errorMsg = 'Erreur lors de l\'envoi de la candidature';
                              bool isAlreadyApplied = false;

                              if (e is DioException) {
                                final data = e.response?.data;
                                if (data is Map && data['detail'] != null) {
                                  final detail = data['detail'].toString().toLowerCase();
                                  if (detail.contains('already applied') || 
                                      detail.contains('déjà postulé') ||
                                      detail.contains('already submitted')) {
                                    isAlreadyApplied = true;
                                  }
                                }
                              }

                              if (isAlreadyApplied) {
                                _showAlreadyAppliedPopup();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMsg), backgroundColor: AppColors.errorRed)
                                );
                              }
                            }
                          } finally {
                            if (mounted) setStateModal(() => _isSubmitting = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepBlack,
                          foregroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.primaryGold, strokeWidth: 2)) 
                          : const Text('ENVOYER MON OFFRE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAlreadyAppliedPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryGold, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Déjà postulé', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Vous avez déjà envoyé une proposition pour cette mission. Vous pouvez suivre son avancement dans l\'onglet "Candidatures".', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, height: 1.4)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('OK, J\'AI COMPRIS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Félicitations !', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Votre proposition a été envoyée au client. Vous recevrez une notification s\'il l\'accepte.', 
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop(); // Return to list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepBlack,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('RETOUR AUX MISSIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Détails de la mission', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.deepBlack,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => context.pop()),
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
                  Text('Chargement des détails...', style: TextStyle(color: AppColors.neutralGray, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) return const Center(child: Text('Erreur de chargement de la mission.'));
          return _buildDetails(snapshot.data!);
        },
      ),
      bottomNavigationBar: FutureBuilder<ProjectModel>(
        future: _projectFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final status = snapshot.data!.status.toUpperCase();
            if (status == 'OPEN' || status == 'IN_PROGRESS' || status == 'ARRIVED') {
              return _buildStickyBottomBar(snapshot.data!);
            }
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
                    _buildHeaderInfo(Icons.payments_outlined, project.budget > 0 ? '${project.budget.toInt()} FCFA' : 'À discuter', 'Rémunération'),
                    const SizedBox(width: 20),
                    _buildHeaderInfo(Icons.location_on_outlined, project.localisation ?? 'Distance indisp.', 'Localisation'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05),
          const SizedBox(height: 32),
          const Text('À propos de la mission', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(project.description, style: const TextStyle(color: AppColors.neutralGray, fontSize: 15, height: 1.6)).animate().fadeIn(delay: 100.ms),
          
          if (project.client != null) ...[
            const SizedBox(height: 32),
            const Text('Client', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.1),
                  backgroundImage: project.client!.profile?.avatarUrl != null ? NetworkImage(project.client!.profile!.avatarUrl!) : null,
                  child: project.client!.profile?.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primaryGold) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.client!.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(project.client!.profile?.bio ?? 'Client régulier', style: const TextStyle(color: AppColors.neutralGray, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ],

          const SizedBox(height: 32),
          const Text('Date d\'exécution', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 12),
              Text(_formatDate(project.executionDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          const Text('Compétences', style: TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (project.skills.isEmpty)
            const Text('Aucune compétence spécifique.', style: TextStyle(color: AppColors.neutralGray))
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.skills.map(_buildSkill).toList(),
            ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(ProjectModel project) {
    final status = project.status.toUpperCase();
    String btnLabel = '';
    IconData btnIcon = Icons.send_rounded;
    VoidCallback? onPressed;

    if (status == 'OPEN') {
      btnLabel = 'POSTULER MAINTENANT';
      btnIcon = Icons.send_rounded;
      onPressed = () => _showApplicationPopup(project);
    } else if (status == 'IN_PROGRESS') {
      btnLabel = 'MARQUER COMME ARRIVÉ';
      btnIcon = Icons.location_on_rounded;
      onPressed = () async {
        try {
          await FreelanceProjectService().markAsArrived(project.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Statut mis à jour : Arrivé')));
            setState(() {
              _projectFuture = FreelanceProjectService().getProjectDetail(project.id);
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: \$e')));
          }
        }
      };
    } else if (status == 'ARRIVED') {
      btnLabel = 'MISSION TERMINÉE';
      btnIcon = Icons.check_circle_rounded;
      onPressed = () async {
        try {
          await FreelanceProjectService().markAsFinished(project.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mission marquée comme terminée')));
            setState(() {
              _projectFuture = FreelanceProjectService().getProjectDetail(project.id);
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: \$e')));
          }
        }
      };
    }

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
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(btnIcon, size: 18),
            label: Text(btnLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              shadowColor: AppColors.primaryGold.withValues(alpha: 0.3),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
}
