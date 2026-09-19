import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/controllers/common/notification_controller.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/app/smartphone/client/widgets/mission_card.dart';

class FreelanceHomeView extends StatefulWidget {
  const FreelanceHomeView({super.key});

  @override
  State<FreelanceHomeView> createState() => _FreelanceHomeViewState();
}

class _FreelanceHomeViewState extends State<FreelanceHomeView> {
  String _selectedCategory = 'Tout';
  final List<String> _categories = [
    'Tout',
    'Design',
    'Développement',
    'Marketing',
    'Vidéo',
    'Rédaction',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchFreelanceProjects();
      context.read<NotificationController>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trouvez votre\nprochaine mission',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepBlack,
                        height: 1.1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.search_rounded, color: AppColors.deepBlack),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildCategorySelector()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            Consumer<ProjectController>(
              builder: (context, controller, child) {
                if (controller.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.deepBlack),
                    ),
                  );
                }

                if (controller.errorMessage != null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                  );
                }

                final filteredProjects = controller.publicProjects.where((p) {
                  if (p.status.toUpperCase() != 'OPEN') return false;
                  if (_selectedCategory == 'Tout') return true;
                  return p.category == _selectedCategory;
                }).toList();

                if (filteredProjects.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.work_off_outlined,
                            size: 48,
                            color: AppColors.neutralGray.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aucune mission trouvée',
                            style: TextStyle(
                              color: AppColors.neutralGray,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = filteredProjects[index];
                        return GestureDetector(
                          onTap: () {
                            // On the freelance side, go to freelanceProjectDetail
                            context.pushNamed(RouteNames.freelanceProjectDetail, pathParameters: {'id': project.id.toString()});
                          },
                          child: MissionCard(
                            project: project,
                            index: index,
                            isFreelanceView: true,
                          ),
                        );
                      },
                      childCount: filteredProjects.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, size: 18, color: AppColors.primaryGold),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Freelance',
                      style: TextStyle(fontSize: 11, color: AppColors.neutralGray),
                    ),
                    Text(
                      'Votre espace personnel',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.deepBlack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Consumer<NotificationController>(
                builder: (context, controller, child) {
                  return GestureDetector(
                    // TODO: freelance notifications
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.softWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neutralGrayDark.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.deepBlack),
                          if (controller.unreadCount > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: AppColors.errorRed,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${controller.unreadCount}',
                                    style: const TextStyle(
                                      color: AppColors.pureWhite,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => context.push(RouteNames.freelanceProfile),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGold, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.softWhite,
                    child: Icon(Icons.person_rounded, size: 20, color: AppColors.deepBlack),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.deepBlack : AppColors.softWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.deepBlack
                      : AppColors.neutralGrayDark.withValues(alpha: 0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryGold : AppColors.neutralGray,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

