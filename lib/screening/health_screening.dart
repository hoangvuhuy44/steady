import '../nutrition/nutrition_strategy.dart';

/// Self-reported conditions, never diagnoses inferred from measurements.
enum HealthCondition {
  type1Diabetes,
  type2Diabetes,
  lungDisease,
  cancer,
  kidneyDisease,
  transplant,
  obesity,
  heartDisease,
  stroke,
  downSyndrome,
  hiv,
  neurologicalDisease,
  bloodDisorder,
  asthma,
  hypertension,
  immunodeficiency,
  fattyLiver,
  otherLiverDisease,
  substanceUse,
  immunosuppressiveTherapy,
  systemicDisease,
  congenitalDisease,
  other,
}

enum HealthFlag {
  pregnantOrBreastfeeding,
  eatingDisorder,
  dialysis,
  chemotherapy,
  insulin,
  swallowingDifficulty,
  unintendedWeightLoss,
  poorIntake,
  severeComplications,
  sglt2Inhibitor,
}

enum ScreeningDecision { lifestyle, moreInformation, professionalReview }

class HealthScreening {
  HealthScreening({
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required Set<HealthCondition> conditions,
    required Set<HealthFlag> flags,
    required Set<String> allergies,
    required this.conditionsKnown,
    required this.allergiesKnown,
    required this.treatmentKnown,
    required this.medications,
    required this.clinicianOrders,
    this.otherAllergies = '',
    this.kidneyStage = '',
    this.labNotes = '',
    required this.completedAt,
    this.bodyFat,
    this.sex = BiologicalSex.unspecified,
    this.nutritionStrategy,
    this.activity = 'Ít vận động',
    this.budget = 150000,
    this.cookingMinutes = 30,
    Set<String> dislikes = const {},
  }) : conditions = Set.unmodifiable(conditions),
       flags = Set.unmodifiable(flags),
       allergies = Set.unmodifiable(allergies),
       dislikes = Set.unmodifiable(dislikes);

  final int age;
  final double height, weight;
  final String goal;
  final Set<HealthCondition> conditions;
  final Set<HealthFlag> flags;
  final Set<String> allergies;
  final bool conditionsKnown, allergiesKnown, treatmentKnown;
  final String medications,
      clinicianOrders,
      otherAllergies,
      kidneyStage,
      labNotes;
  final DateTime completedAt;
  final double? bodyFat;
  final BiologicalSex sex;
  final NutritionStrategy? nutritionStrategy;
  final String activity;
  final int budget, cookingMinutes;
  final Set<String> dislikes;
}

class ScreeningAssessment {
  ScreeningAssessment(
    this.decision,
    Iterable<String> reasons, {
    Iterable<String> guidance = const [],
  }) : reasons = List.unmodifiable(reasons),
       guidance = List.unmodifiable(guidance);
  final ScreeningDecision decision;

  /// Localisation keys describing product scope, not clinical risk scores.
  final List<String> reasons;
  final List<String> guidance;
  bool get allowsSamplePlan => decision == ScreeningDecision.lifestyle;
}

class ScreeningRules {
  static const version = '2026-10-07';
  static const basicConditions = {
    HealthCondition.type2Diabetes,
    HealthCondition.obesity,
    HealthCondition.hypertension,
    HealthCondition.fattyLiver,
    HealthCondition.asthma,
  };

  static ScreeningAssessment assess(HealthScreening profile) {
    final reasons = <String>{};
    if (profile.age < 18) reasons.add('screeningReasonChild');
    if (profile.flags.isNotEmpty) reasons.add('screeningReasonTreatment');
    if (profile.conditions.any((c) => !basicConditions.contains(c))) {
      reasons.add('screeningReasonComplex');
    }
    if (profile.clinicianOrders.trim().isNotEmpty) {
      reasons.add('screeningReasonOrders');
    }
    if (profile.medications.trim().isNotEmpty) {
      reasons.add('screeningReasonMedication');
    }
    if (profile.otherAllergies.trim().isNotEmpty) {
      reasons.add('screeningReasonAllergy');
    }
    if (profile.conditions.contains(HealthCondition.kidneyDisease)) {
      reasons.add('screeningReasonKidney');
    }
    final strategy = profile.nutritionStrategy;
    if (strategy?.macros == MacroStrategy.ketogenic &&
        (profile.flags.contains(HealthFlag.sglt2Inhibitor) ||
            profile.conditions.any((c) => c != HealthCondition.asthma))) {
      reasons.add('nutritionKetoReview');
    }
    if (strategy?.energy == EnergyStrategy.aggressiveBulk &&
        profile.conditions.any((c) => c != HealthCondition.asthma)) {
      reasons.add('nutritionBulkReview');
    }
    if (profile.goal == 'Hỗ trợ giảm cân' &&
        (profile.conditions.contains(HealthCondition.cancer) ||
            profile.flags.contains(HealthFlag.unintendedWeightLoss) ||
            profile.flags.contains(HealthFlag.poorIntake))) {
      reasons.add('screeningReasonWeightConflict');
    }
    if (reasons.isNotEmpty) {
      return ScreeningAssessment(ScreeningDecision.professionalReview, reasons);
    }
    if (!profile.conditionsKnown ||
        !profile.allergiesKnown ||
        !profile.treatmentKnown) {
      return ScreeningAssessment(ScreeningDecision.moreInformation, [
        'screeningReasonUnknown',
      ]);
    }
    return ScreeningAssessment(
      ScreeningDecision.lifestyle,
      ['screeningReasonLifestyle'],
      guidance: [
        if (profile.conditions.contains(HealthCondition.type2Diabetes))
          'diabetes',
        if (profile.conditions.contains(HealthCondition.hypertension)) 'sodium',
      ],
    );
  }
}
