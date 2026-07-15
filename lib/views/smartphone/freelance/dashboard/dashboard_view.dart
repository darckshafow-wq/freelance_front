import 'package:flutter/material.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../../controllers/client/task_controller.dart';
import '../../../../constants/app_colors.dart';
import '../../../../models/client/task_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/main_layout.dart';

class DashboardView extends StatefulWidget {
  final AuthController authController;

  const DashboardView({super.key, required this.authController});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final TaskController _taskController = TaskController();

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_onTaskStateChanged);
    
    // Fetch tasks on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.fetchTasks();
    });
  }

  @override
  void dispose() {
    _taskController.removeListener(_onTaskStateChanged);
    super.dispose();
  }

  void _onTaskStateChanged() {
    if (mounted) setState(() {});
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.validated:
        return AppColors.success;
      case TaskStatus.executed:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.validated:
        return 'Validé';
      case TaskStatus.executed:
        return 'Exécuté';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.authController.currentUser;
    final userName = user?.fullName ?? 'Utilisateur';
    final userRole = user?.role.name.toUpperCase() ?? 'FREELANCE';

    return MainLayout(
      title: 'Tableau de Bord',
      authController: widget.authController,
      currentRoute: '/dashboard',
      body: RefreshIndicator(
        onRefresh: () => _taskController.fetchTasks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Card (Header)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, $userName',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Section title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Missions Disponibles',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _taskController.fetchTasks(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualiser'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Task List State Handling
              if (_taskController.isLoading)
                const SizedBox(
                  height: 200,
                  child: LoadingIndicator(message: 'Chargement des missions...'),
                )
              else if (_taskController.errorMessage != null)
                Card(
                  color: theme.colorScheme.error.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          _taskController.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _taskController.fetchTasks(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_taskController.tasks.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late_outlined, size: 48, color: theme.disabledColor),
                      const SizedBox(height: 12),
                      const Text(
                        'Aucune mission trouvée pour le moment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _taskController.tasks.length,
                  itemBuilder: (context, index) {
                    final task = _taskController.tasks[index];
                    final statusColor = _getStatusColor(task.status);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          // View detail placeholder
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getStatusLabel(task.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.payments_outlined, size: 18, color: theme.colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${task.budget.toStringAsFixed(0)} €',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (task.deadline != null)
                                    Text(
                                      'Échéance : ${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
