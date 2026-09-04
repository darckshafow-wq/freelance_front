import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:freelance_front/core/controllers/common/project_controller.dart';
import 'package:freelance_front/core/routes/route_names.dart';
import 'package:go_router/go_router.dart';

class ProposalListView extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const ProposalListView({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProposalListView> createState() => _ProposalListViewState();
}

class _ProposalListViewState extends State<ProposalListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectController>().fetchProposals(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Retour',
          onPressed: () => context.go(RouteNames.clientProjects),
        ),
        title: Text('Propositions : ${widget.projectTitle}'),
      ),
      body: Consumer<ProjectController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.currentProjectProposals.isEmpty) {
            return const Center(child: Text('Aucune proposition pour le moment'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.currentProjectProposals.length,
            itemBuilder: (context, index) {
              final proposal = controller.currentProjectProposals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Freelance #ID', // Normalement on afficherait le nom
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '${proposal.proposedPrice} €',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(proposal.message),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text('Refuser'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Accepter'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
