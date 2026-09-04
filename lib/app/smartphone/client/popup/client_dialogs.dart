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

Future<bool> showCloseTaskDialog(BuildContext context, String title) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.successGreen, size: 28),
          SizedBox(width: 8),
          Text('Clôturer ?', style: TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w900)),
        ],
      ),
      content: Text(
        'La mission « $title » sera marquée comme terminée. Cette action permettra ensuite de laisser un avis au freelance.',
        style: const TextStyle(color: AppColors.neutralGrayDark, height: 1.4),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.successGreen,
            foregroundColor: AppColors.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Clôturer', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<Map<String, dynamic>?> showReviewDialog(BuildContext context, String freelancerName) {
  final commentController = TextEditingController();
  var rating = 5;
  
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
      backgroundColor: AppColors.pureWhite,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Évaluer $freelancerName', style: const TextStyle(color: AppColors.deepBlack, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Comment s\'est passée la collaboration ?', style: TextStyle(color: AppColors.neutralGrayDark), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => IconButton(
              icon: Icon(
                index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                color: index < rating ? AppColors.primaryGold : AppColors.neutralGray,
                size: 36,
              ),
              onPressed: () => setState(() => rating = index + 1),
            )),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Décrivez votre collaboration...',
              filled: true,
              fillColor: AppColors.softWhite,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Plus tard', style: TextStyle(color: AppColors.neutralGray, fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {'rating': rating, 'comment': commentController.text.trim()}),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.deepBlack,
            foregroundColor: AppColors.primaryGold,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text('Publier', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    )),
  );
}
