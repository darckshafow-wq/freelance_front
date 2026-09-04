import 'package:flutter/material.dart';
import 'package:freelance_front/core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        validator: validator,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: const TextStyle(color: AppColors.neutralGray),
          hintStyle: const TextStyle(color: AppColors.neutralGrayDark),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.deepBlack) : null,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}
