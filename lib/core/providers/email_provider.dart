import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final emailProvider = StateNotifierProvider<EmailNotifier, String?>((ref) {
  return EmailNotifier();
});

class EmailNotifier extends StateNotifier<String?> {
  EmailNotifier() : super(null) {
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('userEmail');
    if (savedEmail != null) {
      state = savedEmail;
    }
  }

  Future<void> setEmail(String email) async {
    state = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userEmail', email);
  }

  Future<void> clearEmail() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');
  }
}
