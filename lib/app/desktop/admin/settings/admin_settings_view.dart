import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _maintenanceMode = false;
  bool _registrationEnabled = true;
  bool _twoFactorRequired = false;
  String _platformFee = '10';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres Système',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          const Text(
            'Contrôlez les fonctions critiques de la plateforme FreeFlow.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSection('Sécurité & Accès', [
                    _buildToggle('Mode Maintenance', 'Désactive l\'accès public à la plateforme pour maintenance.', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
                    _buildToggle('Inscriptions ouvertes', 'Autorise les nouveaux utilisateurs à créer un compte.', _registrationEnabled, (v) => setState(() => _registrationEnabled = v)),
                    _buildToggle('2FA Obligatoire', 'Force tous les administrateurs à utiliser la double authentification.', _twoFactorRequired, (v) => setState(() => _twoFactorRequired = v)),
                  ]),
                  const SizedBox(height: 32),
                  _buildSection('Configuration Financière', [
                    _buildInputTile('Commission Platform (%)', 'Pourcentage prélevé sur chaque mission terminée.', _platformFee, (v) => _platformFee = v),
                    _buildInputTile('Seuil de Payout (FCFA)', 'Montant minimum pour demander un retrait.', '5000', (v) {}),
                  ]),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres enregistrés avec succès !'), backgroundColor: Colors.green));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('ENREGISTRER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle(String label, String sub, bool val, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: val, onChanged: onChanged, activeColor: AppColors.primaryGold),
        ],
      ),
    );
  }

  Widget _buildInputTile(String label, String sub, String val, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: AppColors.primaryGold, fontWeight: FontWeight.bold),
              controller: TextEditingController(text: val),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
