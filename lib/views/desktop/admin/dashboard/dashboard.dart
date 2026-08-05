import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/admin/admin_controller.dart';
import '../../../../routes/admin_routes.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<AdminController>();
      controller.fetchDashboardStats();
      controller.fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminController = context.watch<AdminController>();

    return AdminDesktopScaffold(
      selectedIndex: 0,
      title: 'Performance Overview',
      body: adminController.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 30),
                  _buildStatsGrid(adminController),
                  const SizedBox(height: 30),
                  _buildChartsRow(adminController),
                  const SizedBox(height: 30),
                  _buildBottomRow(adminController),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, Admin',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Here is what happening with your platform today.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900]!,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              SizedBox(width: 10),
              Text(
                'Real-time Data',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminController controller) {
    final stats = controller.stats;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Users',
            stats?.users.total.toString() ?? '0',
            Icons.people_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Validated Missions',
            stats?.tasks.validated.toString() ?? '0',
            Icons.rocket_launch_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Pending Apps',
            stats?.applications.pending.toString() ?? '0',
            Icons.assignment_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            'Messages',
            stats?.messages.total.toString() ?? '0',
            Icons.message_rounded,
            AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 25),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsRow(AdminController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 380,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(child: _buildLineChart(controller)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 25),
        Expanded(
          flex: 1,
          child: Container(
            height: 380,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              children: [
                const Text(
                  'Health Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRadialGauge(controller),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(controller.stats?.percentages.siteActivity ?? 0).toStringAsFixed(0)}%',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Activity',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(AdminController controller) {
    final history = controller.stats?.activityHistory ?? [];
    List<FlSpot> spots = [];
    if (history.isEmpty) {
      spots = const [FlSpot(0, 0)];
    } else {
      for (int i = 0; i < history.length; i++) {
        spots.add(FlSpot(i.toDouble(), history[i].tasks.toDouble()));
      }
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < history.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      history[index].name,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialGauge(AdminController controller) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 75,
        startDegreeOffset: 180,
        sections: [
          PieChartSectionData(
            color: AppColors.primary,
            value: controller.stats?.percentages.siteActivity ?? 70,
            radius: 15,
            showTitle: false,
          ),
          PieChartSectionData(
            color: Colors.white10,
            value: 100 - (controller.stats?.percentages.siteActivity ?? 70),
            radius: 15,
            showTitle: false,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(AdminController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latest Missions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildTable(controller),
              ],
            ),
          ),
        ),
        const SizedBox(width: 25),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Log',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _logItem('API Check', 'Successful', Colors.green),
                _logItem('Database Backup', 'Scheduled', Colors.blue),
                _logItem('Security Scan', 'In Progress', Colors.orange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _logItem(String title, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(AdminController controller) {
    final tasks = controller.tasks;
    if (tasks.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No missions found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.2),
        4: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          children: [
            _tableHeader('ID'),
            _tableHeader('TITLE'),
            _tableHeader('BUDGET'),
            _tableHeader('STATUS'),
            _tableHeader(''),
          ],
        ),
        ...tasks
            .take(5)
            .map(
              (task) => TableRow(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
                children: [
                  _tableCell('#${task.id}'),
                  _tableCell(task.title),
                  _tableCell('${task.budget.toStringAsFixed(0)} F'),
                  _tableCell(task.status.name.toUpperCase()),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: IconButton(
                      icon: const Icon(
                        Icons.visibility,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AdminRouteNames.taskDetail,
                        arguments: task.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
