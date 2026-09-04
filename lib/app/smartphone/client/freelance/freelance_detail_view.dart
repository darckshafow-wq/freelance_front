import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class FreelanceDetailView extends StatelessWidget {
  final String id;
  const FreelanceDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildBio(),
                  const SizedBox(height: 32),
                  _buildSkills(),
                  const SizedBox(height: 32),
                  _buildStats(),
                  const SizedBox(height: 32),
                  _buildReviews(),
                  const SizedBox(height: 100), // Bottom padding for button
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildActionBtn(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.deepBlack,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Retour',
        onPressed: () => context.go(RouteNames.clientFreelanceSearch),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=2070&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mohamed Ndiaye',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ).animate().fadeIn().slideX(begin: -0.1),
              const Text(
                'Lead Flutter Developer • 6 ans d\'expérience',
                style: TextStyle(fontSize: 16, color: AppColors.neutralGray, fontWeight: FontWeight.w500),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
        const CircleAvatar(
          radius: 35,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=freelance_prof'),
        ).animate().scale(delay: 400.ms),
      ],
    );
  }

  Widget _buildBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À propos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text(
          'Passionné par le développement mobile et les architectures propres. J\'accompagne les entreprises dans la création d\'applications robustes et performantes.',
          style: TextStyle(color: AppColors.neutralGray, height: 1.6, fontSize: 15),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSkills() {
    final skills = ['Flutter', 'Firebase', 'Clean Architecture', 'CI/CD', 'Docker'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Compétences', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(s, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepBlack)),
          )).toList(),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('42', 'Missions'),
          _statItem('100%', 'Succès'),
          _statItem('4.9/5', 'Note'),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms).scale();
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.primaryGold, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Avis Clients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('Voir tout', style: TextStyle(color: AppColors.neutralGray))),
          ],
        ),
        const SizedBox(height: 12),
        _reviewCard('Super développeur, très réactif et code de qualité.', 'Jean D.'),
      ],
    ).animate().fadeIn(delay: 1200.ms);
  }

  Widget _reviewCard(String text, String author) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (index) => const Icon(Icons.star, size: 14, color: Colors.orange)),
          ),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text(author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBlack,
            foregroundColor: AppColors.primaryGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Envoyer une offre directe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.5);
  }
}
