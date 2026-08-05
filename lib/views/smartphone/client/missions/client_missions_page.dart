import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  TaskStatus _selectedStatus = TaskStatus.pending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskController>().fetchTasks();
    });
  }

  List<TaskModel> _getFilteredTasks(TaskController controller) {
    return controller.tasks
        .where((task) => task.status == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskController = context.watch<TaskController>();
    final filteredTasks = _getFilteredTasks(taskController);

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: AppColors.primary,
      onRefresh: () => taskController.fetchTasks(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: _StatusTabBar(
              selectedStatus: _selectedStatus,
              onStatusSelected: (status) {
                setState(() => _selectedStatus = status);
              },
            ),
          ),
          Expanded(
            child: taskController.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  )
                : filteredTasks.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return _MissionCard(
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ClientRouteNames.missionDetail,
                            arguments: task.id,
                          );
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_rounded,
            size: 80,
            color: Colors.grey[200],
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune mission ${_selectedStatus == TaskStatus.pending
                ? 'en attente'
                : _selectedStatus == TaskStatus.validated
                ? 'validée'
                : 'terminée'}',
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

class _StatusTabBar extends StatelessWidget {
  const _StatusTabBar({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: TaskStatus.values.map((status) {
          final bool isSelected = status == selectedStatus;
          return Expanded(
            child: GestureDetector(
              onTap: () => onStatusSelected(status),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _label(status),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 12,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
  const _MissionCard({required this.task, required this.onTap});

  final TaskModel task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildStatusChip(task.status),
                ],
              ),
              const SizedBox(height: 10),
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
                      '${task.budget.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    task.assignedToId != null ? 'Assignée' : 'Non assignée',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.deadline != null
                            ? '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}'
                            : 'Sans date',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.black26,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String label;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        label = 'EN ATTENTE';
        break;
      case TaskStatus.validated:
        color = Colors.green;
        label = 'VALIDÉE';
        break;
      case TaskStatus.executed:
        color = Colors.blue;
        label = 'TERMINÉE';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
