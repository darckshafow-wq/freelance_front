import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/feedback_controller.dart';
import '../../../../models/shared/feedback_model.dart';
import '../../../../routes/admin_routes.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminFeedbackList extends StatefulWidget {
  const AdminFeedbackList({super.key});

  @override
  State<AdminFeedbackList> createState() => _AdminFeedbackListState();
}

class _AdminFeedbackListState extends State<AdminFeedbackList> {
  final FeedbackController _controller = FeedbackController();
  FeedbackStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    await _controller.fetchAllAdminFeedbacks(filterStatus: _selectedFilter);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminDesktopScaffold(
      selectedIndex: 5, // Indice de la navigation Admin (Feedbacks)
      title: 'Feedbacks Overview',
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 30),
                  _buildFilterChips(),
                  const SizedBox(height: 25),
                  _buildFeedbackTableContainer(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Feedback',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Gérez les retours et suggestions transmis par vos utilisateurs.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 12,
      children: [
        _buildChip('Tous', null),
        _buildChip('En attente', FeedbackStatus.pending),
        _buildChip('Répondus', FeedbackStatus.answered),
        _buildChip('Archivés', FeedbackStatus.closed),
      ],
    );
  }

  Widget _buildChip(String label, FeedbackStatus? status) {
    final bool isSelected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(
        color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = status;
          });
          _loadData();
        }
      },
    );
  }

  Widget _buildFeedbackTableContainer() {
    final list = _controller.adminFeedbacks;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, color: Colors.grey[700], size: 48),
            const SizedBox(height: 15),
            Text(
              'Aucun feedback trouvé',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white60,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(0.8),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(3),
          3: FlexColumnWidth(1.2),
          4: IntrinsicColumnWidth(),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
              ),
            ),
            children: [
              _tableHeader('ID'),
              _tableHeader('CATÉGORIE'),
              _tableHeader('MESSAGE'),
              _tableHeader('STATUT'),
              _tableHeader('ACTIONS'),
            ],
          ),
          ...list.map(
            (item) => TableRow(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              children: [
                _tableCell('#${item.id}'),
                _tableCell(item.category.name.toUpperCase()),
                _tableCell(
                  item.content.length > 50
                      ? '${item.content.substring(0, 50)}...'
                      : item.content,
                ),
                _buildStatusBadge(item.status),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.visibility_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: 'Détail',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AdminRouteNames.feedbackDetail,
                            arguments: item.id,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.reply_rounded,
                          color: Colors.white70,
                          size: 20,
                        ),
                        tooltip: 'Répondre',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AdminRouteNames.feedbackReply,
                            arguments: item.id,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(FeedbackStatus status) {
    Color color;
    switch (status) {
      case FeedbackStatus.pending:
        color = Colors.orange;
        break;
      case FeedbackStatus.answered:
        color = Colors.green;
        break;
      case FeedbackStatus.closed:
        color = Colors.grey;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
