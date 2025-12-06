/// Achievement model representing a user achievement or badge.
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName; // Icon identifier
  final DateTime? unlockedAt;
  final AchievementType type;
  final AchievementCategory category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    this.unlockedAt,
    required this.type,
    required this.category,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    DateTime? unlockedAt,
    AchievementType? type,
    AchievementCategory? category,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }
}

enum AchievementType {
  firstSteps,
  sleepChampion,
  hydrationHero,
  goalCrusher,
  weekWarrior,
  monthMaster,
}

enum AchievementCategory {
  steps,
  sleep,
  water,
  general,
}

