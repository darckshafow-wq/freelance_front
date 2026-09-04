import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/admin/feedback_model.dart';
import 'package:freelance_front/core/services/common/feedback_service.dart';

class ClientFeedbackView extends StatefulWidget {
  const ClientFeedbackView({super.key});

  @override
  State<ClientFeedbackView> createState() => _ClientFeedbackViewState();
}

class _ClientFeedbackViewState extends State<ClientFeedbackView> {
  final _service = FeedbackService();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  late Future<List<FeedbackModel>> _ticketsFuture;

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
    if (_subjectController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Renseignez le sujet et votre message.')));
      return;
    }
    await _service.createTicket(subject: _subjectController.text.trim(), content: _contentController.text.trim());
    _subjectController.clear();
    _contentController.clear();
    setState(() => _ticketsFuture = _service.getMyTickets());
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Votre demande est en attente de réponse.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(title: const Text('Aide et feedback', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: AppColors.deepBlack),
      body: ListView(padding: const EdgeInsets.fromLTRB(24, 8, 24, 32), children: [
        _section('Nouveau message', Column(children: [
          TextField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Sujet', prefixIcon: Icon(Icons.subject_outlined))),
          const SizedBox(height: 12),
          TextField(controller: _contentController, maxLines: 5, decoration: const InputDecoration(labelText: 'Votre message', alignLabelWithHint: true, prefixIcon: Icon(Icons.edit_note_outlined))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.send_outlined), label: const Text('Envoyer le feedback'))),
        ])),
        const SizedBox(height: 24),
        const Text('Mes demandes', style: TextStyle(color: AppColors.deepBlack, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        FutureBuilder<List<FeedbackModel>>(future: _ticketsFuture, builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Text('Impossible de charger vos demandes.');
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) return const Text('Aucune demande envoyée.');
          return Column(children: tickets.map(_ticketCard).toList());
        }),
      ]),
    );
  }

  Widget _section(String title, Widget child) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.deepBlack, fontSize: 17, fontWeight: FontWeight.w800)), const SizedBox(height: 14), child]));

  Widget _ticketCard(FeedbackModel ticket) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(ticket.subject, style: const TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w800))), _status(ticket.status)]), const SizedBox(height: 8), Text(ticket.content, style: const TextStyle(color: AppColors.neutralGray)), if (ticket.adminReply.isNotEmpty) ...[const Divider(height: 24), const Text('Réponse de l’administration', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(ticket.adminReply)] ]));

  Widget _status(String status) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: status == 'PENDING' ? Colors.orange.withValues(alpha: 0.14) : Colors.green.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(20)), child: Text(status == 'PENDING' ? 'En attente' : 'Répondu', style: TextStyle(color: status == 'PENDING' ? Colors.orange.shade800 : Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.w700)));
}
