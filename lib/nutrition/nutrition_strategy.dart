enum BodyGoal {
  health,
  fatLoss,
  muscleGain,
  recomposition,
  performance,
  endurance,
}

enum EnergyStrategy { maintenance, deficit, leanBulk, aggressiveBulk, recomp }

enum MacroStrategy { balanced, highProtein, lowCarb, ketogenic, lowFat }

enum FoodPattern { balanced, mediterranean, dash, paleo }

enum FoodSource { omnivore, vegetarian, vegan }

enum MealTiming { threeMeals, fourMeals, timeRestricted }

enum BiologicalSex { unspecified, female, male }

enum TrainingExperience { beginner, intermediate, advanced }

class NutritionStrategy {
  const NutritionStrategy({
    this.goal = BodyGoal.health,
    this.energy = EnergyStrategy.maintenance,
    this.macros = MacroStrategy.balanced,
    this.pattern = FoodPattern.balanced,
    this.source = FoodSource.omnivore,
    this.timing = MealTiming.threeMeals,
    this.experience = TrainingExperience.beginner,
    this.resistanceSessions = 0,
    this.energyAdjustment = 0,
  });
  final BodyGoal goal;
  final EnergyStrategy energy;
  final MacroStrategy macros;
  final FoodPattern pattern;
  final FoodSource source;
  final MealTiming timing;
  final TrainingExperience experience;
  final int resistanceSessions;
  final int energyAdjustment;

  NutritionStrategy copyWith({
    BodyGoal? goal,
    EnergyStrategy? energy,
    MacroStrategy? macros,
    FoodPattern? pattern,
    FoodSource? source,
    MealTiming? timing,
    TrainingExperience? experience,
    int? resistanceSessions,
    int? energyAdjustment,
  }) => NutritionStrategy(
    goal: goal ?? this.goal,
    energy: energy ?? this.energy,
    macros: macros ?? this.macros,
    pattern: pattern ?? this.pattern,
    source: source ?? this.source,
    timing: timing ?? this.timing,
    experience: experience ?? this.experience,
    resistanceSessions: resistanceSessions ?? this.resistanceSessions,
    energyAdjustment: energyAdjustment ?? this.energyAdjustment,
  );

  static EnergyStrategy energyFor(BodyGoal goal) => switch (goal) {
    BodyGoal.fatLoss => EnergyStrategy.deficit,
    BodyGoal.muscleGain => EnergyStrategy.leanBulk,
    BodyGoal.recomposition => EnergyStrategy.recomp,
    _ => EnergyStrategy.maintenance,
  };
  String get legacyGoal => switch (goal) {
    BodyGoal.fatLoss => 'Hỗ trợ giảm cân',
    BodyGoal.muscleGain || BodyGoal.recomposition => 'Hỗ trợ tăng cơ',
    _ => 'Ăn uống cân bằng',
  };
}
