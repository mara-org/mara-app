import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isVitalSignsLoading = false;
  bool _isSummaryLoading = false;

  void _onVitalSignsTap() {
    setState(() {
      _isVitalSignsLoading = true;
    });
    // Simulate loading - you can replace this with actual async operation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isVitalSignsLoading = false;
        });
      }
    });
  }

  void _onSummaryTap() {
    setState(() {
      _isSummaryLoading = true;
    });
    // Simulate loading - you can replace this with actual async operation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSummaryLoading = false;
        });
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 1:
        context.go('/analytics');
        break;
      case 2:
        context.go('/chat');
        break;
      default:
        context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final name = profile.name ?? 'there';
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final dateText = dateFormat.format(now);
    final timeOfDay = now.hour;
    String greeting;
    if (timeOfDay < 12) {
      greeting = 'Good morning';
    } else if (timeOfDay < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gradientStart,
                    AppColors.homeHeaderBackground,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Mara logo
                        const MaraLogo(
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$greeting, $name 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                dateText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile icon
                        GestureDetector(
                          onTap: () {
                            context.go('/profile');
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: PlatformUtils.getDefaultPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Conversation resume card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              offset: const Offset(0, 1),
                              blurRadius: 13,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'What happened to your cough?',
                                    style: TextStyle(
                                      color: AppColors.languageButtonColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.languageButtonColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'complete your last conversation',
                              style: TextStyle(
                                color: AppColors.languageButtonColor,
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Daily Insights section
                      Text(
                        'Your Daily Insights',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Insights row
                      Row(
                        children: [
                          Expanded(
                            child: _InsightCard(
                              label: 'Mood',
                              value: 'calm',
                              icon: Icons.sentiment_satisfied,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InsightCard(
                              label: 'Sleep',
                              value: '7h 25m',
                              icon: Icons.bedtime,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InsightCard(
                              label: 'Water',
                              value: '2.5L',
                              icon: Icons.water_drop,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Vital signs card
                      GestureDetector(
                        onTap: _isVitalSignsLoading ? null : _onVitalSignsTap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _isVitalSignsLoading
                                ? Colors.grey
                                : AppColors.homeVitalSignsBackground,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _isVitalSignsLoading
                                            ? Icons.hourglass_empty
                                            : Icons.favorite,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Vital signs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    _isVitalSignsLoading
                                        ? Icons.hourglass_empty
                                        : Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Track your variability and resting heart rate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Summary card
                      GestureDetector(
                        onTap: _isSummaryLoading ? null : _onSummaryTap,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _isSummaryLoading
                                ? Colors.grey
                                : AppColors.homeCardBackground,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _isSummaryLoading
                                        ? Icons.hourglass_empty
                                        : Icons.insights,
                                    color: _isSummaryLoading
                                        ? Colors.white
                                        : AppColors.languageButtonColor,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Summary',
                                    style: TextStyle(
                                      color: _isSummaryLoading
                                          ? Colors.white
                                          : AppColors.languageButtonColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _isSummaryLoading
                                    ? Icons.hourglass_empty
                                    : Icons.arrow_forward_ios,
                                size: 16,
                                color: _isSummaryLoading
                                    ? Colors.white
                                    : AppColors.languageButtonColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Chat with Mara button
                      PrimaryButton(
                        text: 'Chat with Mara',
                        onPressed: () {
                          context.go('/chat');
                        },
                      ),
                      const SizedBox(height: 16),
                      // Tip card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.homeTipBackground,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: AppColors.languageButtonColor,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Drink a glass of water every morning to boost your metabolism.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.languageButtonColor,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analyst',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Mara',
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InsightCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.permissionCardBackground],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.languageButtonColor,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            icon,
            color: AppColors.languageButtonColor,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.languageButtonColor,
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

