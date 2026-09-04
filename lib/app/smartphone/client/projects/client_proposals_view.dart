import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/app/smartphone/client/widgets/proposal_card.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';

class ClientProposalsView extends StatefulWidget {
  const ClientProposalsView({super.key});

  @override
  State<ClientProposalsView> createState() => _ClientProposalsViewState();
}

class _ClientProposalsViewState extends State<ClientProposalsView> {
  late final Future<List<ProposalModel>> _proposalsFuture = ProjectService().getClientProposals();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Propositions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<ProposalModel>>(
        future: _proposalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Impossible de charger les propositions.'));
          final proposals = snapshot.data ?? [];
          if (proposals.isEmpty) return const Center(child: Text('Aucune proposition reçue.'));
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: proposals.length,
            itemBuilder: (context, index) {
              final proposal = proposals[index];
              return ProposalCard(
                index: proposal.id,
                freelancerName: 'Freelance #${proposal.freelanceId}',
                price: '${proposal.proposedPrice.toStringAsFixed(0)}€',
                message: proposal.message,
                avatarUrl: 'https://i.pravatar.cc/150?u=freelance${proposal.freelanceId}',
              );
            },
          );
        },
      ),
    );
  }
}
