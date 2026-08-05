import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/client/application_controller.dart';
import '../../../../models/freelance/application_model.dart';
import '../../../../routes/client_routes.dart';
import '../../../../utils/ui/ui_utils.dart';

class ClientApplicationsView extends StatefulWidget {
  const ClientApplicationsView({super.key});

  @override
  State<ClientApplicationsView> createState() => _ClientApplicationsViewState();
}

class _ClientApplicationsViewState extends State<ClientApplicationsView> {
  ApplicationStatus _selectedStatus = ApplicationStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientApplicationController>().fetchApplications();
    });
  }

  List<ApplicationModel> _getFilteredApplications(ClientApplicationController controller) {
    return controller.applications
        .where((application) => application.status == _selectedStatus)
        .toList();
  }

  void _changeStatus(ApplicationStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.interview:
        return 'Entretien';
      case ApplicationStatus.accepted:
        return 'Confirmées';
      case ApplicationStatus.rejected:
        return 'Rejetées';
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.interview:
        return const Color(0xFF7C3AED); // violet — phase active
      case ApplicationStatus.accepted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.redAccent;
    }
  }

  Future<void> _handleApplicationDecision(
    int applicationId, {
    required bool accept,
  }) async {
    final controller = context.read<ClientApplicationController>();
    final bool success = accept
        ? await controller.acceptApplication(applicationId)
        : await controller.rejectApplication(applicationId);

    if (!mounted) return;

    if (success) {
      UIUtils.showSuccess(context, 'Candidature ${accept ? 'acceptée' : 'refusée'} avec succès.');
    } else {
      UIUtils.showError(context, controller.errorMessage ?? 'Impossible de modifier le statut.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationController = context.watch<ClientApplicationController>();
    final filteredApplications = _getFilteredApplications(applicationController);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Candidatures',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => applicationController.fetchApplications(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.black),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => applicationController.fetchApplications(),
        color: Colors.black,
        backgroundColor: AppColors.primary,
        child: Builder(
          builder: (context) {
            if (applicationController.isLoading && applicationController.applications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            final statusCounts = {
              ApplicationStatus.pending: applicationController.applications
                  .where((app) => app.status == ApplicationStatus.pending)
                  .length,
              ApplicationStatus.interview: applicationController.applications
                  .where((app) => app.status == ApplicationStatus.interview)
                  .length,
              ApplicationStatus.accepted: applicationController.applications
                  .where((app) => app.status == ApplicationStatus.accepted)
                  .length,
              ApplicationStatus.rejected: applicationController.applications
                  .where((app) => app.status == ApplicationStatus.rejected)
                  .length,
            };

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: ApplicationStatus.values.map((status) {
                        final bool isSelected = status == _selectedStatus;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _changeStatus(status),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 5,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w900
                                          : FontWeight.w700,
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${statusCounts[status] ?? 0}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredApplications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: filteredApplications.length,
                          itemBuilder: (context, index) {
                            final application = filteredApplications[index];
                            return _ApplicationCard(
                              application: application,
                              statusColor: _statusColor(application.status),
                              // Contacter visible si pending OU interview (pas rejected/accepted)
                              onMessageTap: (application.status == ApplicationStatus.pending ||
                                      application.status == ApplicationStatus.interview)
                                  ? () {
                                      Navigator.pushNamed(
                                        context,
                                        ClientRouteNames.chatDetail,
                                        arguments: {
                                          'otherUserId': application.freelancerId,
                                          'otherUserName':
                                              'Freelance #${application.freelancerId}',
                                          'taskId': application.taskId,
                                        },
                                      );
                                    }
                                  : null,
                              // Accept/Reject disponibles uniquement en phase INTERVIEW
                              onAccept:
                                  application.status == ApplicationStatus.interview
                                  ? () => _handleApplicationDecision(
                                      application.id,
                                      accept: true,
                                    )
                                  : null,
                              onReject:
                                  application.status == ApplicationStatus.interview
                                  ? () => _handleApplicationDecision(
                                      application.id,
                                      accept: false,
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.how_to_reg_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          Text(
            'Aucune candidature ${_statusLabel(_selectedStatus).toLowerCase()}',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.statusColor,
    required this.onMessageTap,
    this.onAccept,
    this.onReject,
  });

  final ApplicationModel application;
  final Color statusColor;
  final VoidCallback? onMessageTap; // nullable : null = bouton désactivé
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final title = application.taskTitle ?? 'Mission sans titre';
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Freelance #${application.freelancerId}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${application.proposedBudget.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              application.coverLetter.isNotEmpty
                  ? application.coverLetter
                  : 'Pas de message envoyé.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMessageTap,
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: const Text('Contacter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (application.status == ApplicationStatus.interview) ...[
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.redAccent,
                    onTap: onReject!,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.check_rounded,
                    color: Colors.green,
                    onTap: onAccept!,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        application.status.name.toUpperCase(),
        style: TextStyle(
          color: statusColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}
