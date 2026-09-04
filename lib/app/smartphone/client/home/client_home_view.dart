import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/controllers/common/notification_controller.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:freelance_front/app/smartphone/client/widgets/mission_card.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  String _selectedCategory = 'Tout';
  final List<String> _categories = [
    'Tout',
    'Design',
    'D\u00e9veloppement',
    'Marketing',
    'Vid\u00e9o',
    'R\u00e9daction',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchPublicProjects();
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
            // Header
            SliverToBoxAdapter(child: _buildHeader()),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // "Visitez de nouveaux talents" Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.goNamed(RouteNames.clientFreelanceSearch),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.deepBlack,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepBlack.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: AppColors.primaryGold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Visitez de nouveaux talents',
                                style: TextStyle(
                                  color: AppColors.pureWhite,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'D\u00e9couvrez des freelances pr\u00e8s de chez vous',
                                style: TextStyle(
                                  color: AppColors.neutralGrayDark,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.primaryGold,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Category Chips
            SliverToBoxAdapter(child: _buildCategorySelector()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Missions r\u00e9centes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.deepBlack,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed(RouteNames.clientProjects),
                      child: const Text(
                        'Voir tout',
                        style: TextStyle(
                          color: AppColors.primaryGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Project Grid using MissionCard
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
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.neutralGray),
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
                            'Aucune mission trouv\u00e9e',
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
                      (context, index) => MissionCard(
                        project: filteredProjects[index],
                        index: index,
                      ),
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
          // Location
          Expanded(
            child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primaryGold),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localisation',
                    style: TextStyle(fontSize: 11, color: AppColors.neutralGray),
                  ),
                  Text(
                    'Localisation non renseignée',
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

          // Notifications + Profile
          Row(
            children: [
              Consumer<NotificationController>(
                builder: (context, controller, child) {
                  return GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.clientNotifications),
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
                onTap: () => context.pushNamed(RouteNames.clientProfile),
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
