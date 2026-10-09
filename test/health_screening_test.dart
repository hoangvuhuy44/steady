import 'package:flutter_test/flutter_test.dart';
import 'package:steady/models/activity_type.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/screening/health_screening.dart';
import 'package:steady/state/steady_store.dart';

import 'helpers/fake_activity_repository.dart';

HealthScreening screening({
  int age = 35,
  Set<HealthCondition> conditions = const {},
  Set<HealthFlag> flags = const {},
  Set<String> allergies = const {},
  String goal = 'Ăn uống cân bằng',
  bool known = true,
  String medications = '',
  String orders = '',
  String otherAllergies = '',
  String labNotes = '',
  String kidneyStage = '',
}) => HealthScreening(
  age: age,
  height: 170,
  weight: 75,
  goal: goal,
  conditions: conditions,
  flags: flags,
  allergies: allergies,
  conditionsKnown: known,
  allergiesKnown: known,
  treatmentKnown: known,
  medications: medications,
  clinicianOrders: orders,
  otherAllergies: otherAllergies,
  labNotes: labNotes,
  kidneyStage: kidneyStage,
  completedAt: DateTime(2026, 10, 7),
);

const mealProfile = NutritionProfile(
  age: 32,
  height: 170,
  weight: 65,
  goal: 'Hỗ trợ tăng cơ',
  activity: 'Ít vận động',
  cholesterol: 'Chưa biết',
  diet: 'Ăn đa dạng',
  budget: 120000,
  minutes: 30,
  exclusions: {},
);

void main() {
  test('a new guest store cannot create or swap meals without assessment', () {
    final store = SteadyStore();
    addTearDown(store.dispose);
    expect(store.mealPlanningAllowed, isFalse);
    store.setNutritionProfile(mealProfile);
    expect(store.nutritionProfile, isNull);
    expect(store.mealPlan, isEmpty);
    expect(store.swapMeal(0, 0, meals.first), isFalse);
  });
  test('compatible MVP conditions allow illustrative templates only', () {
    final assessment = ScreeningRules.assess(
      screening(
        conditions: {
          HealthCondition.type2Diabetes,
          HealthCondition.hypertension,
          HealthCondition.obesity,
        },
      ),
    );
    expect(assessment.decision, ScreeningDecision.lifestyle);
  });
  test(
    'kidney disease overrides compatible conditions even with lab notes',
    () {
      final assessment = ScreeningRules.assess(
        screening(
          conditions: {
            HealthCondition.type2Diabetes,
            HealthCondition.kidneyDisease,
            HealthCondition.hypertension,
          },
          labNotes: 'eGFR 40; potassium 4.5 mmol/L, 2026-10-07, lab report',
          kidneyStage: 'G3b',
        ),
      );
      expect(assessment.allowsSamplePlan, isFalse);
      expect(assessment.reasons, contains('screeningReasonKidney'));
    },
  );
  test('cancer and unintended weight loss override weight-loss goal', () {
    final assessment = ScreeningRules.assess(
      screening(
        goal: 'Hỗ trợ giảm cân',
        conditions: {HealthCondition.obesity, HealthCondition.cancer},
        flags: {HealthFlag.chemotherapy, HealthFlag.unintendedWeightLoss},
      ),
    );
    expect(assessment.decision, ScreeningDecision.professionalReview);
    expect(assessment.reasons, contains('screeningReasonWeightConflict'));
  });
  test('unknown answers never count as no conditions or allergies', () {
    expect(
      ScreeningRules.assess(screening(known: false)).decision,
      ScreeningDecision.moreInformation,
    );
  });
  test('children, treatment flags, medicines, orders and unmodelled allergies pause plans', () {
    for (final p in [
      screening(age: 17),
      screening(medications: 'warfarin'),
      screening(orders: 'Fluid restriction'),
      screening(otherAllergies: 'mushrooms'),
      for (final flag in HealthFlag.values) screening(flags: {flag}),
    ]) {
      expect(ScreeningRules.assess(p).allowsSamplePlan, isFalse);
    }
  });
  test('store enforces screening, retained allergies and authoritative measurements', () {
    final store = SteadyStore()..beginSession();
    addTearDown(store.dispose);
    store.setNutritionProfile(mealProfile);
    expect(store.nutritionProfile, isNull);
    store.completeScreening(screening(allergies: {'fish', 'soy'}));
    store.setNutritionProfile(mealProfile);
    expect(store.nutritionProfile!.age, 35);
    expect(store.nutritionProfile!.weight, 75);
    expect(store.nutritionProfile!.goal, 'Ăn uống cân bằng');
    expect(store.mealPlan, hasLength(7));
    expect(
      store.mealPlan
          .expand((d) => d)
          .any(
            (m) => m.contains.contains('fish') || m.contains.contains('soy'),
          ),
      isFalse,
    );
    store.requestScreening();
    expect(store.mealPlan, isEmpty);
    store.completeScreening(
      screening(conditions: {HealthCondition.kidneyDisease}),
    );
    store.setNutritionProfile(mealProfile);
    expect(store.nutritionProfile, isNull);
    expect(store.swapMeal(0, 0, meals.first), isFalse);
  });
  test(
    'declining or starting a new account session cannot expose old health data',
    () async {
      final store = SteadyStore(activityRepository: FakeActivityRepository())
        ..beginSession();
      addTearDown(store.dispose);
      store.completeScreening(screening());
      store.setNutritionProfile(mealProfile);
      await store.setActivityOwner('A');
      await store.logActivity(ActivityType.walk, 20);
      store.declineScreening();
      expect(store.healthScreening, isNull);
      expect(store.mealPlanningAllowed, isFalse);
      store.beginSession();
      expect(store.logs, hasLength(1));
      expect(store.points, 20);
      expect(store.screeningRequired, isTrue);
    },
  );
  test('deleting nutrition clears screening details and pauses templates', () {
    final store = SteadyStore()..beginSession();
    addTearDown(store.dispose);
    store.completeScreening(screening());
    store.setNutritionProfile(mealProfile);
    store.clearNutrition();
    expect(store.healthScreening, isNull);
    expect(store.screeningAssessment, isNull);
    expect(store.mealPlan, isEmpty);
    expect(store.mealPlanningAllowed, isFalse);
  });
}
