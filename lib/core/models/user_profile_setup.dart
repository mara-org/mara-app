class UserProfileSetup {
  String? name;
  DateTime? dateOfBirth;
  Gender? gender;
  int? height; // in cm or inches
  String? heightUnit; // 'cm' or 'in'
  int? weight; // in kg or lbs
  String? weightUnit; // 'kg' or 'lb'
  String? bloodType; // e.g., 'A+', 'B-', etc.
  String? mainGoal; // e.g., 'Stay active', 'Reduce stress', etc.

  UserProfileSetup({
    this.name,
    this.dateOfBirth,
    this.gender,
    this.height,
    this.heightUnit,
    this.weight,
    this.weightUnit,
    this.bloodType,
    this.mainGoal,
  });

  UserProfileSetup copyWith({
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
    int? height,
    String? heightUnit,
    int? weight,
    String? weightUnit,
    String? bloodType,
    String? mainGoal,
  }) {
    return UserProfileSetup(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      heightUnit: heightUnit ?? this.heightUnit,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      bloodType: bloodType ?? this.bloodType,
      mainGoal: mainGoal ?? this.mainGoal,
    );
  }
}

enum Gender {
  male,
  female,
}

