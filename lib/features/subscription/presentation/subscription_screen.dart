import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/subscription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../l10n/app_localizations.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _selectedYearly = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          l10n.maraPro,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Big header
                Text(
                  l10n.maraProSubscription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // Benefits list
                _buildBenefitItem(l10n.highQualitySummaries),
                const SizedBox(height: 16),
                _buildBenefitItem(l10n.deeperAIInsights),
                const SizedBox(height: 16),
                _buildBenefitItem(l10n.moreReminders),
                const SizedBox(height: 50),
                // Pricing cards
                Row(
                  children: [
                    Expanded(
                      child: _PricingCard(
                        title: l10n.monthly,
                        price: 'SAR 25',
                        period: l10n.pricePerMonth,
                        isSelected: !_selectedYearly,
                        onTap: () => setState(() => _selectedYearly = false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PricingCard(
                        title: l10n.yearly,
                        price: 'SAR 199',
                        period: l10n.pricePerYear,
                        isSelected: _selectedYearly,
                        onTap: () => setState(() => _selectedYearly = true),
                        isHighlighted: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Subscribe button
                PrimaryButton(
                  text: l10n.subscribeWithAppleGoogle,
                  onPressed: () {
                    // Stub: Mark as subscribed
                    ref.read(subscriptionProvider.notifier).setPremium();
                    context.go('/profile');
                  },
                ),
                const SizedBox(height: 24),
                // Terms and Privacy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text.rich(
                    TextSpan(
                      text: '${l10n.iAgreeToThe} ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse('https://iammara.com/terms');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.inAppWebView,
                                );
                              }
                            },
                            child: Text(
                              l10n.termsOfServiceLink,
                              style: TextStyle(
                                color: AppColors.languageButtonColor,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(text: ' ${l10n.terms} '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => context.push('/privacy-webview'),
                            child: Text(
                              l10n.privacyPolicyLink,
                              style: TextStyle(
                                color: AppColors.languageButtonColor,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: AppColors.languageButtonColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isSelected,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isHighlighted
                    ? AppColors.languageButtonColor
                    : AppColors.languageButtonColor)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.languageButtonColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.languageButtonColor : Colors.black87,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

