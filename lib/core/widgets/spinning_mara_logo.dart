import 'package:flutter/material.dart';
import 'mara_logo.dart';

/// A spinning version of the Mara logo, typically used for loading states.
class SpinningMaraLogo extends StatefulWidget {
  final double? width;
  final double? height;

  const SpinningMaraLogo({super.key, this.width, this.height});

  @override
  State<SpinningMaraLogo> createState() => _SpinningMaraLogoState();
}

class _SpinningMaraLogoState extends State<SpinningMaraLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: MaraLogo(width: widget.width, height: widget.height),
    );
  }
}
