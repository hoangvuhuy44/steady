import 'package:flutter_test/flutter_test.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/recipes/recipe_filter.dart';

void main() {
  test('unfiltered catalogue reuses every original sample recipe', () {
    expect(const RecipeFilter().apply(meals), meals);
  });

  test('meal, time, multiple labels and ingredients combine with AND', () {
    const filter = RecipeFilter(
      slot: 'Sáng',
      maxMinutes: 20,
      avoidedLabels: {'soy', 'egg'},
      avoidedIngredients: {'Gạo lứt'},
    );
    expect(filter.apply(meals).map((meal) => meal.id), isEmpty);
    const lessRestricted = RecipeFilter(
      slot: 'Sáng',
      maxMinutes: 20,
      avoidedLabels: {'soy', 'egg'},
    );
    expect(lessRestricted.apply(meals).map((meal) => meal.id), [
      'ricebreakfast',
    ]);
  });

  test('time boundary is inclusive and impossible filters stay empty', () {
    expect(const RecipeFilter(maxMinutes: 10).apply(meals).map((m) => m.id), [
      'oats',
      'soySnack',
    ]);
    const filter = RecipeFilter(slot: 'Trưa', maxMinutes: 10);
    expect(filter.apply(meals), isEmpty);
    expect(filter.slot, 'Trưa');
    expect(filter.maxMinutes, 10);
  });

  test('allergy exclusion checks labels only; it is no safety assessment', () {
    final unlabelled = Meal(
      'unlabelled',
      'Unlabelled egg',
      'Sáng',
      5,
      0,
      0,
      0,
      0,
      0,
      {'Trứng': 100},
      {},
      'Sample',
    );
    expect(const RecipeFilter(avoidedLabels: {'egg'}).apply([unlabelled]), [
      unlabelled,
    ]);
    expect(
      const RecipeFilter(avoidedIngredients: {'Trứng'}).apply([unlabelled]),
      isEmpty,
    );
  });
}
