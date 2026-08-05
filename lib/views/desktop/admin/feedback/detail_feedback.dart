import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/feedback_controller.dart';
import '../../../../models/shared/feedback_model.dart';
import '../../../../routes/admin_routes.dart';
import '../../../shared/widgets/admin_desktop_scaffold.dart';

class AdminFeedbackDetail extends StatefulWidget {
  final int feedbackId;

  const AdminFeedbackDetail({super.key, required this.feedbackId});

  @override
  State<AdminFeedbackDetail> createState() => _AdminFeedbackDetailState();
}

class _AdminFeedbackDetailState extends State<AdminFeedbackDetail> {
  final FeedbackController _controller = FeedbackController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);

    // Déclenche la requête après la construction du widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchFeedbackDetail(widget.feedbackId);
    });
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _controller.selectedFeedback;

    return AdminDesktopScaffold(
      selectedIndex: 5,
      title: 'Feedback Details',
      body: _controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 30),
                  if (feedback == null)
                    _buildErrorState()
                  else ...[
                    _buildMainCard(feedback),
                    if (feedback.adminReply != null &&
                        feedback.adminReply!.isNotEmpty) ...[
                      const SizedBox(height: 25),
                      _buildReplyCard(feedback.adminReply!),
                    ],
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            'Feedback #${widget.feedbackId}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              AdminRouteNames.feedbackReply,
              arguments: widget.feedbackId,
            );
          },
          icon: const Icon(Icons.reply_rounded, size: 18),
          label: const Text('Répondre'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(FeedbackModel feedback) {
    // Conversion sécurisée du nom de la catégorie
    final categoryName = feedback.category
        .toString()
        .split('.')
        .last
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                feedback.createdAt.toString().split(' ')[0],
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            'Contenu du retour',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            feedback.content,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(String reply) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Réponse Admin',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            reply,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Center(
        child: Text(
          _controller.errorMessage ?? 'Feedback introuvable.',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
