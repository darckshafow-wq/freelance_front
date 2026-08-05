import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/admin/admin_controller.dart';
import '../../../../models/client/task_model.dart';
import '../../../../routes/admin_routes.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';
import '../../../../utils/ui/ui_utils.dart';

class AdminTaskList extends StatefulWidget {
  const AdminTaskList({super.key});

  @override
  State<AdminTaskList> createState() => _AdminTaskListState();
}

class _AdminTaskListState extends State<AdminTaskList> {
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchTasks();
    });
  }

  List<TaskModel> _getFilteredTasks(AdminController controller) {
    if (_filter == 'All') return controller.tasks;
    return controller.tasks
        .where((t) => t.status.name.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();
    final filteredTasks = _getFilteredTasks(adminController);

    return AdminDesktopScaffold(
      selectedIndex: 2,
      title: 'Mission Management',
      actions: [
        _buildFilterChip('All'),
        _buildFilterChip('Pending'),
        _buildFilterChip('Validated'),
        _buildFilterChip('Executed'),
      ],
      body: adminController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(30),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _buildTaskCard(task, adminController);
                },
              ),
            ),
    );
  }

  Widget _buildTaskCard(TaskModel task, AdminController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${task.id}',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              _buildStatusBadge(task.status),
            ],
          ),
          const Spacer(),
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: Colors.grey, size: 16),
              const SizedBox(width: 5),
              Text(
                '${task.budget.toStringAsFixed(0)} F',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.person_rounded, color: Colors.grey, size: 16),
              const SizedBox(width: 5),
              Text(
                'Client ${task.clientId}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AdminRouteNames.taskDetail,
                    arguments: task.id,
                  ),
                  icon: const Icon(Icons.visibility_rounded, size: 18),
                  label: const Text('View Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (task.status == TaskStatus.pending) ...[
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    final success = await controller.updateTaskStatus(task.id, 'validated');
                    if (!mounted) return;
                    if (success) {
                      UIUtils.showSuccess(context, 'Mission #${task.id} approuvée !');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) => setState(() => _filter = label),
        backgroundColor: const Color(0xFF1C1C36),
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatusBadge(TaskStatus status) {
    Color color;
    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        break;
      case TaskStatus.validated:
        color = Colors.green;
        break;
      case TaskStatus.executed:
        color = Colors.blue;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
