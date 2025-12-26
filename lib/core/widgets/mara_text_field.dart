import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_colors_dark.dart';
import '../utils/platform_utils.dart';

class MaraTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool enabled;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableContextMenu;

  const MaraTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.inputFormatters,
    this.enableContextMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = PlatformUtils.isIOS;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      enableInteractiveSelection: enableContextMenu,
      contextMenuBuilder: enableContextMenu
          ? null
          : (context, editableTextState) => const SizedBox.shrink(),
      style: TextStyle(
        fontFamily: 'Roboto',
        fontSize: isIOS ? 17 : 16,
        color: isDark ? AppColorsDark.textPrimary : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark ? AppColorsDark.textSecondary : null,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? AppColorsDark.textSecondary.withOpacity( 0.6)
              : null,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark ? AppColorsDark.cardBackground : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: BorderSide(
              color: isDark ? AppColorsDark.borderColor : Colors.grey[300]!,
              width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: BorderSide(
              color: isDark ? AppColorsDark.borderColor : Colors.grey[300]!,
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: const BorderSide(
            color: AppColors.languageButtonColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isIOS ? 16 : 14,
        ),
      ),
    );
  }
}
