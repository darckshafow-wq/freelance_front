import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class AdminFinancialsView extends StatefulWidget {
  const AdminFinancialsView({super.key});

  @override
  State<AdminFinancialsView> createState() => _AdminFinancialsViewState();
}

class _AdminFinancialsViewState extends State<AdminFinancialsView> {
  final currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final metrics = controller.overview?['metrics'] ?? {};

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion Financière',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          const Text(
            'Suivi des transactions, commissions et paiements des freelances.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),

          // Top Row Cards
          Row(
            children: [
              Expanded(child: _buildFinanceCard('Volume Total', 24500000, Icons.account_balance_wallet_rounded, Colors.blueAccent)),
              const SizedBox(width: 24),
              Expanded(child: _buildFinanceCard('Commissions (10%)', 2450000, Icons.pie_chart_rounded, AppColors.primaryGold)),
              const SizedBox(width: 24),
              Expanded(child: _buildFinanceCard('Paiements en attente', 850000, Icons.hourglass_top_rounded, Colors.orangeAccent)),
              const SizedBox(width: 24),
              Expanded(child: _buildFinanceCard('Revenu Net Platform', 1600000, Icons.trending_up_rounded, Colors.greenAccent)),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),

          const SizedBox(height: 48),

          // Bottom Row: Transactions & Payouts
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTransactionsList(),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: _buildPayoutsColumn(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            currencyFormat.format(value),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 14),
              const SizedBox(width: 4),
              const Text('12% ce mois', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transactions Récentes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 32),
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), shape: BoxShape.circle),
                      child: const Icon(Icons.payment_rounded, color: Colors.white38, size: 18),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paiement Mission #124', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('Client: John Doe', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('+ 150 000 FCFA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                        Text('Il y a 2h', style: TextStyle(color: Colors.white24, fontSize: 11)),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutsColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Demandes de Payout', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(backgroundColor: AppColors.primaryGold, radius: 14, child: Icon(Icons.person, size: 16, color: Colors.black)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Freelance Expert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Text('45 000 FCFA', style: TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black),
                      child: const Text('APPROUVER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white10)),
                      child: const Text('VOIR RIB', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}
