import 'package:flutter/material.dart';

class AdminFinancialsView extends StatelessWidget {
  const AdminFinancialsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finances Admin')),
      body: const Center(
        child: Text('Escrow, payouts et commissions'),
      ),
    );
  }
}
