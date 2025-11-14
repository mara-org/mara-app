import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/platform_utils.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;

  const PrimaryButton({
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
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.languageButtonColor, // #0EA5C6
          foregroundColor: AppColors.secondary,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isIOS ? 14 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
          ),
          elevation: isIOS ? 0 : 2,
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

