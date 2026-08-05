import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/feedback_controller.dart';
import '../../../../models/shared/feedback_model.dart';
import 'admin_feedback_detail_page.dart';

class AdminFeedbackListPage extends StatefulWidget {
  const AdminFeedbackListPage({super.key});

  @override
  State<AdminFeedbackListPage> createState() => _AdminFeedbackListPageState();
}

class _AdminFeedbackListPageState extends State<AdminFeedbackListPage> {
  String? _selectedStatus; // null pour "tous"

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedbackController>().fetchAllFeedbacks();
    });
  }

  void _onStatusFilterChanged(String? newStatus) {
    setState(() {
      _selectedStatus = newStatus;
    });
    context.read<FeedbackController>().fetchAllFeedbacks(status: newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gestion des Feedbacks',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Tous',
                    isSelected: _selectedStatus == null,
                    onTap: () => _onStatusFilterChanged(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'En attente',
                    isSelected:
                        _selectedStatus ==
                        FeedbackStatus.pending.name.toLowerCase(),
                    onTap: () => _onStatusFilterChanged(
                      FeedbackStatus.pending.name.toLowerCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Répondu',
                    isSelected:
                        _selectedStatus ==
                        FeedbackStatus.answered.name.toLowerCase(),
                    onTap: () => _onStatusFilterChanged(
                      FeedbackStatus.answered.name.toLowerCase(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Fermé',
                    isSelected:
                        _selectedStatus ==
                        FeedbackStatus.closed.name.toLowerCase(),
                    onTap: () => _onStatusFilterChanged(
                      FeedbackStatus.closed.name.toLowerCase(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Liste
          Expanded(
            child: Builder(
              builder: (context) {
                final controller = context.watch<FeedbackController>();
                if (controller.isLoading && controller.allFeedbacks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (controller.error != null &&
                    controller.allFeedbacks.isEmpty) {
                  return Center(
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (controller.allFeedbacks.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucun feedback trouvé.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchAllFeedbacks(status: _selectedStatus),
                  color: AppColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.allFeedbacks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final fb = controller.allFeedbacks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminFeedbackDetailPage(feedback: fb),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      fb.category.label,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: fb.status.color.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      fb.status.label,
                                      style: TextStyle(
                                        color: fb.status.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                fb.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Soumis par Utilisateur #${fb.userId} • ${timeago.format(fb.createdAt, locale: 'fr')}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
