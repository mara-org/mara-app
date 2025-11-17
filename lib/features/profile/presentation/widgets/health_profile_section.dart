import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/user_profile_provider.dart';
import '../../../../core/models/user_profile_setup.dart';
import '../../../../core/theme/app_colors.dart';

class HealthProfileSection extends ConsumerWidget {
  const HealthProfileSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Health Profile',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _HealthProfileRow(
                label: 'Name',
                value: profile.name ?? 'Not set',
                onTap: () => _showNameEditor(context, ref, profile.name),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Date of Birth',
                value: profile.dateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(profile.dateOfBirth!)
                    : 'Not set',
                onTap: () => _showDatePicker(context, ref),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Gender',
                value: profile.gender != null
                    ? profile.gender == Gender.male
                        ? 'Male'
                        : 'Female'
                    : 'Not set',
                onTap: () => _showGenderPicker(context, ref),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Height',
                value: profile.height != null && profile.heightUnit != null
                    ? '${profile.height} ${profile.heightUnit}'
                    : 'Not set',
                onTap: () => context.push('/height'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Weight',
                value: profile.weight != null && profile.weightUnit != null
                    ? '${profile.weight} ${profile.weightUnit}'
                    : 'Not set',
                onTap: () => context.push('/weight'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Blood Type',
                value: profile.bloodType ?? 'Not set',
                onTap: () => context.push('/blood-type'),
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: const Color(0xFF0EA5C6).withOpacity(1.0), // #0EA5C6, 100% opacity
              ),
              _HealthProfileRow(
                label: 'Main Goal',
                value: profile.mainGoal ?? 'Not set',
                onTap: () => context.push('/goals'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNameEditor(BuildContext context, WidgetRef ref, String? currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(userProfileProvider.notifier).setName(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) {
    final currentDate = ref.read(userProfileProvider).dateOfBirth ?? DateTime.now();
    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        ref.read(userProfileProvider.notifier).setDateOfBirth(date);
      }
    });
  }

  void _showGenderPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Gender',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Male'),
                leading: const Icon(Icons.male),
                onTap: () {
                  ref.read(userProfileProvider.notifier).setGender(Gender.male);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Female'),
                leading: const Icon(Icons.female),
                onTap: () {
                  ref.read(userProfileProvider.notifier).setGender(Gender.female);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _HealthProfileRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF0F172A), // #0F172A
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF64748B), // #64748B
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

