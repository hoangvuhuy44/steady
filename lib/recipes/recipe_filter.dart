import '../nutrition/meal_planner.dart' show Meal, meals;

/// Catalogue filters never consult a health profile or relax selected criteria.
class RecipeFilter {
  const RecipeFilter({
    this.slot,
    this.maxMinutes,
    this.avoidedLabels = const {},
    this.avoidedIngredients = const {},
  });

  final String? slot;
  final int? maxMinutes;
  final Set<String> avoidedLabels;
  final Set<String> avoidedIngredients;

  static const slots = ['Sáng', 'Trưa', 'Tối', 'Bữa phụ'];
  static const timeLimits = [10, 15, 20, 30];
  static const allergyLabels = [
    'soy',
    'fish',
    'gluten',
    'milk',
    'egg',
    'peanut',
    'nuts',
    'shellfish',
    'sesame',
  ];
  static final ingredients = meals
      .expand((meal) => meal.ingredients.keys)
      .toSet()
      .toList(growable: false);

  bool matches(Meal meal) =>
      (slot == null || meal.slot == slot) &&
      (maxMinutes == null || meal.minutes <= maxMinutes!) &&
      !meal.contains.any(avoidedLabels.contains) &&
      !meal.ingredients.keys.any(avoidedIngredients.contains);

  List<Meal> apply(Iterable<Meal> catalogue) =>
      catalogue.where(matches).toList(growable: false);
}
