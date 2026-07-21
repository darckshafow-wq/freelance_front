import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/client/application_controller.dart';
import '../../../../models/freelance/application_model.dart';
import '../../../../routes/client_routes.dart';

class ClientApplicationsView extends StatefulWidget {
  const ClientApplicationsView({super.key});

  @override
  State<ClientApplicationsView> createState() => _ClientApplicationsViewState();
}

class _ClientApplicationsViewState extends State<ClientApplicationsView> {
  final ClientApplicationController _controller = ClientApplicationController();
  ApplicationStatus _selectedStatus = ApplicationStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchApplications();
    });
  }

  List<ApplicationModel> get _filteredApplications {
    return _controller.applications
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
        return 'Postulées';
      case ApplicationStatus.accepted:
        return 'Confirmées';
      case ApplicationStatus.rejected:
        return 'Rejetées';
    }
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return AppColors.warning;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
    }
  }

  Future<void> _handleApplicationDecision(
    int applicationId, {
    required bool accept,
  }) async {
    final bool success = accept
        ? await _controller.acceptApplication(applicationId)
        : await _controller.rejectApplication(applicationId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Candidature ${accept ? 'acceptée' : 'refusée'} avec succès.'
              : _controller.errorMessage ??
                    'Impossible de modifier le statut de la candidature.',
        ),
        backgroundColor: success
            ? AppColors.success
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes candidatures'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _controller.fetchApplications(),
            icon: const Icon(Icons.refresh, size: 22),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _controller.fetchApplications(),
        color: AppColors.primary,
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, child) {
            if (_controller.isLoading && _controller.applications.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              );
            }

            if (_controller.errorMessage != null &&
                _controller.applications.isEmpty) {
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
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _controller.fetchApplications(),
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

            if (_controller.applications.isEmpty) {
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
                          Icons.how_to_reg_outlined,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Aucune candidature reçue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Les candidatures envoyées pour vos missions apparaîtront ici.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }

            final statusCounts = {
              ApplicationStatus.pending: _controller.applications
                  .where((app) => app.status == ApplicationStatus.pending)
                  .length,
              ApplicationStatus.accepted: _controller.applications
                  .where((app) => app.status == ApplicationStatus.accepted)
                  .length,
              ApplicationStatus.rejected: _controller.applications
                  .where((app) => app.status == ApplicationStatus.rejected)
                  .length,
            };

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: ApplicationStatus.values.map((status) {
                    final bool isSelected = status == _selectedStatus;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () => _changeStatus(status),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? _statusColor(status)
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            elevation: isSelected ? 2 : 0,
                            side: BorderSide(color: AppColors.lightBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _statusLabel(status),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${statusCounts[status] ?? 0}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                if (_filteredApplications.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: 56,
                          color: AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Aucune candidature ${_selectedStatus == ApplicationStatus.pending
                              ? 'en attente'
                              : _selectedStatus == ApplicationStatus.accepted
                              ? 'confirmée'
                              : 'rejetée'} pour le moment.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._filteredApplications.map(
                    (application) => _ApplicationCard(
                      application: application,
                      statusColor: _statusColor(application.status),
                      onMessageTap: () {
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
                      },
                      onAccept: application.status == ApplicationStatus.pending
                          ? () => _handleApplicationDecision(
                              application.id,
                              accept: true,
                            )
                          : null,
                      onReject: application.status == ApplicationStatus.pending
                          ? () => _handleApplicationDecision(
                              application.id,
                              accept: false,
                            )
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
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
  final VoidCallback onMessageTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  String _statusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'En attente';
      case ApplicationStatus.accepted:
        return 'Confirmée';
      case ApplicationStatus.rejected:
        return 'Rejetée';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = application.taskTitle ?? 'Mission sans titre';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Freelance #${application.freelancerId}',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.55),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(application.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${application.proposedBudget.toStringAsFixed(0)} F CFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              application.coverLetter.isNotEmpty
                  ? application.coverLetter
                  : 'Pas de message envoyé.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMessageTap,
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (application.status == ApplicationStatus.pending)
              const SizedBox(height: 12),
            if (application.status == ApplicationStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Refuser'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Accepter'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
