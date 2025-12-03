import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/platform_utils.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = PlatformUtils.isIOS;
    final buttonHeight = height ?? (isIOS ? 50.0 : 48.0);

    return SizedBox(
      width: width ?? double.infinity,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isIOS ? 14 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
