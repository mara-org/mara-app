import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/data/datasources/auth_remote_data_source_impl.dart'
    show VerificationCooldownException, VerificationRateLimitException;

class DeleteAccountService {
  final AuthRepository _authRepository;

  const DeleteAccountService(this._authRepository);

  /// Request backend to send the delete-account verification code.
  Future<void> sendDeleteCode(String email) async {
    try {
      final success = await _authRepository.sendDeleteAccountCode(email);
      if (!success) {
        throw const DeleteAccountException(DeleteAccountError.network);
      }
    } on VerificationCooldownException catch (e) {
      throw DeleteAccountException(
        DeleteAccountError.network,
        message: e.message,
      );
    } catch (e) {
      if (e is DeleteAccountException) rethrow;
      throw const DeleteAccountException(DeleteAccountError.network);
    }
  }

  /// Submit the verification code to permanently delete the account.
  Future<void> deleteAccount({
    required String email,
    required String code,
  }) async {
    if (code.trim().isEmpty) {
      throw const DeleteAccountException(DeleteAccountError.invalidCode);
    }

    try {
      final success = await _authRepository.deleteAccount(
        email: email,
        code: code,
      );
      if (!success) {
        throw const DeleteAccountException(DeleteAccountError.invalidCode);
      }
    } on VerificationRateLimitException catch (e) {
      throw DeleteAccountException(
        DeleteAccountError.network,
        message: e.message,
      );
    } catch (e) {
      if (e is DeleteAccountException) rethrow;
      throw const DeleteAccountException(DeleteAccountError.invalidCode);
    }
  }
}

class DeleteAccountException implements Exception {
  final DeleteAccountError error;
  final String? message;
  const DeleteAccountException(this.error, {this.message});

  @override
  String toString() => message ?? error.toString();
}

enum DeleteAccountError { invalidCode, network }
