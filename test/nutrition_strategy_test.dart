import 'package:flutter_test/flutter_test.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/nutrition/nutrition_strategy.dart';
import 'package:steady/nutrition/nutrition_targets.dart';
import 'package:steady/screening/health_screening.dart';
import 'package:steady/state/steady_store.dart';

NutritionProfile configuredProfile({
  NutritionStrategy strategy = const NutritionStrategy(),
  HealthScreening? health,
  Set<String> exclusions = const {},
  int budget = 250000,
  double weight = 70,
  double? bodyFat = 20,
  BiologicalSex sex = BiologicalSex.male,
}) => NutritionProfile(
  age: 30,
  height: 175,
  weight: weight,
  bodyFat: bodyFat,
  sex: sex,
  goal: strategy.legacyGoal,
  activity: 'Vừa: 3–4 buổi/tuần',
  cholesterol: 'Chưa biết',
  diet: strategy.source == FoodSource.omnivore ? 'Ăn đa dạng' : 'Chay',
  budget: budget,
  minutes: 30,
  exclusions: exclusions,
  strategy: strategy,
  health: health,
);

HealthScreening healthProfile({
  Set<HealthCondition> conditions = const {},
  Set<HealthFlag> flags = const {},
  NutritionStrategy? strategy,
}) => HealthScreening(
  age: 30,
  height: 175,
  weight: 70,
  bodyFat: 20,
  sex: BiologicalSex.male,
  goal: strategy?.legacyGoal ?? 'Ăn uống cân bằng',
  conditions: conditions,
  flags: flags,
  allergies: {'fish'},
  dislikes: {'Trứng'},
  conditionsKnown: true,
  allergiesKnown: true,
  treatmentKnown: true,
  medications: '',
  clinicianOrders: '',
  completedAt: DateTime(2026, 10, 7),
  nutritionStrategy: strategy,
  activity: 'Vừa: 3–4 buổi/tuần',
  budget: 250000,
);

