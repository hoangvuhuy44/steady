import '../screening/health_screening.dart';
import 'nutrition_profile.dart';
import 'nutrition_strategy.dart';

/// Starting estimates for adults, not validated therapeutic prescriptions.
class NutritionTargets {
  const NutritionTargets({
    required this.maintenance,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.sodiumLimit,
    required this.saturatedFatLimit,
    this.notes = const [],
  });
  final double maintenance,
      kcal,
      protein,
      carbs,
      fat,
      sodiumLimit,
      saturatedFatLimit;
  final List<String> notes;

  static String? unavailableReason(NutritionProfile p) {
    if (!p.supported) return 'nutritionMedicalReview';
    if (!p.height.isFinite ||
        !p.weight.isFinite ||
        p.height < 50 ||
        p.height > 250 ||
        p.weight < 10 ||
        p.weight > 400 ||
        p.age > 120 ||
        (p.bodyFat != null &&
            (!p.bodyFat!.isFinite || p.bodyFat! < 3 || p.bodyFat! > 65))) {
      return 'nutritionInvalidMeasurements';
    }
    if (p.health != null &&
        !ScreeningRules.assess(p.health!).allowsSamplePlan) {
      return 'nutritionMedicalReview';
    }
    final s = p.strategy;
    if (s == null) return null;
    if (p.sex == BiologicalSex.unspecified) return 'nutritionNeedSex';
    if (s.resistanceSessions < 0 || s.resistanceSessions > 7) {
      return 'nutritionInvalidMeasurements';
    }
    if ((s.goal == BodyGoal.muscleGain && s.energy == EnergyStrategy.deficit) ||
        (s.goal == BodyGoal.fatLoss &&
            [
              EnergyStrategy.leanBulk,
              EnergyStrategy.aggressiveBulk,
            ].contains(s.energy)) ||
        (s.goal == BodyGoal.recomposition &&
            [
              EnergyStrategy.leanBulk,
              EnergyStrategy.aggressiveBulk,
            ].contains(s.energy))) {
      return 'nutritionGoalConflict';
    }
    final bmi = p.weight / ((p.height / 100) * (p.height / 100));
    if (bmi < 18.5 &&
        [EnergyStrategy.deficit, EnergyStrategy.recomp].contains(s.energy)) {
      return 'nutritionLowWeightReview';
    }
    final conditions = p.health?.conditions ?? <HealthCondition>{};
    if (s.macros == MacroStrategy.ketogenic &&
        conditions.any((c) => c != HealthCondition.asthma)) {
      return 'nutritionKetoReview';
    }
    if (s.energy == EnergyStrategy.aggressiveBulk &&
        conditions.any((c) => c != HealthCondition.asthma)) {
      return 'nutritionBulkReview';
    }
    if (s.pattern == FoodPattern.paleo && s.source != FoodSource.omnivore) {
      return 'nutritionPatternConflict';
    }
    if (![
      'Ít vận động',
      'Nhẹ: 1–2 buổi/tuần',
      'Vừa: 3–4 buổi/tuần',
      'Nhiều: 5+ buổi/tuần',
    ].contains(p.activity)) {
      return 'nutritionInvalidMeasurements';
    }
    return null;
  }

  static NutritionTargets? estimate(NutritionProfile p) {
    final s = p.strategy;
    if (s == null || unavailableReason(p) != null) return null;
    final resting =
        10 * p.weight +
        6.25 * p.height -
        5 * p.age +
        (p.sex == BiologicalSex.male ? 5 : -161);
    final activity = switch (p.activity) {
      'Nhẹ: 1–2 buổi/tuần' => 1.375,
      'Vừa: 3–4 buổi/tuần' => 1.55,
      'Nhiều: 5+ buổi/tuần' => 1.725,
      _ => 1.2,
    };
    final maintenance = resting * activity;
    final factor = switch (s.energy) {
      EnergyStrategy.deficit => 0.85,
      EnergyStrategy.leanBulk =>
        s.experience == TrainingExperience.advanced ? 1.05 : 1.10,
      EnergyStrategy.aggressiveBulk => 1.15,
      EnergyStrategy.recomp || EnergyStrategy.maintenance => 1.0,
    };
    final kcal = maintenance * factor + s.energyAdjustment;
    // Reject extreme estimates instead of silently clamping an implausible plan.
    if (kcal < resting ||
        kcal < 1200 ||
        kcal > 4500 ||
        s.energyAdjustment.abs() > maintenance * 0.10) {
      return null;
    }
    final muscle =
        [
          BodyGoal.muscleGain,
          BodyGoal.recomposition,
          BodyGoal.fatLoss,
        ].contains(s.goal) ||
        s.macros == MacroStrategy.highProtein ||
        [
          EnergyStrategy.leanBulk,
          EnergyStrategy.aggressiveBulk,
        ].contains(s.energy) ||
        s.resistanceSessions > 0;
    final protein =
        p.weight *
        (muscle
            ? 1.8
            : s.macros == MacroStrategy.ketogenic ||
                  [BodyGoal.performance, BodyGoal.endurance].contains(s.goal)
            ? 1.6
            : 1.2);
    final carbCalories = switch (s.macros) {
      MacroStrategy.ketogenic => 30.0 * 4,
      MacroStrategy.lowCarb => kcal * 0.25,
      MacroStrategy.lowFat => kcal - protein * 4 - kcal * 0.20,
      _ => kcal - protein * 4 - kcal * 0.30,
    };
    final carbs = carbCalories / 4;
    final fat = (kcal - protein * 4 - carbCalories) / 9;
    if (carbs < 0 || fat < 0.5 * p.weight) return null;
    final hypertension =
        p.health?.conditions.contains(HealthCondition.hypertension) == true;
    return NutritionTargets(
      maintenance: maintenance,
      kcal: kcal,
      protein: protein,
      carbs: carbs,
      fat: fat,
      sodiumLimit: hypertension || s.pattern == FoodPattern.dash ? 1500 : 2300,
      saturatedFatLimit:
          kcal * (p.cholesterol == 'Đã xác nhận' ? 0.06 : 0.10) / 9,
      notes: [
        'nutritionEstimateNote',
        if (s.energy == EnergyStrategy.aggressiveBulk) 'nutritionBulkTradeoff',
        if ([BodyGoal.muscleGain, BodyGoal.recomposition].contains(s.goal) &&
            s.resistanceSessions == 0)
          'nutritionTrainingNote',
        if (s.macros == MacroStrategy.ketogenic &&
            [
              BodyGoal.muscleGain,
              BodyGoal.performance,
              BodyGoal.endurance,
            ].contains(s.goal))
          'nutritionKetoPerformance',
        if (s.source == FoodSource.vegan) 'nutritionVeganNote',
      ],
    );
  }
}
