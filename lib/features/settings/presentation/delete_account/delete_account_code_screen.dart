import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/mara_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import 'delete_account_scaffold.dart';

class DeleteAccountCodeScreen extends ConsumerStatefulWidget {
  const DeleteAccountCodeScreen({super.key});

  @override
  ConsumerState<DeleteAccountCodeScreen> createState() =>
      _DeleteAccountCodeScreenState();
}

class _DeleteAccountCodeScreenState
    extends ConsumerState<DeleteAccountCodeScreen> {
  final _phraseController = TextEditingController();
  bool _hasTyped = false;

  @override
  void initState() {
    super.initState();
    _phraseController.addListener(() {
      setState(() {}); // Refresh UI for button & error states
    });
  }

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phrase = l10n.deleteAccountPhrase;
    final normalizedInput =
        _phraseController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final normalizedPhrase =
        phrase.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final matchesPhrase =
        normalizedInput.isNotEmpty && normalizedInput == normalizedPhrase;
    final shouldShowError =
        _hasTyped && _phraseController.text.trim().isNotEmpty && !matchesPhrase;

    return DeleteAccountScaffold(
      onBack: () => context.pop(),
      title: l10n.deleteAccountPhraseTitle,
      subtitle: l10n.deleteAccountPhraseSubtitle(phrase),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaraTextField(
              label: l10n.deleteAccountPhraseTitle,
              hint: phrase,
              controller: _phraseController,
              enableContextMenu: false,
              onChanged: (_) {
                if (!_hasTyped) {
                  setState(() {
                    _hasTyped = true;
                  });
                }
              },
            ),
            if (shouldShowError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.deleteAccountPhraseError,
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
                  onPressed:
                      matchesPhrase ? () => context.push('/delete-account/verify') : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

