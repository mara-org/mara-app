import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class MainBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const MainBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/analytics');
        break;
      case 2:
        context.go('/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: AppColors.languageButtonColor,
      unselectedItemColor: AppColors.textSecondary,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: l10n.analyst,
        ),
        BottomNavigationBarItem(
          icon: _MaraLogoIcon(isSelected: false),
          activeIcon: _MaraLogoIcon(isSelected: true),
          label: l10n.mara,
        ),
      ],
    );
  }
}

class _MaraLogoIcon extends StatelessWidget {
  final bool isSelected;

  const _MaraLogoIcon({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final image = SizedBox(
      width: 28,
      height: 28,
      child: Image.asset(
        'assets/images/mara_logo_new.png',
      ),
    );

    if (isSelected) {
      // Show original colors when selected (no filter)
      return image;
    } else {
      // Apply grey filter when not selected
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        child: image,
      );
    }
  }
}
