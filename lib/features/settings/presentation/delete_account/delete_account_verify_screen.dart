import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/chat_history_provider.dart';
import '../../../../core/providers/chat_messages_provider.dart';
import '../../../../core/providers/email_provider.dart';
import '../../../../core/providers/permissions_provider.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/cache_utils.dart';
import '../../../../core/widgets/mara_code_input.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/delete_account_service.dart';
import '../../providers/delete_account_providers.dart';
import 'delete_account_scaffold.dart';

class DeleteAccountVerifyScreen extends ConsumerStatefulWidget {
  const DeleteAccountVerifyScreen({super.key});

  @override
  ConsumerState<DeleteAccountVerifyScreen> createState() =>
      _DeleteAccountVerifyScreenState();
}

class _DeleteAccountVerifyScreenState
    extends ConsumerState<DeleteAccountVerifyScreen> {
  static const int _codeLength = 6;
  final GlobalKey<MaraCodeInputState> _codeInputKey =
      GlobalKey<MaraCodeInputState>();
  String _currentCode = '';
  bool _isSending = false;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendCode();
    });
  }

  Future<void> _sendCode({bool isResend = false}) async {
    if (_isSending) return;
    final email = ref.read(emailProvider);
    if (email == null || email.isEmpty) {
      if (mounted) {
        context.go('/profile');
      }
      return;
    }

    _resetCodeFields();

    setState(() {
      _isSending = true;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref.read(deleteAccountServiceProvider).sendDeleteCode(email);
      if (isResend && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountResentMessage)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.deleteAccountSendCodeError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _resetCodeFields() {
    _codeInputKey.currentState?.clear();
    setState(() {
      _currentCode = '';
    });
  }

  Future<void> _handleDelete() async {
    final code = _currentCode.trim();
    if (code.isEmpty || _isDeleting) return;

    final email = ref.read(emailProvider);
    if (email == null || email.isEmpty) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    try {
      await ref
          .read(deleteAccountServiceProvider)
          .deleteAccount(email: email, code: code);

      await CacheUtils.clearLocalCaches();

      ref.read(chatHistoryProvider.notifier).reset();
      ref.read(chatMessagesProvider.notifier).clearMessages();
      ref.read(userProfileProvider.notifier).reset();
      ref.read(permissionsProvider.notifier).reset();
      await ref.read(emailProvider.notifier).clearEmail();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deleteAccountSuccessMessage)));
      context.go('/language-selector');
    } on DeleteAccountException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.error == DeleteAccountError.invalidCode
            ? l10n.deleteAccountVerificationError
            : l10n.deleteAccountSendCodeError;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.deleteAccountSendCodeError;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isButtonEnabled = _currentCode.length == _codeLength && !_isDeleting;

    return DeleteAccountScaffold(
      onBack: () => context.pop(),
      title: l10n.deleteAccountVerifyTitle,
      subtitle: l10n.deleteAccountVerifySubtitle,
      children: [
        if (_isSending)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        Text(
          l10n.deleteAccountCodeHelper,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        MaraCodeInput(
          key: _codeInputKey,
          length: _codeLength,
          onChanged: (value) {
            setState(() {
              _currentCode = value;
              if (_errorMessage != null && value.isNotEmpty) {
                _errorMessage = null;
              }
            });
          },
          onCompleted: (_) {
            if (!_isDeleting) {
              _handleDelete();
            }
          },
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 320,
            child: PrimaryButton(
              text: l10n.deleteAccountDeleteButton,
              onPressed: isButtonEnabled ? _handleDelete : null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: (_isSending || _isDeleting)
                ? null
                : () => _sendCode(isResend: true),
            child: Text(
              l10n.deleteAccountResend,
              style: TextStyle(
                color: (_isSending || _isDeleting)
                    ? AppColors.textSecondary.withOpacity(0.6)
                    : AppColors.languageButtonColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
