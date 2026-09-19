import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';
import 'package:freelance_front/core/controllers/admin/admin_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminBroadcastView extends StatefulWidget {
  final bool isDialog;
  const AdminBroadcastView({super.key, this.isDialog = false});

  @override
  State<AdminBroadcastView> createState() => _AdminBroadcastViewState();
}

class _AdminBroadcastViewState extends State<AdminBroadcastView> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedTarget = 'ALL';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final controller = context.read<AdminController>();
    final success = await controller.sendBroadcast(
      title,
      message,
      target: _selectedTarget,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diffusion envoyée avec succès !'), backgroundColor: Colors.green),
      );
      if (widget.isDialog) {
        Navigator.pop(context, true);
      } else {
        _titleController.clear();
        _messageController.clear();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.errorMessage ?? 'Erreur lors de l\'envoi'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final bool isDialog = widget.isDialog;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isDialog) ...[
          const Text(
            'Diffusion de Notifications',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 8),
          const Text(
            'Envoyez un message important à tous les utilisateurs ou à une cible spécifique.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 48),
        ],

        Flexible(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: EdgeInsets.all(isDialog ? 0 : 32),
              decoration: isDialog ? null : BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cible', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTargetSelector(),
                  const SizedBox(height: 32),
                  
                  const Text('Titre de la notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTextField(_titleController, 'Ex: Nouvelle mise à jour disponible', maxLines: 1),
                  const SizedBox(height: 32),

                  const Text('Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildTextField(_messageController, 'Décrivez l\'annonce ici...', maxLines: 6),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: controller.isLoading ? null : _handleSend,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        controller.isLoading ? 'ENVOI EN COURS...' : 'DIFFUSER MAINTENANT',
                        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
        ),
      ],
    );

    if (isDialog) {
      return AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nouvelle Diffusion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(width: 600, child: content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER', style: TextStyle(color: Colors.white38)),
          ),
        ],
      );
    }

    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(40),
      child: content,
    );
  }

  Widget _buildTargetSelector() {
    return Wrap(
      spacing: 12,
      children: [
        _targetChip('TOUT LE MONDE', 'ALL'),
        _targetChip('CLIENTS UNIQUEMENT', 'CLIENT'),
        _targetChip('FREELANCES UNIQUEMENT', 'FREELANCE'),
      ],
    );
  }

  Widget _targetChip(String label, String value) {
    final active = _selectedTarget == value;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (s) => setState(() => _selectedTarget = value),
      selectedColor: AppColors.primaryGold,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: TextStyle(
        color: active ? Colors.black : Colors.white54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      showCheckmark: false,
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primaryGold, width: 1)),
      ),
    );
  }
}
