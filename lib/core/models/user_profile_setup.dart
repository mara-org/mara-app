/// Domain model for user profile setup data.
///
/// Contains business logic and validation for user profile information.
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

  /// Validates if the profile setup is complete.
  ///
  /// Returns true if all required fields are filled.
  bool get isValid {
    return name != null &&
        name!.isNotEmpty &&
        dateOfBirth != null &&
        gender != null &&
        height != null &&
        height! > 0 &&
        weight != null &&
        weight! > 0;
  }

  /// Gets the display name for the user.
  ///
  /// Returns the name if available, otherwise returns a default.
  String get displayName => name?.trim() ?? 'User';

  /// Validates the name field.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be at most 100 characters';
    }
    return null;
  }

  /// Validates the date of birth.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }
    final age = now.year - value.year;
    if (age < 0 || age > 150) {
      return 'Invalid date of birth';
    }
    return null;
  }

  /// Validates the height value.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateHeight(int? value) {
    if (value == null) {
      return 'Height is required';
    }
    if (value <= 0) {
      return 'Height must be greater than 0';
    }
    // Reasonable height limits (in cm)
    final maxHeight = heightUnit == 'in' ? 300 : 250; // ~8ft in inches, ~8ft in cm
    if (value > maxHeight) {
      return 'Height value seems too large';
    }
    return null;
  }

  /// Validates the weight value.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateWeight(int? value) {
    if (value == null) {
      return 'Weight is required';
    }
    if (value <= 0) {
      return 'Weight must be greater than 0';
    }
    // Reasonable weight limits (in kg)
    final maxWeight = weightUnit == 'lb' ? 1000 : 500; // ~450kg or ~1000lbs
    if (value > maxWeight) {
      return 'Weight value seems too large';
    }
    return null;
  }

  /// Validates the blood type format.
  ///
  /// Returns null if valid, error message if invalid.
  String? validateBloodType(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Blood type is optional
    }
    // Valid blood types: A+, A-, B+, B-, AB+, AB-, O+, O-
    final validBloodTypes = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-'
    ];
    if (!validBloodTypes.contains(value.toUpperCase())) {
      return 'Invalid blood type format';
    }
    return null;
  }

  /// Gets the age in years.
  ///
  /// Returns null if date of birth is not set.
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Gets BMI (Body Mass Index) if height and weight are available.
  ///
  /// Returns null if height or weight is missing.
  double? get bmi {
    if (height == null || weight == null) return null;

    // Convert to metric (kg and cm) for calculation
    double heightInMeters;
    double weightInKg;

    if (heightUnit == 'in') {
      heightInMeters = (height! * 2.54) / 100; // inches to meters
    } else {
      heightInMeters = height! / 100; // cm to meters
    }

    if (weightUnit == 'lb') {
      weightInKg = weight! * 0.453592; // lbs to kg
    } else {
      weightInKg = weight!.toDouble();
    }

    if (heightInMeters <= 0) return null;

    return weightInKg / (heightInMeters * heightInMeters);
  }

  /// Gets BMI category if BMI is available.
  ///
  /// Returns a string describing the BMI category.
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) {
      return 'Underweight';
    } else if (bmiValue < 25) {
      return 'Normal';
    } else if (bmiValue < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

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

  @override
  String toString() =>
      'UserProfileSetup(name: $name, age: $age, gender: $gender, bmi: ${bmi?.toStringAsFixed(1)})';
}

enum Gender { male, female }
