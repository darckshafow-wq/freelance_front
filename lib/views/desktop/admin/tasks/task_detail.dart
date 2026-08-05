import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/admin/admin_controller.dart';
import '../../../../models/client/task_model.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminTaskDetail extends StatefulWidget {
  final int taskId;
  const AdminTaskDetail({super.key, required this.taskId});

  @override
  State<AdminTaskDetail> createState() => _AdminTaskDetailState();
}

class _AdminTaskDetailState extends State<AdminTaskDetail> {
  final AdminController _controller = AdminController();
  TaskModel? _task;
  bool _localLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.fetchTasks();
    if (mounted) {
      setState(() {
        _task = _controller.tasks.firstWhere(
          (t) => t.id == widget.taskId,
          orElse: () => _controller.tasks.first,
        );
        _localLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminDesktopScaffold(
      selectedIndex: 2,
      title: 'Mission Information',
      body: _localLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _task == null
          ? const Center(
              child: Text(
                'Mission not found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildMainDetails()),
                      const SizedBox(width: 30),
                      Expanded(flex: 1, child: _buildSideDetails()),
                    ],
                  ),
                  const SizedBox(height: 50),
                  _buildActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MISSION #${_task!.id}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _task!.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildStatusBadge(_task!.status),
      ],
    );
  }

  Widget _buildMainDetails() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _task!.description,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 40),
          Divider(color: Colors.white.withValues(alpha: 0.05)),
          const SizedBox(height: 40),
          Row(
            children: [
              _infoTile(
                'Assigned To',
                'No Expert Assigned',
                Icons.person_search_rounded,
              ),
              const SizedBox(width: 30),
              _infoTile(
                'Post Date',
                _task!.createdAt?.toString().split(' ')[0] ?? 'N/A',
                Icons.calendar_today_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideDetails() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Budget & Timeline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              _sideInfoItem(
                'Budget',
                '${_task!.budget.toStringAsFixed(0)} F',
                Icons.payments_rounded,
                Colors.green,
              ),
              _sideInfoItem(
                'Deadline',
                _task!.deadline != null
                    ? '${_task!.deadline!.day}/${_task!.deadline!.month}/${_task!.deadline!.year}'
                    : 'Flexible',
                Icons.timer_rounded,
                Colors.orange,
              ),
              _sideInfoItem(
                'Location',
                _task!.location ?? 'Remote',
                Icons.location_on_rounded,
                Colors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF14142B),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Client Info',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Client ID',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      Text(
                        '#${_task!.clientId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        if (_task!.status == TaskStatus.pending)
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final success = await _controller.updateTaskStatus(
                  _task!.id,
                  'validated',
                );
                if (success) _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'APPROVE MISSION',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: const Icon(
            Icons.delete_forever_rounded,
            color: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideInfoItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
