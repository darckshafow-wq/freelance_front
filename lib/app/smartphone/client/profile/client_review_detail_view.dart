import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/review_model.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class ClientReviewDetailView extends StatelessWidget {
  final ReviewModel review;

  const ClientReviewDetailView({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Détail de l’avis', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.go(RouteNames.clientReviews),
        ),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 32), children: [
        _section('Freelance', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 30, backgroundColor: AppColors.softWhite, backgroundImage: NetworkImage(review.reviewerAvatarUrl ?? 'https://i.pravatar.cc/120?u=${review.reviewerId}'), child: const Icon(Icons.person, color: AppColors.neutralGray)),
            const SizedBox(width: 14),
            Expanded(child: Text(review.reviewerName ?? 'Freelance #${review.reviewerId}', style: const TextStyle(color: AppColors.deepBlack, fontSize: 19, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: () => context.push('/client/freelance/${review.revieweeId}'), icon: const Icon(Icons.person_outline), label: const Text('Voir le profil freelance')),
        ])),
        const SizedBox(height: 16),
        _section('Mission', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(review.projectTitle ?? 'Mission terminée', style: const TextStyle(color: AppColors.deepBlack, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _dateRow('Date de postulation', review.applicationDate),
          _dateRow('Date de fin de mission', review.completionDate),
        ])),
        const SizedBox(height: 16),
        _section('Avis du client', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildStars(review.rating),
          const SizedBox(height: 14),
              Text(review.comment, style: const TextStyle(color: AppColors.deepBlack, fontSize: 16, height: 1.5)),
          if (review.createdAt != null) ...[const SizedBox(height: 12), Text('Publié le ${_formatDate(review.createdAt!)}', style: const TextStyle(color: AppColors.neutralGray, fontSize: 12))],
        ])),
      ]),
    );
  }

  Widget _section(String title, Widget child) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.deepBlack, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 16), child]),
  );

  Widget _dateRow(String label, DateTime? date) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [const Icon(Icons.event_outlined, size: 18, color: AppColors.primaryGold), const SizedBox(width: 8), Text('$label : ', style: const TextStyle(color: AppColors.neutralGray)), Text(date == null ? 'Non renseignée' : _formatDate(date), style: const TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w700))]),
  );

  Widget _buildStars(double rating) => Row(children: List.generate(5, (index) => Icon(index < rating.round() ? Icons.star : Icons.star_border, color: Colors.orange, size: 22)));

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}
