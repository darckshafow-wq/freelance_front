import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../../controllers/freelance/application_controller.dart';
import '../../../../../models/freelance/application_model.dart';
import '../../../../../routes/freelance_routes.dart'; // Added for navigation
import '../../../../utils/ui/ui_utils.dart';

class FreelanceApplicationsPage extends StatefulWidget {
  const FreelanceApplicationsPage({super.key});

  @override
  State<FreelanceApplicationsPage> createState() =>
      _FreelanceApplicationsPageState();
}

class _FreelanceApplicationsPageState extends State<FreelanceApplicationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationController>().fetchApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationController = context.watch<ApplicationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        title: const Text(
          'Mes demandes',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),

        backgroundColor: const Color(0xFFFDFBF7),
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => applicationController.fetchApplications(),
            icon: const Icon(Icons.refresh, size: 22, color: Colors.black),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          // 1. Chargement initial
          if (applicationController.isLoading && applicationController.applications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          // 2. Erreur
          if (applicationController.errorMessage != null &&
              applicationController.applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      applicationController.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => applicationController.fetchApplications(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Aucun résultat
          if (applicationController.applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aucune candidature',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Vos propositions de missions envoyées apparaîtront ici.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          // 4. Affichage de la liste
          return RefreshIndicator(
            onRefresh: () => applicationController.fetchApplications(),
            color: AppColors.primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: applicationController.applications.length,
              itemBuilder: (context, index) {
                final application = applicationController.applications[index];
                return _ApplicationCard(application: application);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final ApplicationModel application;

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return 'Attribuée';
      case ApplicationStatus.rejected:
        return 'Non retenue';
      case ApplicationStatus.interview:
        return 'Entretien en cours';
      case ApplicationStatus.pending:
        return 'En attente';
    }
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return const Color(0xFF10B981); // Vert moderne
      case ApplicationStatus.rejected:
        return const Color(0xFFEF4444); // Rouge moderne
      case ApplicationStatus.interview:
        return const Color(0xFF7C3AED); // Violet — phase active
      case ApplicationStatus.pending:
        return const Color(0xFFF59E0B); // Orange moderne
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = application.taskTitle ?? 'Mission sans titre';
    final double budgetValue = application.proposedBudget;

    final String statusLabel = _getStatusLabel(application.status);
    final Color statusColor = _getStatusColor(application.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ), // Bordure très douce
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              FreelanceRouteNames.applicationDetail,
              arguments: application,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. En-tête : Badge Statut & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge de statut stylisé
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icône d'informations supplémentaires
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. Section principale (Icône + Titre & Info)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Petite icône d'illustration de dossier pour le design
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.work_outline_rounded,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.7,
                        ),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Titre et ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(
                                0xFF0F172A,
                              ), // Couleur Slate sombre très qualitative
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Candidature #${application.id}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 3. Lettre de motivation (Affiche un extrait si dispo)
                if (application.coverLetter.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      application.coverLetter,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),

                // 4. Section basse : Prix proposé & Icônes d'actions (Messagerie et Détails)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget proposé :',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${budgetValue.toStringAsFixed(0)} F CFA',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Bouton chat : actif si INTERVIEW ou ACCEPTED
                        IconButton(
                          onPressed: (application.status == ApplicationStatus.interview ||
                                  application.status == ApplicationStatus.accepted)
                              ? () {
                                  if (application.clientId != null &&
                                      application.clientId! > 0) {
                                    Navigator.pushNamed(
                                      context,
                                      '/freelance/chat',
                                      arguments: {
                                        'otherUserId': application.clientId,
                                        'otherUserName':
                                            'Client de ${application.taskTitle}',
                                        'taskId': application.taskId,
                                      },
                                    );
                                  }
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Le client doit d\'abord vous contacter pour initier l\'entretien.',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                          icon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color:
                                statusColor, // Applique directement la couleur du statut
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(10),
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Bouton d'action pour voir les détails de la mission
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              FreelanceRouteNames.applicationDetail,
                              arguments: application,
                            );
                          },
                          icon: const Icon(
                            Icons.article_outlined,
                            color: Color(0xFF64748B),
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            padding: const EdgeInsets.all(10),
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
