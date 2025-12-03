import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_setup.dart';

class UserProfileNotifier extends StateNotifier<UserProfileSetup> {
  UserProfileNotifier() : super(UserProfileSetup());

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDateOfBirth(DateTime dateOfBirth) {
    state = state.copyWith(dateOfBirth: dateOfBirth);
  }

  void setGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void setHeight(int height, String unit) {
    state = state.copyWith(height: height, heightUnit: unit);
  }

  void setWeight(int weight, String unit) {
    state = state.copyWith(weight: weight, weightUnit: unit);
  }

  void setBloodType(String bloodType) {
    state = state.copyWith(bloodType: bloodType);
  }

  void setMainGoal(String goal) {
    state = state.copyWith(mainGoal: goal);
  }

  void reset() {
    state = UserProfileSetup();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileSetup>(
  (ref) => UserProfileNotifier(),
);
