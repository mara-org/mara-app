import 'package:flutter/material.dart';
import '../../core/widgets/mara_logo.dart';
import '../../core/utils/platform_utils.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaraLogo(),
                SizedBox(height: 24),
                Text(
                  'Splash Screen',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

