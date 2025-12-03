class DeleteAccountService {
  const DeleteAccountService();

  /// Request backend to send the delete-account verification code.
  Future<void> sendDeleteCode(String email) async {
    // TODO: integrate with real backend endpoint (e.g. POST /auth/send-delete-code).
    await Future.delayed(const Duration(milliseconds: 600));
  }

  /// Submit the verification code to permanently delete the account.
  Future<void> deleteAccount({
    required String email,
    required String code,
  }) async {
    // TODO: integrate with real backend endpoint (e.g. POST /auth/delete-account).
    await Future.delayed(const Duration(milliseconds: 600));
    if (code.trim().isEmpty) {
      throw const DeleteAccountException(DeleteAccountError.invalidCode);
    }
  }
}

class DeleteAccountException implements Exception {
  final DeleteAccountError error;
  const DeleteAccountException(this.error);
}

enum DeleteAccountError { invalidCode, network }
