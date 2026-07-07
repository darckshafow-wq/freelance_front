import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class ClientMissionsPage extends StatelessWidget {
  const ClientMissionsPage({super.key});

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
          Navigator.pushNamed(
            context,
            '/smartphone/client/missions/create_mission_view',
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle tâche'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _MissionCard(
            title: 'Design de logo',
            status: 'En attente de validation',
            count: '3 candidatures',
          ),
          _MissionCard(
            title: 'Développement web',
            status: 'Validée',
            count: '2 candidatures',
          ),
          _MissionCard(
            title: 'Rédaction de contenu',
            status: 'En cours',
            count: '1 candidature',
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.title,
    required this.status,
    required this.count,
  });

  final String title;
  final String status;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const SizedBox(height: 6),
                Text(
                  status,
                  style: TextStyle(color: AppColors.lightTextSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  count,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
    );
  }
}
