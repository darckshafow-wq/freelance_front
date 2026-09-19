import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';

Future<Map<String, String>?> showEditProfileDialog(BuildContext context, {required String name, required String bio}) {
  final nameController = TextEditingController(text: name);
  final bioController = TextEditingController(text: bio);
  
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Modifier le profil', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w900)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGold),
                filled: true,
                fillColor: AppColors.softWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Biographie',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50.0), // Align icon with top text
                  child: Icon(Icons.edit_note_outlined, color: AppColors.primaryGold),
                ),
                filled: true,
                fillColor: AppColors.softWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {'name': nameController.text.trim(), 'bio': bioController.text.trim()}),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBlack,
            foregroundColor: AppColors.primaryGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Enregistrer', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}
