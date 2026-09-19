import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/admin/feedback_model.dart';
import 'package:freelance_front/core/services/common/feedback_service.dart';
import 'package:intl/intl.dart';

class AdminFeedbackView extends StatefulWidget {
  const AdminFeedbackView({super.key});

  @override
  State<AdminFeedbackView> createState() => _AdminFeedbackViewState();
}

class _AdminFeedbackViewState extends State<AdminFeedbackView> {
  final _service = FeedbackService();
  late Future<List<FeedbackModel>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _service.getPendingTickets();
  }

  void _refresh() => setState(() => _ticketsFuture = _service.getPendingTickets());

  Future<void> _reply(FeedbackModel ticket) async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text('Répondre à « ${ticket.subject} »', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Réponse',
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler', style: TextStyle(color: Colors.white24))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
            child: const Text('ENVOYER'),
          ),
        ],
      ),
    );
    
    controller.dispose();
    if (reply == null || reply.isEmpty) return;
    
    await _service.replyToTicket(ticket.id, reply);
    if (mounted) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réponse envoyée avec succès.'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Feedbacks en attente', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryGold)),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: FutureBuilder<List<FeedbackModel>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryGold));
                if (snapshot.hasError) return const Center(child: Text('Erreur lors du chargement', style: TextStyle(color: Colors.white54)));
                
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) return const Center(child: Text('Aucun feedback en attente.', style: TextStyle(color: Colors.white24)));

                return ListView.separated(
                  itemCount: tickets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _ticketCard(tickets[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(FeedbackModel ticket) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Text('EN ATTENTE', style: TextStyle(color: AppColors.primaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(ticket.subject, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              Text(
                ticket.createdAt != null ? DateFormat('dd/MM HH:mm').format(ticket.createdAt!) : '',
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(ticket.content, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('User ID: #${ticket.userId}', style: const TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _reply(ticket),
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('RÉPONDRE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
