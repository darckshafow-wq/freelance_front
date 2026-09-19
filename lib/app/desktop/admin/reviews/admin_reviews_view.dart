import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/services/common/api_client.dart';
import 'package:freelance_front/core/constants/api_endpoints.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class AdminReviewsView extends StatefulWidget {
  const AdminReviewsView({super.key});

  @override
  State<AdminReviewsView> createState() => _AdminReviewsViewState();
}

class _AdminReviewsViewState extends State<AdminReviewsView> {
  List<dynamic> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.reviews);
      setState(() {
        _reviews = res.data is List ? res.data : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReviewStatus(int id, bool currentStatus) async {
    // Assuming a soft delete or toggle endpoint exists
    // For now, we mock the UI update
    setState(() {
      final index = _reviews.indexWhere((r) => r['id'] == id);
      if (index != -1) {
        _reviews[index]['is_active'] = !currentStatus;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(currentStatus ? 'Avis masqué' : 'Avis restauré'), backgroundColor: currentStatus ? Colors.orange : Colors.green)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modération des Avis', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  const Text('Gérez les évaluations laissées entre clients et freelances.', style: TextStyle(color: Colors.white38, fontSize: 14)),
                ],
              ),
              IconButton(onPressed: _fetchReviews, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold)),
            ],
          ),
          const SizedBox(height: 48),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGold))
                : _reviews.isEmpty
                    ? const Center(child: Text('Aucun avis trouvé.', style: TextStyle(color: Colors.white24)))
                    : ListView.separated(
                        itemCount: _reviews.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                        itemBuilder: (ctx, index) => _buildReviewCard(_reviews[index], index),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r, int index) {
    final rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
    final date = DateTime.tryParse(r['created_at'] ?? '') ?? DateTime.now();
    final bool isActive = r['is_active'] ?? true;

    return Opacity(
      opacity: isActive ? 1.0 : 0.4,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.1),
                  child: Text(r['reviewer_name']?[0] ?? '?', style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                _buildRatingBadge(rating),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${r['reviewer_name'] ?? 'Utilisateur'} → ${r['reviewee_name'] ?? 'Destinataire'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(color: Colors.white24, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r['comment'] ?? 'Aucun commentaire laissé.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (r['project_id'] != null)
                        TextButton.icon(
                          onPressed: () => context.push('/admin/project/${r['project_id']}'),
                          icon: const Icon(Icons.link_rounded, size: 14),
                          label: const Text('PROJET LIÉ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                IconButton(
                  onPressed: () => _toggleReviewStatus(r['id'], isActive),
                  icon: Icon(isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: isActive ? AppColors.errorRed : Colors.green),
                  tooltip: isActive ? 'Masquer l\'avis' : 'Restaurer l\'avis',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.05);
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
          const SizedBox(width: 4),
          Text(rating.toString(), style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
