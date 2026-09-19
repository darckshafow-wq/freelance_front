import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/models/common/proposal_model.dart';
import 'package:freelance_front/core/services/client/project_service.dart';

class FreelanceProposalsView extends StatefulWidget {
  const FreelanceProposalsView({super.key});

  @override
  State<FreelanceProposalsView> createState() => _FreelanceProposalsViewState();
}

class _FreelanceProposalsViewState extends State<FreelanceProposalsView> {
  late Future<List<ProposalModel>> _proposalsFuture;

  @override
  void initState() {
    super.initState();
    _proposalsFuture = _loadProposals();
  }

  Future<List<ProposalModel>> _loadProposals() async {
    try {
      return await ProjectService().getFreelanceProposals();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softWhite,
      appBar: AppBar(
        title: const Text('Mes candidatures', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.deepBlack)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: FutureBuilder<List<ProposalModel>>(
        future: _proposalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Impossible de charger vos candidatures.'));
          
          final proposals = snapshot.data ?? [];
          if (proposals.isEmpty) {
            return const Center(child: Text('Vous n\'avez envoyé aucune candidature.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: proposals.length,
            itemBuilder: (context, index) {
              final proposal = proposals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mission #${proposal.projectId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: proposal.status == 'ACCEPTED' ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.primaryGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            proposal.status,
                            style: TextStyle(
                              color: proposal.status == 'ACCEPTED' ? AppColors.successGreen : AppColors.primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Tarif proposé : ${proposal.proposedPrice.toStringAsFixed(0)} €', style: const TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(proposal.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.neutralGray, fontSize: 13)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