void main() {
  test('energy strategy changes calories independently from food pattern', () {
    final maintenance = NutritionTargets.estimate(configuredProfile())!;
    final lean = NutritionTargets.estimate(
      configuredProfile(
        strategy: const NutritionStrategy(
          goal: BodyGoal.muscleGain,
          energy: EnergyStrategy.leanBulk,
          source: FoodSource.vegan,
        ),
      ),
    )!;
    final aggressive = NutritionTargets.estimate(
      configuredProfile(
        strategy: const NutritionStrategy(
          goal: BodyGoal.muscleGain,
          energy: EnergyStrategy.aggressiveBulk,
        ),
      ),
    )!;
    final cut = NutritionTargets.estimate(
      configuredProfile(
        strategy: const NutritionStrategy(
          goal: BodyGoal.fatLoss,
          energy: EnergyStrategy.deficit,
        ),
      ),
    )!;
    expect(maintenance.maintenance, closeTo(1648.75 * 1.55, 0.1));
    expect(lean.kcal, closeTo(maintenance.kcal * 1.1, 0.1));
    expect(aggressive.kcal, greaterThan(lean.kcal));
    expect(cut.kcal, lessThan(maintenance.kcal));
    expect(lean.protein, closeTo(126, 0.1));
  });
  test('medical rules override keto and sports protein targets', () {
    const keto = NutritionStrategy(
      goal: BodyGoal.fatLoss,
      energy: EnergyStrategy.deficit,
      macros: MacroStrategy.ketogenic,
    );
    final diabetic = healthProfile(
      conditions: {HealthCondition.type2Diabetes},
      flags: {HealthFlag.sglt2Inhibitor},
      strategy: keto,
    );
    expect(
      ScreeningRules.assess(diabetic).reasons,
      contains('nutritionKetoReview'),
    );
    expect(
      MealPlanner.generate(configuredProfile(strategy: keto, health: diabetic)),
      isEmpty,
    );
    const bulk = NutritionStrategy(
      goal: BodyGoal.muscleGain,
      energy: EnergyStrategy.leanBulk,
    );
    expect(
      NutritionTargets.estimate(
        configuredProfile(
          strategy: bulk,
          health: healthProfile(conditions: {HealthCondition.kidneyDisease}),
        ),
      ),
      isNull,
    );
  });
  for (final strategy in [
    const NutritionStrategy(),
    const NutritionStrategy(
      goal: BodyGoal.muscleGain,
      energy: EnergyStrategy.leanBulk,
      macros: MacroStrategy.highProtein,
      resistanceSessions: 4,
    ),
    const NutritionStrategy(
      goal: BodyGoal.muscleGain,
      energy: EnergyStrategy.aggressiveBulk,
      resistanceSessions: 4,
    ),
    const NutritionStrategy(
      goal: BodyGoal.fatLoss,
      energy: EnergyStrategy.deficit,
    ),
    const NutritionStrategy(
      goal: BodyGoal.recomposition,
      energy: EnergyStrategy.recomp,
      source: FoodSource.vegan,
      resistanceSessions: 3,
    ),
    const NutritionStrategy(macros: MacroStrategy.ketogenic),
    const NutritionStrategy(macros: MacroStrategy.lowCarb),
    const NutritionStrategy(macros: MacroStrategy.lowFat),
    const NutritionStrategy(goal: BodyGoal.performance),
    const NutritionStrategy(goal: BodyGoal.endurance),
    const NutritionStrategy(source: FoodSource.vegetarian),
    const NutritionStrategy(pattern: FoodPattern.mediterranean),
    const NutritionStrategy(timing: MealTiming.timeRestricted),
    const NutritionStrategy(timing: MealTiming.fourMeals),
    const NutritionStrategy(pattern: FoodPattern.paleo),
    const NutritionStrategy(
      pattern: FoodPattern.dash,
      source: FoodSource.vegan,
    ),
  ]) {
    test(
      'menu meets calorie/macro constraints (${strategy.energy.name}/${strategy.macros.name}/${strategy.source.name}/${strategy.timing.name}/${strategy.pattern.name})',
      () {
        final profile = configuredProfile(strategy: strategy);
        final targets = NutritionTargets.estimate(profile)!;
        final watch = Stopwatch()..start();
        final plan = MealPlanner.generate(profile);
        // ignore: avoid_print
        print(
          'generated ${plan.length} days in ${watch.elapsedMilliseconds}ms',
        );
        expect(plan, hasLength(7));
        for (final day in plan) {
          expect(day.length, strategy.timing == MealTiming.fourMeals ? 4 : 3);
          final kcal = day.fold<int>(0, (sum, meal) => sum + meal.kcal);
          expect(
            kcal,
            inInclusiveRange(targets.kcal * 0.9, targets.kcal * 1.1),
          );
          expect(
            day.fold<int>(0, (sum, meal) => sum + meal.protein),
            greaterThanOrEqualTo(targets.protein * 0.9),
          );
          expect(
            day.fold<int>(0, (sum, meal) => sum + meal.protein),
            lessThanOrEqualTo(targets.protein * 1.3),
          );
          expect(
            day.fold<int>(0, (sum, meal) => sum + meal.fibre),
            greaterThanOrEqualTo(25),
          );
          expect(
            day.fold<double>(0, (sum, meal) => sum + meal.sodium),
            lessThanOrEqualTo(targets.sodiumLimit),
          );
          expect(
            day.fold<double>(0, (sum, meal) => sum + meal.saturatedFat),
            lessThanOrEqualTo(targets.saturatedFatLimit),
          );
          if (strategy.macros != MacroStrategy.ketogenic) {
            expect(
              day.fold<double>(0, (sum, meal) => sum + meal.carbs),
              inInclusiveRange(targets.carbs * 0.75, targets.carbs * 1.25),
            );
            expect(
              day.fold<double>(0, (sum, meal) => sum + meal.fat),
              inInclusiveRange(targets.fat * 0.7, targets.fat * 1.3),
            );
          }
          expect(
            day.fold<int>(0, (sum, meal) => sum + meal.cost),
            lessThanOrEqualTo(profile.budget),
          );
          if (strategy.macros == MacroStrategy.ketogenic) {
            expect(
              day.fold<double>(0, (sum, meal) => sum + meal.carbs),
              lessThanOrEqualTo(50),
            );
          }
          if (strategy.source == FoodSource.vegan) {
            expect(
              day.any(
                (meal) => meal.contains.intersection({
                  'fish',
                  'meat',
                  'milk',
                  'egg',
                }).isNotEmpty,
              ),
              isFalse,
            );
          }
        }
      },
    );
  }
  test(
    'infeasible calorie budget keeps hard exclusions and returns no plan',
    () {
      expect(MealPlanner.generate(configuredProfile(budget: 10000)), isEmpty);
      expect(
        MealPlanner.generate(
          configuredProfile(
            exclusions: {'soy', 'fish', 'meat', 'egg', 'gluten'},
          ),
        ),
        isEmpty,
      );
    },
  );
  test('missing and conflicting inputs do not silently produce targets', () {
    expect(
      NutritionTargets.unavailableReason(
        configuredProfile(sex: BiologicalSex.unspecified),
      ),
      'nutritionNeedSex',
    );
    expect(
      NutritionTargets.unavailableReason(
        configuredProfile(bodyFat: double.nan),
      ),
      'nutritionInvalidMeasurements',
    );
    expect(
      NutritionTargets.unavailableReason(
        configuredProfile(
          strategy: const NutritionStrategy(
            goal: BodyGoal.fatLoss,
            energy: EnergyStrategy.leanBulk,
          ),
        ),
      ),
      'nutritionGoalConflict',
    );
    expect(
      NutritionTargets.unavailableReason(
        configuredProfile(
          weight: 45,
          strategy: const NutritionStrategy(
            goal: BodyGoal.fatLoss,
            energy: EnergyStrategy.deficit,
          ),
        ),
      ),
      'nutritionLowWeightReview',
    );
    expect(
      NutritionTargets.estimate(configuredProfile(bodyFat: null)),
      isNotNull,
    );
  });
  test('hypertension sets sodium constraint; medical conditions override aggressive bulk', () {
    final profile = configuredProfile(
      health: healthProfile(conditions: {HealthCondition.hypertension}),
    );
    final plan = MealPlanner.generate(profile);
    expect(plan, hasLength(7));
    expect(NutritionTargets.estimate(profile)!.sodiumLimit, 1500);
    const bulk = NutritionStrategy(
      goal: BodyGoal.muscleGain,
      energy: EnergyStrategy.aggressiveBulk,
    );
    expect(
      MealPlanner.generate(
        configuredProfile(
          strategy: bulk,
          health: healthProfile(
            conditions: {HealthCondition.hypertension},
            strategy: bulk,
          ),
        ),
      ),
      isEmpty,
    );
  });
  test(
    'completion generates once and swapping preserves the daily targets',
    () {
      final store = SteadyStore()..beginSession();
      addTearDown(store.dispose);
      store.completeScreening(
        healthProfile(
          strategy: const NutritionStrategy(
            goal: BodyGoal.muscleGain,
            energy: EnergyStrategy.leanBulk,
            resistanceSessions: 3,
          ),
        ),
      );
      expect(store.mealPlan, hasLength(7));
      expect(
        store.nutritionProfile!.exclusions,
        containsAll(['fish', 'Trứng']),
      );
      final before = store.mealPlan[0][1];
      final alternatives = MealPlanner.alternatives(
        store.nutritionProfile!,
        store.mealPlan[0],
        1,
      );
      expect(alternatives, isNotEmpty);
      expect(store.swapMeal(0, 1, alternatives.first), isTrue);
      expect(store.mealPlan[0][1].id, isNot(before.id));
      final targets = store.nutritionTargets!;
      expect(
        store.mealPlan[0].fold<int>(0, (sum, m) => sum + m.kcal),
        inInclusiveRange(targets.kcal * 0.9, targets.kcal * 1.1),
      );
      store.beginSession();
      expect(store.mealPlan, isEmpty);
      expect(store.nutritionProfile, isNull);
    },
  );
}
