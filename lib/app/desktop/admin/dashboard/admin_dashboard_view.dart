import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            _MetricCard(title: 'Utilisateurs', value: '1,245'),
            _MetricCard(title: 'Projets', value: '318'),
            _MetricCard(title: 'Signalements', value: '12'),
            _MetricCard(title: 'Avis', value: '89'),
            const SizedBox(height: 16),
            _FeedbackEntry(),
          ],
        ),
      ),
    );
  }
}

class _FeedbackEntry extends StatelessWidget {
  const _FeedbackEntry();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.deepBlack,
      child: ListTile(
        leading: const Icon(Icons.feedback_outlined, color: AppColors.primaryGold),
        title: const Text('Feedback clients', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        subtitle: const Text('Consulter les demandes en attente', style: TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryGold, size: 16),
        onTap: () => context.push(RouteNames.adminFeedback),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const _MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
