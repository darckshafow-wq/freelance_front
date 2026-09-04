import 'package:flutter/material.dart';

class AdminUsersModerationView extends StatelessWidget {
  const AdminUsersModerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modération utilisateurs')),
      body: const Center(
        child: Text('Validation KYC, suspension et modération'),
      ),
    );
  }
}
