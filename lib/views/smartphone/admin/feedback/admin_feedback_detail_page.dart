import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../constants/app_colors.dart';
import '../../../../controllers/shared/feedback_controller.dart';
import '../../../../models/shared/feedback_model.dart';
import '../../../../utils/ui/ui_utils.dart';

class AdminFeedbackDetailPage extends StatefulWidget {
  final FeedbackModel feedback;

  const AdminFeedbackDetailPage({super.key, required this.feedback});

  @override
  State<AdminFeedbackDetailPage> createState() =>
      _AdminFeedbackDetailPageState();
}

class _AdminFeedbackDetailPageState extends State<AdminFeedbackDetailPage> {
  final _replyController = TextEditingController();
  late FeedbackStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.feedback.status;
    if (widget.feedback.adminReply != null) {
      _replyController.text = widget.feedback.adminReply!;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() async {
    if (_replyController.text.trim().isEmpty) {
      UIUtils.showInfo(context, 'Veuillez saisir une réponse.');
      return;
    }

    final controller = context.read<FeedbackController>();
    final success = await controller.replyToFeedback(
      feedbackId: widget.feedback.id,
      adminReply: _replyController.text,
      status: _selectedStatus,
    );

    if (!mounted) return;

    if (success) {
      UIUtils.showSuccess(context, 'Réponse envoyée avec succès');
      Navigator.pop(context);
    } else {
      UIUtils.showError(context, controller.error ?? 'Erreur lors de la réponse');
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackController = context.watch<FeedbackController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Détail du Feedback',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info du feedback original
            Container(
              padding: const EdgeInsets.all(20),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          widget.feedback.category.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        timeago.format(widget.feedback.createdAt, locale: 'fr'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.feedback.content,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Soumis par l\'utilisateur ID: ${widget.feedback.userId}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Formulaire de réponse admin
            const Text(
              'Répondre',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Statut du feedback',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FeedbackStatus>(
                  value: _selectedStatus,
                  isExpanded: true,
                  items: FeedbackStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: status.color,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _replyController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Saisissez votre réponse ici...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: feedbackController.isLoading ? null : _submitReply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: feedbackController.isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
