import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class ProposalCard extends StatelessWidget {
  final int index;
  final String freelancerName;
  final String price;
  final String message;
  final String avatarUrl;

  const ProposalCard({
    super.key,
    required this.index,
    required this.freelancerName,
    required this.price,
    required this.message,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(RouteNames.clientConversationDetail.replaceAll(':id', index.toString())),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.softWhite,
                        backgroundImage: NetworkImage(avatarUrl),
                        onBackgroundImageError: (e, s) => const Icon(Icons.person, color: AppColors.neutralGray),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            freelancerName,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.deepBlack, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Freelancer Expert',
                            style: TextStyle(color: AppColors.neutralGray, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Light green background
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.deepBlack, fontSize: 15, height: 1.6, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push(RouteNames.clientConversationDetail.replaceAll(':id', index.toString())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepBlack,
                          foregroundColor: AppColors.primaryGold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          minimumSize: const Size(double.infinity, 56),
                          elevation: 0,
                        ),
                        child: const Text('Démarrer l\'entretien', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.errorRed.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 24),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
  }
}
