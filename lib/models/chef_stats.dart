/// Модель прогресса игрока (геймификация ZeroWasteChef).
class ChefStats {
  final int xp;
  final int recipesGenerated;
  final int recipesCompleted;
  final int savedIngredients;
  final int streak;
  final DateTime? lastActiveDate;

  const ChefStats({
    this.xp = 0,
    this.recipesGenerated = 0,
    this.recipesCompleted = 0,
    this.savedIngredients = 0,
    this.streak = 0,
    this.lastActiveDate,
  });

  /// Пороги уровней: индекс + 1 = номер уровня.
  static const List<int> levelThresholds = [0, 100, 300, 700, 1500];

  /// Текущий уровень (1..5).
  int get level {
    int result = 1;
    for (int i = 0; i < levelThresholds.length; i++) {
      if (xp >= levelThresholds[i]) result = i + 1;
    }
    return result;
  }

  /// Сколько XP накоплено внутри текущего уровня.
  int get xpIntoLevel => xp - levelThresholds[level - 1];

  /// Сколько XP осталось добрать до следующего уровня.
  int get xpToNextLevel {
    if (level >= levelThresholds.length) return 0;
    return levelThresholds[level] - xp;
  }

  /// Прогресс текущего уровня от 0.0 до 1.0 (для LinearProgressIndicator).
  double get levelProgress {
    if (level >= levelThresholds.length) return 1.0;
    final base = levelThresholds[level - 1];
    final next = levelThresholds[level];
    return ((xp - base) / (next - base)).clamp(0.0, 1.0);
  }

  ChefStats copyWith({
    int? xp,
    int? recipesGenerated,
    int? recipesCompleted,
    int? savedIngredients,
    int? streak,
    DateTime? lastActiveDate,
  }) {
    return ChefStats(
      xp: xp ?? this.xp,
      recipesGenerated: recipesGenerated ?? this.recipesGenerated,
      recipesCompleted: recipesCompleted ?? this.recipesCompleted,
      savedIngredients: savedIngredients ?? this.savedIngredients,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  factory ChefStats.fromMap(Map<String, dynamic> map) {
    return ChefStats(
      xp: (map['xp'] as num?)?.toInt() ?? 0,
      recipesGenerated: (map['recipesGenerated'] as num?)?.toInt() ?? 0,
      recipesCompleted: (map['recipesCompleted'] as num?)?.toInt() ?? 0,
      savedIngredients: (map['savedIngredients'] as num?)?.toInt() ?? 0,
      streak: (map['streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: map['lastActiveDate'] == null
          ? null
          : DateTime.tryParse(map['lastActiveDate'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'xp': xp,
      'recipesGenerated': recipesGenerated,
      'recipesCompleted': recipesCompleted,
      'savedIngredients': savedIngredients,
      'streak': streak,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }
}
