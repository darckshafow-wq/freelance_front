import 'package:flutter/material.dart';
import '../../../../../constants/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            title: 'Compte',
            items: [
              _SettingsTile(
                icon: Icons.person_outline_rounded,
                label: 'Informations personnelles',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Sécurité et mot de passe',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                label: 'Préférences de notification',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSection(
            title: 'Application',
            items: [
              _SettingsTile(
                icon: Icons.language_rounded,
                label: 'Langue',
                trailing: 'Français',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: 'Thème sombre',
                trailing: 'Désactivé',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                label: 'Centre d\'aide',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSection(
            title: 'Légal',
            items: [
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Conditions d\'utilisation',
                onTap: () => _showComingSoon(context),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Politique de confidentialité',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cette fonctionnalité sera bientôt disponible !'),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 5),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.black26,
          ),
        ],
      ),
    );
  }
}
