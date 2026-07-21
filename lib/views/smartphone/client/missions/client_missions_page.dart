import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/client/task_controller.dart';
import '../../../../models/client/task_model.dart';
import '../../../../routes/client_routes.dart';

class ClientMissionsPage extends StatefulWidget {
  const ClientMissionsPage({super.key});

  @override
  State<ClientMissionsPage> createState() => _ClientMissionsPageState();
}

class _ClientMissionsPageState extends State<ClientMissionsPage> {
  final TaskController _taskController = TaskController();
  TaskStatus _selectedStatus = TaskStatus.pending;

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_onTaskChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.fetchTasks();
    });
  }

  @override
  void dispose() {
    _taskController.removeListener(_onTaskChanged);
    _taskController.dispose();
    super.dispose();
  }

  void _onTaskChanged() {
    if (mounted) setState(() {});
  }

  List<TaskModel> get _filteredTasks {
    return _taskController.tasks
        .where((task) => task.status == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes missions'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, ClientRouteNames.createMission);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _taskController.fetchTasks(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Mes missions postées',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            _StatusTabBar(
              selectedStatus: _selectedStatus,
              onStatusSelected: (status) {
                setState(() => _selectedStatus = status);
              },
            ),
            const SizedBox(height: 16),
            if (_taskController.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_taskController.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Card(
                  color: AppColors.error.withValues(alpha: 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(
                          _taskController.errorMessage!,
                          style: const TextStyle(color: AppColors.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _taskController.fetchTasks(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_filteredTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_late_outlined,
                      size: 56,
                      color: AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Aucune mission ${_selectedStatus == TaskStatus.pending
                          ? 'en attente'
                          : _selectedStatus == TaskStatus.validated
                          ? 'validée'
                          : 'terminée'} pour le moment.',
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
              ..._filteredTasks.map(
                (task) => _MissionCard(
                  title: task.title,
                  status: _statusLabel(task.status),
                  count:
                      '${task.assignedToId != null ? 'Assignée' : 'Non assignée'}',
                  budget: task.budget,
                  deadline: task.deadline,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ClientRouteNames.missionDetail,
                      arguments: task.id,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.validated:
        return 'Validée';
      case TaskStatus.executed:
        return 'Terminée';
    }
  }
}

class _StatusTabBar extends StatelessWidget {
  const _StatusTabBar({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: TaskStatus.values.map((status) {
        final bool isSelected = status == selectedStatus;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              onPressed: () => onStatusSelected(status),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? AppColors.primary : Colors.white,
                foregroundColor: isSelected
                    ? Colors.white
                    : AppColors.lightTextPrimary,
                elevation: isSelected ? 2 : 0,
                side: BorderSide(color: AppColors.lightBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _label(status),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'En attente';
      case TaskStatus.validated:
        return 'Validées';
      case TaskStatus.executed:
        return 'Terminées';
    }
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.status,
    required this.count,
    required this.budget,
    required this.deadline,
    required this.onTap,
  });

  final String title;
  final String status;
  final String count;
  final double budget;
  final DateTime? deadline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
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
                    status,
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${budget.toStringAsFixed(0)} F CFA',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count,
                    style: const TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (deadline != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${deadline!.day.toString().padLeft(2, '0')}/${deadline!.month.toString().padLeft(2, '0')}/${deadline!.year}',
                          style: const TextStyle(
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
