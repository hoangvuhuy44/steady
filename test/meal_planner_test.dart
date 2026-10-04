import 'package:flutter_test/flutter_test.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/state/steady_store.dart';

NutritionProfile profile({
  Set<String> exclusions = const {},
  int budget = 150000,
  int minutes = 30,
  int age = 30,
  String diet = 'Ăn đa dạng',
  bool professional = false,
}) => NutritionProfile(
  age: age,
  height: 175,
  weight: 70,
  goal: 'Ăn uống cân bằng',
  activity: 'Vừa: 3–4 buổi/tuần',
  cholesterol: 'Đã xác nhận',
  diet: diet,
  budget: budget,
  minutes: minutes,
  exclusions: exclusions,
  needsProfessionalPlan: professional,
);

void main() {
  test('allergy, dislike and vegetarian exclusions survive generation', () {
    final p = profile(
      exclusions: {'soy', 'gluten', 'Ức gà bỏ da'},
      diet: 'Chay',
    );
    final plan = MealPlanner.generate(p);
    expect(plan, hasLength(7));
    for (final meal in plan.expand((d) => d)) {
      expect(
        meal.contains.intersection({'soy', 'gluten', 'fish', 'meat'}),
        isEmpty,
      );
      expect(meal.ingredients.containsKey('Ức gà bỏ da'), isFalse);
    }
  });
  test('every day respects budget and every recipe respects time', () {
    final p = profile(budget: 100000, minutes: 25);
    final plan = MealPlanner.generate(p);
    expect(plan, hasLength(7));
    for (final day in plan) {
      expect(
        day.fold<int>(0, (s, m) => s + m.cost),
        lessThanOrEqualTo(p.budget),
      );
      expect(day.every((m) => m.minutes <= p.minutes), isTrue);
    }
  });
  test('infeasible constraints never silently relax allergies', () {
    expect(MealPlanner.generate(profile(budget: 10000)), isEmpty);
    expect(MealPlanner.generate(profile(minutes: 5)), isEmpty);
    expect(MealPlanner.generate(profile(age: 17)), isEmpty);
    expect(MealPlanner.generate(profile(professional: true)), isEmpty);
  });
  test(
    'swap rejects incompatible meal and groceries reflect accepted swap',
    () {
      final store = SteadyStore();
      store.setNutritionProfile(profile(exclusions: {'fish'}));
      final original = store.mealPlan[0][1];
      store.swapMeal(0, 1, meals.firstWhere((m) => m.id == 'fish'));
      expect(store.mealPlan[0][1], same(original));
      final replacement = MealPlanner.alternatives(
        store.nutritionProfile!,
        store.mealPlan[0],
        1,
      ).first;
      final before = MealPlanner.groceries(store.mealPlan);
      store.swapMeal(0, 1, replacement);
      final after = MealPlanner.groceries(store.mealPlan);
      for (final name in {...before.keys, ...after.keys}) {
        expect(
          after[name] ?? 0,
          closeTo(
            (before[name] ?? 0) -
                (original.ingredients[name] ?? 0) +
                (replacement.ingredients[name] ?? 0),
            0.001,
          ),
        );
      }
      store.clearNutrition();
      expect(store.nutritionProfile, isNull);
      expect(store.mealPlan, isEmpty);
      store.dispose();
    },
  );
  test('daily budget allows unequal meal costs without false empty states', () {
    final p = profile(budget: 78000);
    final plan = MealPlanner.generate(p);
    expect(plan, hasLength(7));
    for (final day in plan) {
      expect(day.fold<int>(0, (s, m) => s + m.cost), lessThanOrEqualTo(78000));
    }
  });
  test('swapping never exceeds the remaining daily budget', () {
    final store = SteadyStore()..setNutritionProfile(profile(budget: 80000));
    addTearDown(store.dispose);
    final original = store.mealPlan[0][1];
    expect(
      store.swapMeal(0, 1, meals.firstWhere((m) => m.id == 'fish')),
      isFalse,
    );
    expect(store.mealPlan[0][1], same(original));
    for (var day = 0; day < 7; day++) {
      for (var slot = 0; slot < 3; slot++) {
        for (final replacement in MealPlanner.alternatives(
          store.nutritionProfile!,
          store.mealPlan[day],
          slot,
        )) {
          store.swapMeal(day, slot, replacement);
          expect(
            store.mealPlan[day].fold<int>(0, (s, m) => s + m.cost),
            lessThanOrEqualTo(80000),
          );
        }
      }
    }
  });
}
