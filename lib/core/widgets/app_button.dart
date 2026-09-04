import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.indigo : Colors.grey.shade200,
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: const Size(0, 48),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}
