import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/admin/feedback_model.dart';
import 'package:freelance_front/core/services/common/feedback_service.dart';
import 'package:intl/intl.dart';

class FreelanceFeedbackView extends StatefulWidget {
  const FreelanceFeedbackView({super.key});

  @override
  State<FreelanceFeedbackView> createState() => _FreelanceFeedbackViewState();
}

class _FreelanceFeedbackViewState extends State<FreelanceFeedbackView> {
  final _service = FeedbackService();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  late Future<List<FeedbackModel>> _ticketsFuture;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _service.getMyTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final content = _contentController.text.trim();

    if (subject.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      await _service.createTicket(subject: subject, content: content);
      _subjectController.clear();
      _contentController.clear();
      if (mounted) {
        setState(() {
          _ticketsFuture = _service.getMyTickets();
          _isSending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre feedback a été envoyé avec succès.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi du feedback.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Centre d\'assistance Freelance', 
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlack, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepBlack,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactForm(),
            const SizedBox(height: 40),
            const Text('Historique de vos demandes', 
              style: TextStyle(color: AppColors.deepBlack, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            _buildTicketsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Besoin d\'aide sur une mission ?', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.deepBlack)),
          const SizedBox(height: 24),
          _buildField('Sujet', _subjectController, Icons.topic_outlined, 'Ex: Problème technique'),
          const SizedBox(height: 16),
          _buildField('Message', _contentController, Icons.edit_note_rounded, 'Décrivez votre situation...', maxLines: 4),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(_isSending ? 'ENVOI EN COURS...' : 'ENVOYER MON FEEDBACK', 
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepBlack,
                foregroundColor: AppColors.primaryGold,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.neutralGray)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.2)),
            prefixIcon: Icon(icon, color: AppColors.primaryGold, size: 20),
            filled: true,
            fillColor: AppColors.softWhite,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsList() {
    return FutureBuilder<List<FeedbackModel>>(
      future: _ticketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
        }
        
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucune demande envoyée.', style: TextStyle(color: AppColors.neutralGray.withValues(alpha: 0.5))),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tickets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildTicketCard(tickets[index]),
        );
      },
    );
  }

  Widget _buildTicketCard(FeedbackModel ticket) {
    final bool isResolved = ticket.status == 'RESOLVED';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isResolved ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isResolved ? 'RÉPONDU' : 'EN ATTENTE', 
                  style: TextStyle(color: isResolved ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const Spacer(),
              Text(ticket.createdAt != null ? DateFormat('dd MMM').format(ticket.createdAt!) : '', 
                style: const TextStyle(color: Colors.black12, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.deepBlack)),
          const SizedBox(height: 8),
          Text(ticket.content, style: const TextStyle(color: AppColors.neutralGray, fontSize: 14, height: 1.4)),
          
          if (ticket.adminReply.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.black12),
            ),
            const Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryGold, size: 16),
                SizedBox(width: 8),
                Text('RÉPONSE DU SUPPORT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primaryGold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.adminReply, 
              style: const TextStyle(color: AppColors.deepBlack, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}
