import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/delete_account_service.dart';

final deleteAccountServiceProvider = Provider<DeleteAccountService>(
  (ref) => const DeleteAccountService(),
);
