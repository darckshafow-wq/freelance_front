import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';
import 'package:go_router/go_router.dart';

class ClientReviewsView extends StatefulWidget {
  const ClientReviewsView({super.key});

  @override
  State<ClientReviewsView> createState() => _ClientReviewsViewState();
}

class _ClientReviewsViewState extends State<ClientReviewsView> {
  late final Future<List<ReviewModel>> _reviewsFuture = ProjectService().getClientReviews();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Avis reçus', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepBlack,
      ),
      body: FutureBuilder<List<ReviewModel>>(
        future: _reviewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.deepBlack));
          }
          if (snapshot.hasError) return const Center(child: Text('Impossible de charger les avis.'));
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) return const Center(child: Text('Aucun avis reçu pour le moment.'));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            itemCount: reviews.length,
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          );
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.pushNamed('clientReviewDetail', extra: review),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 23, backgroundColor: AppColors.softWhite, backgroundImage: NetworkImage(review.reviewerAvatarUrl ?? 'https://i.pravatar.cc/100?u=${review.reviewerId}'), child: const Icon(Icons.person, color: AppColors.neutralGray)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(review.reviewerName ?? 'Freelance #${review.reviewerId}', style: const TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w800)),
                Text(review.projectTitle ?? 'Mission terminée', style: const TextStyle(color: AppColors.neutralGray, fontSize: 12)),
              ])),
              const Icon(Icons.chevron_right, color: AppColors.neutralGray),
            ]),
            const SizedBox(height: 14),
            _buildStars(review.rating),
            const SizedBox(height: 8),
            Text(review.comment, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(height: 1.4)),
          ]),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) => Row(children: List.generate(5, (index) => Icon(index < rating.round() ? Icons.star : Icons.star_border, size: 18, color: Colors.orange)));
}
