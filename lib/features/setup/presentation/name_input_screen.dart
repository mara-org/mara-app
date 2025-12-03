import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_profile_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/mara_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';

class NameInputScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;
  final bool fromLanguageChange;
  final String? languageCode;

  const NameInputScreen({
    super.key,
    this.isFromProfile = false,
    this.fromLanguageChange = false,
    this.languageCode,
  });

  @override
  ConsumerState<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends ConsumerState<NameInputScreen> {
  late final TextEditingController _nameController;
  bool _canContinue = false;

  TextInputFormatter _formatterForLanguage(String languageCode) {
    if (languageCode == 'en') {
      return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'));
    }
    if (languageCode == 'ar') {
      return FilteringTextInputFormatter.allow(RegExp(r'[ء-ي ]'));
    }
    // Fallback to allow any Unicode letters plus spaces.
    return FilteringTextInputFormatter.allow(
      RegExp(r'[\p{L} ]', unicode: true),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    if (widget.isFromProfile && !widget.fromLanguageChange) {
      final currentName = ref.read(userProfileProvider).name ?? '';
      if (currentName.isNotEmpty) {
        _nameController.text = currentName;
      }
    }
    _canContinue = _nameController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(userProfileProvider.notifier).setName(name);
      if (widget.fromLanguageChange || widget.isFromProfile) {
        context.go('/profile');
      } else {
        context.push('/dob-input');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedLocale = Localizations.localeOf(context).languageCode;
    final effectiveLanguage = widget.languageCode ?? resolvedLocale;
    final formatters = <TextInputFormatter>[];

    final nameFormatter = _formatterForLanguage(effectiveLanguage);
    formatters.add(nameFormatter);
    if (effectiveLanguage == 'ar') {
      formatters.add(FilteringTextInputFormatter.deny(RegExp(r'[0-9٠-٩۰-۹]')));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: PlatformUtils.getDefaultPadding(context),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Back button
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.languageButtonColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.languageButtonColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mara logo
                const Center(child: MaraLogo(width: 258, height: 202)),
                const SizedBox(height: 40),
                // Title
                Text(
                  widget.fromLanguageChange
                      ? _languageChangeTitle(
                          widget.languageCode ?? resolvedLocale,
                        )
                      : l10n.whatsYourName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  l10n.nameSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Name field (width 324, same as button)
                Center(
                  child: SizedBox(
                    width: 324,
                    child: MaraTextField(
                      hint: l10n.enterYourName,
                      controller: _nameController,
                      onChanged: (_) {
                        setState(() {
                          _canContinue = _nameController.text.trim().isNotEmpty;
                        });
                      },
                      inputFormatters: formatters,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: l10n.continueButtonText,
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: _canContinue ? _handleContinue : null,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _languageChangeTitle(String languageCode) {
  if (languageCode == 'ar') {
    return 'نعتذر، لكن يجب أن تُدخل اسمك بالعربية ليتطابق مع لغة التطبيق.';
  }
  return 'Sorry, but you have to re-enter your name in English to match the app language.';
}
