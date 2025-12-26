import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/delete_account_service.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../../core/di/dependency_injection.dart';

final deleteAccountServiceProvider = Provider<DeleteAccountService>(
  (ref) => DeleteAccountService(ref.read(authRepositoryProvider)),
);
