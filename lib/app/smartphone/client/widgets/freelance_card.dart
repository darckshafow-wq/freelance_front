import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class FreelanceCard extends StatelessWidget {
  final UserModel freelance;
  final int index;

  const FreelanceCard({
    super.key,
    required this.freelance,
    required this.index,
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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 25,
              offset: const Offset(0, 12))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
              RouteNames.clientFreelanceDetail.replaceAll(':id', freelance.id.toString())),
          borderRadius: BorderRadius.circular(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: AppColors.softWhite,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?u=freelance${freelance.id}'),
                        onBackgroundImageError: (e, s) => const Icon(Icons.person, size: 30),
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration:
                            const BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3))),
                        child: const Icon(Icons.check, size: 8, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        freelance.fullName,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.deepBlack, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senior Mobile Developer',
                        style: TextStyle(color: AppColors.neutralGray, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildMiniBadge(Icons.star, '4.9', Colors.orange),
                          const SizedBox(width: 12),
                          _buildMiniBadge(Icons.work_outline, '42', AppColors.neutralGray),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '45€',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.deepBlack),
                    ),
                    Text('/h', style: TextStyle(color: AppColors.neutralGray.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1);
  }

  Widget _buildMiniBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.deepBlack)),
      ],
    );
  }
}
