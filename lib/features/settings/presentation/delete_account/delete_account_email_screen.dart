import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/email_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mara_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'delete_account_scaffold.dart';

class DeleteAccountEmailScreen extends ConsumerStatefulWidget {
  const DeleteAccountEmailScreen({super.key});

  @override
  ConsumerState<DeleteAccountEmailScreen> createState() =>
      _DeleteAccountEmailScreenState();
}

class _DeleteAccountEmailScreenState
    extends ConsumerState<DeleteAccountEmailScreen> {
  final _emailController = TextEditingController();
  String? _inlineError;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {}); // Refresh button state
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValidEmail {
    final value = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(value);
  }

  void _handleContinue(AppLocalizations l10n, String currentEmail) {
    setState(() {
      _hasInteracted = true;
    });

    if (!_isValidEmail) {
      return;
    }

    final matches = _emailController.text.trim().toLowerCase() ==
        currentEmail.trim().toLowerCase();
    if (!matches) {
      setState(() {
        _inlineError = l10n.deleteAccountEmailMismatchError;
      });
      return;
    }

    setState(() {
      _inlineError = null;
    });
    context.push('/delete-account/code');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentEmail = ref.watch(emailProvider) ?? '';
    final isButtonEnabled = _isValidEmail && currentEmail.isNotEmpty;

    return DeleteAccountScaffold(
      onBack: () => context.pop(),
      title: l10n.deleteAccountEmailTitle,
      subtitle: l10n.deleteAccountEmailSubtitle,
      children: [
        Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MaraTextField(
                label: l10n.emailLabel,
                hint: l10n.enterYourEmail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                enableContextMenu: false,
                onChanged: (_) {
                  if (_hasInteracted) {
                    setState(() {
                      _inlineError = null;
                    });
                  }
                },
              ),
              if (_inlineError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _inlineError!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 320,
                  child: PrimaryButton(
                    text: l10n.continueButton,
                    onPressed: isButtonEnabled
                        ? () => _handleContinue(l10n, currentEmail)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
