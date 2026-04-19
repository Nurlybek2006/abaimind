import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GoldTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final void Function(String)? onChanged;
  final TextCapitalization textCapitalization;

  const GoldTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.gold.withValues(alpha: 0.8)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.gold)
            : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
