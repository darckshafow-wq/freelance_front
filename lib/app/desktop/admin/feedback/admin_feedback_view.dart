import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/admin/feedback_model.dart';
import 'package:freelance_front/core/services/common/feedback_service.dart';

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
    final reply = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: Text('Répondre à « ${ticket.subject} »'), content: TextField(controller: controller, maxLines: 5, decoration: const InputDecoration(labelText: 'Réponse')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Envoyer'))]));
    controller.dispose();
    if (reply == null || reply.isEmpty) return;
    await _service.replyToTicket(ticket.id, reply);
    if (mounted) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Réponse envoyée.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback clients'), backgroundColor: AppColors.deepBlack, foregroundColor: Colors.white),
      body: FutureBuilder<List<FeedbackModel>>(future: _ticketsFuture, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return const Center(child: Text('Impossible de charger les feedbacks.'));
        final tickets = snapshot.data ?? [];
        if (tickets.isEmpty) return const Center(child: Text('Aucun feedback en attente.'));
        return RefreshIndicator(onRefresh: () async => _refresh(), child: ListView.builder(padding: const EdgeInsets.all(24), itemCount: tickets.length, itemBuilder: (context, index) => _ticketCard(tickets[index])));
      }),
    );
  }

  Widget _ticketCard(FeedbackModel ticket) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(ticket.subject, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
                const Chip(label: Text('En attente')),
              ],
            ),
            const SizedBox(height: 10),
            Text(ticket.content),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => _reply(ticket),
                icon: const Icon(Icons.reply_outlined),
                label: const Text('Répondre'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
