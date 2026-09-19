import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchOverview();
      if (mounted) {
        Future.delayed(100.ms, () {
          if (mounted) setState(() => _isFirstLoad = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final overview = controller.overview;
    final metrics = overview?['metrics'] ?? {};

    return Container(
      color: const Color(0xFF111111),
      child: controller.isLoading && overview == null
          ? Center(
              child: const CircularProgressIndicator(color: AppColors.primaryGold)
                  .animate()
                  .fadeIn(duration: 400.ms),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header with "Soufflée" Animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pages / Dashboard', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back, Admin!',
                            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                          ).animate(target: _isFirstLoad ? 0 : 1).fadeIn(duration: 800.ms).slideY(begin: 0.1, curve: Curves.easeOutBack),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.white10,
                        backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=admin'),
                        child: Icon(Icons.person, color: Colors.white24, size: 20),
                      ).animate(target: _isFirstLoad ? 0 : 1).fadeIn(delay: 100.ms).scale(),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 2. KPI Cards
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildSmallKpi('Utilisateurs', '${metrics['active_users'] ?? 0}', Icons.people_rounded),
                      _buildSmallKpi('Missions', '${metrics['total_tasks'] ?? 0}', Icons.task_rounded),
                      _buildSmallKpi('Terminées', '${metrics['completed'] ?? 0}', Icons.check_circle_rounded),
                      _buildSmallKpi('Clients', '${metrics['clients'] ?? 0}', Icons.business_center_rounded),
                      _buildSmallKpi('Freelancers', '${metrics['freelancers'] ?? 0}', Icons.person_search_rounded),
                      _buildSmallKpi('Avis reçus', '4.8/5', Icons.star_rounded),
                    ],
                  ).animate(target: _isFirstLoad ? 0 : 1).fadeIn(delay: 200.ms).slideY(begin: 0.05),
                  const SizedBox(height: 32),

                  // 3. Middle Row: Graph Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _ActivityCrossChartCard(overview: overview)
                            .animate(target: _isFirstLoad ? 0 : 1)
                            .fadeIn(delay: 400.ms)
                            .slideY(begin: 0.02),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _ProjectStatusCard(breakdown: overview?['status_breakdown'])
                            .animate(target: _isFirstLoad ? 0 : 1)
                            .fadeIn(delay: 500.ms)
                            .slideX(begin: 0.02),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Grid Widgets
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _TeamMembersCard(users: overview?['recent_users'] ?? [])),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _TasksQuickList(projects: overview?['recent_projects'] ?? [])),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _SystemHealthCard(rate: metrics['completion_rate']?.toDouble() ?? 0.0)),
                    ],
                  ).animate(target: _isFirstLoad ? 0 : 1).fadeIn(delay: 600.ms).slideY(begin: 0.02),
                  const SizedBox(height: 48),

                  const Text('Missions Récentes', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))
                      .animate(target: _isFirstLoad ? 0 : 1).fadeIn(delay: 800.ms),
                  const SizedBox(height: 24),
                  _buildRecentMissionsList(overview?['recent_projects'] ?? []),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
    );
  }

  Widget _buildSmallKpi(String label, String value, IconData icon) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryGold, size: 20),
          ),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildRecentMissionsList(List<dynamic> projects) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.take(5).length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = projects[index];
        final budget = p['budget'] ?? p['proposed_price'] ?? p['price'] ?? p['amount'] ?? 0;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            children: [
              StatusBadge(status: p['status'] ?? 'OPEN'),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Text(
                  p['title'] ?? 'Sans titre',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'User #${p['client_id']}',
                  style: const TextStyle(color: Colors.white38, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$budget FCFA',
                  style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: () => context.push('/admin/project/${p['id']}'),
                child: const Text('DÉTAILS →', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ),
            ],
          ),
        ).animate(target: _isFirstLoad ? 0 : 1).fadeIn(delay: (900 + index * 50).ms).slideX(begin: 0.05);
      },
    );
  }
}

class _ActivityCrossChartCard extends StatelessWidget {
  final Map<String, dynamic>? overview;
  const _ActivityCrossChartCard({this.overview});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Signed over time', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const Icon(Icons.show_chart_rounded, color: AppColors.primaryGold, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text('Activity analysis (Missions & Proposals)', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 13)),
          const SizedBox(height: 40),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(painter: _CrossLineChartPainter()),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Tasks', AppColors.primaryGold),
              const SizedBox(width: 40),
              _buildLegend('Proposals', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ProjectStatusCard extends StatelessWidget {
  final Map<String, dynamic>? breakdown;
  const _ProjectStatusCard({this.breakdown});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Project Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildProgress('Open', (breakdown?['OPEN'] ?? 0) / 20.0, AppColors.primaryGold),
          _buildProgress('In Progress', (breakdown?['IN_PROGRESS'] ?? 0) / 20.0, Colors.blueAccent),
          _buildProgress('Completed', (breakdown?['COMPLETED'] ?? 0) / 20.0, Colors.greenAccent),
          _buildProgress('Cancelled', (breakdown?['CANCELLED'] ?? 0) / 20.0, AppColors.errorRed),
        ],
      ),
    );
  }

  Widget _buildProgress(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${(val * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val.clamp(0.05, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMembersCard extends StatelessWidget {
  final List<dynamic> users;
  const _TeamMembersCard({required this.users});
  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team members', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...users.take(3).map((u) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white10, radius: 14, child: Text(u['full_name']?[0] ?? '?', style: const TextStyle(color: Colors.white, fontSize: 10))),
                const SizedBox(width: 10),
                Expanded(child: Text(u['full_name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold), maxLines: 1)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TasksQuickList extends StatelessWidget {
  final List<dynamic> projects;
  const _TasksQuickList({required this.projects});
  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Tasks', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...projects.take(4).map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(p['status'] == 'COMPLETED' ? Icons.check_circle_rounded : Icons.radio_button_unchecked, color: AppColors.primaryGold, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(p['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _SystemHealthCard extends StatelessWidget {
  final double rate;
  const _SystemHealthCard({required this.rate});
  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Success Growth', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [30, 60, 45, 90, 50, 75].map((h) => Container(
              width: 10, height: h.toDouble(), decoration: BoxDecoration(color: AppColors.primaryGold, borderRadius: BorderRadius.circular(2)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;
  const _BaseCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(24)),
      child: child,
    );
  }
}

class _CrossLineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()..color = AppColors.primaryGold..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final whitePaint = Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final areaPaint = Paint()..color = AppColors.primaryGold.withValues(alpha: 0.1)..style = PaintingStyle.fill;

    // Line 1: Tasks (Gold)
    final p1 = Path();
    p1.moveTo(0, size.height * 0.5);
    p1.quadraticBezierTo(size.width * 0.25, size.height * 0.8, size.width * 0.5, size.height * 0.4);
    p1.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.3);

    // Area under Gold Line
    final areaPath = Path.from(p1);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();
    canvas.drawPath(areaPath, areaPaint);

    // Line 2: Proposals (White) - Crossing the gold line
    final p2 = Path();
    p2.moveTo(0, size.height * 0.8);
    p2.quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.7, size.height * 0.6);
    p2.lineTo(size.width, size.height * 0.45);

    canvas.drawPath(p1, goldPaint);
    canvas.drawPath(p2, whitePaint);

    // Points at intersection or key values
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.4), 6, Paint()..color = AppColors.primaryGold);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
