import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/mara_logo.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/platform_utils.dart';
import '../../../core/providers/user_profile_provider.dart';

class BloodTypeScreen extends ConsumerStatefulWidget {
  final bool isFromProfile;
  
  const BloodTypeScreen({super.key, this.isFromProfile = false});

  @override
  ConsumerState<BloodTypeScreen> createState() => _BloodTypeScreenState();
}

class _BloodTypeScreenState extends ConsumerState<BloodTypeScreen> {
  String? _selectedBloodType;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  void _handleContinue() {
    if (_selectedBloodType != null) {
      ref.read(userProfileProvider.notifier).setBloodType(_selectedBloodType!);
      if (widget.isFromProfile) {
        context.go('/profile');
      } else {
        context.push('/goals');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  alignment: Alignment.centerLeft,
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
                const Center(
                  child: MaraLogo(
                    width: 258,
                    height: 202,
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  "What's your blood type?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.languageButtonColor,
                    fontSize: 26,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 40),
                // Blood type grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _bloodTypes.length,
                  itemBuilder: (context, index) {
                    final bloodType = _bloodTypes[index];
                    final isSelected = _selectedBloodType == bloodType;
                    return _BloodTypeButton(
                      text: bloodType,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedBloodType = bloodType;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
                // Continue button
                PrimaryButton(
                  text: 'Continue',
                  width: 324,
                  height: 52,
                  borderRadius: 20,
                  onPressed: _selectedBloodType != null ? _handleContinue : null,
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

class _BloodTypeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _BloodTypeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? const Color(0xFFC4F4FF)
              : const Color(0xFFFFFFFF),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFF10A9CC)
                  : const Color(0xFF94A3B8),
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

