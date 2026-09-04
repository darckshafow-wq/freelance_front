import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/project_model.dart';
import 'package:freelance_front/core/widgets/status_badge.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/routes/route_names.dart';

class MissionCard extends StatelessWidget {
  final ProjectModel project;
  final int index;
  final bool showImage;
  final bool isClientMission;

  const MissionCard({
    super.key,
    required this.project,
    this.index = 0,
    this.showImage = true,
    this.isClientMission = false,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = 'https://picsum.photos/seed/mission${project.id}/400/500';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            (isClientMission ? RouteNames.clientOwnedProjectDetail : RouteNames.clientProjectDetail).replaceAll(':id', project.id.toString()),
          ),
          borderRadius: BorderRadius.circular(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showImage)
                Expanded(
                  flex: 5,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Container(
                            color: AppColors.softWhite,
                            child: const Icon(Icons.image, color: AppColors.neutralGray),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_border, size: 14, color: AppColors.deepBlack),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (showImage)
                Expanded(
                  flex: 4,
                  child: _buildDetails(),
                )
              else
                _buildDetails(),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  Widget _buildDetails() {
    return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.deepBlack, letterSpacing: -0.5),
                          ),
                          if (!showImage) ...[
                            const SizedBox(height: 6),
                            StatusBadge(status: project.status),
                          ],
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              project.category ?? 'General',
                              style: const TextStyle(
                                color: Color(0xFF916A08),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${project.budget.toInt()}€',
                            style: const TextStyle(
                              color: AppColors.deepBlack,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.star, size: 12, color: Colors.orange),
                              SizedBox(width: 2),
                              Text('4.8', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.deepBlack)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
  }
}
