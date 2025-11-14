import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';

class SignInEmailScreen extends StatefulWidget {
  const SignInEmailScreen({super.key});

  @override
  State<SignInEmailScreen> createState() => _SignInEmailScreenState();
}

class _SignInEmailScreenState extends State<SignInEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _onVerifyPressed() {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      // Navigate to verify email screen, then ready screen
      context.go('/verify-email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h * 0.12),
                // Mara logo at the top
                const Center(
                  child: MaraLogo(
                    width: 258,
                    height: 202,
                  ),
                ),
                SizedBox(height: h * 0.06),
                // Title
                const Text(
                  'Enter your email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0EA5C6),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 24),
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(fontFamily: 'Roboto'),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  style: const TextStyle(fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 12),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(fontFamily: 'Roboto'),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  style: const TextStyle(fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 22),
                // Terms checkbox + link
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF0EA5C6),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontFamily: 'Roboto',
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'terms',
                                style: const TextStyle(
                                  color: Color(0xFF0EA5C6),
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Roboto',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final url =
                                        Uri.parse('https://iammara.com/terms');
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.inAppWebView,
                                      );
                                    }
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Verify button (width 320, height 52)
                Center(
                  child: SizedBox(
                    width: 320,
                    height: 52,
                    child: PrimaryButton(
                      text: 'Verify',
                      width: 320,
                      height: 52,
                      borderRadius: 20,
                      onPressed: _agreedToTerms ? _onVerifyPressed : null,
                    ),
                  ),
                ),
                const Spacer(),
                // "Already a member ? Login"
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Welcome Back screen
                      context.push('/welcome-back');
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'Already a member ? ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: Color(0xFF0EA5C6),
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
