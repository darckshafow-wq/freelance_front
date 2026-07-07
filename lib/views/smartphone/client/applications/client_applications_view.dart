import 'package:flutter/material.dart';

class ClientApplicationsView extends StatelessWidget {
  const ClientApplicationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Candidatures Reçues')),
      body: const Center(
        child: Text('// TODO: Liste des candidatures reçues pour les tâches du client'),
      ),
    );
  }
}
