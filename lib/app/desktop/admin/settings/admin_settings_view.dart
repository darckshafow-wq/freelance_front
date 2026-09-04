import 'package:flutter/material.dart';

class AdminSettingsView extends StatelessWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres Admin')),
      body: const Center(
        child: Text('Configuration de la plateforme'),
      ),
    );
  }
}
