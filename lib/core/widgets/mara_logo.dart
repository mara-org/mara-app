import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';

class MaraLogo extends StatelessWidget {
  final double? width;
  final double? height;

  const MaraLogo({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? (PlatformUtils.isIOS ? 120 : 100);
    final logoHeight = height ?? (PlatformUtils.isIOS ? 120 : 100);
    
    return Image.asset(
      'assets/images/mara_logo_new.png',
      width: logoWidth,
      height: logoHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: logoWidth,
          height: logoHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image,
            color: Colors.white,
            size: 48,
          ),
        );
      },
    );
  }
}

