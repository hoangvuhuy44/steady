import '../nutrition/meal_planner.dart' show Meal, meals;
import 'food_profile.dart';

enum IngredientStatus { unverified, complete }

/// Components form a tree so sauces, stocks and seasonings have their own
/// ingredients and evidence. An unknown child invalidates the entire audit.
class FoodComponent {
  const FoodComponent(
    this.name, {
    this.allergens = const {},
    this.verified = false,
    this.children = const [],
  });
  final String name;
  final Set<String> allergens;
  final bool verified;
  final List<FoodComponent> children;
  Iterable<FoodComponent> get flattened sync* {
    yield this;
    for (final child in children) {
      yield* child.flattened;
    }
  }
}

class FoodNutrition {
  const FoodNutrition({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.source,
  });
  final double kcal, protein, carbs, fat;

  /// A nonempty, reviewed source is required; legacy sample macros aren't used.
  final String source;
  bool get usable =>
      source.trim().isNotEmpty &&
      [kcal, protein, carbs, fat].every((v) => v.isFinite && v >= 0);
}

class FoodRecipe {
  const FoodRecipe({
    required this.meal,
    required this.components,
    this.status = IngredientStatus.unverified,
    this.allergens = const {},
    this.diets = const {},
    this.sample = true,
    this.servings = 1,
    this.nutrition,
    this.estimatedCost,
    this.preparationMinutes,
    this.imageUrl,
  });
  final Meal meal;
  final List<FoodComponent> components;
  final IngredientStatus status;
  final Set<String> allergens;
  final Set<FoodDiet> diets;
  final bool sample;
  final double servings;
  final FoodNutrition? nutrition;
  final int? estimatedCost, preparationMinutes;
  final String? imageUrl;
  String get id => meal.id;
  Iterable<FoodComponent> get allComponents =>
      components.expand((c) => c.flattened);
  bool get auditable =>
      status == IngredientStatus.complete &&
      components.isNotEmpty &&
      allComponents.every((c) => c.verified);
  Set<String> get ingredientNames => FoodNames.terms({
    ...meal.ingredients.keys,
    ...allComponents.map((c) => c.name),
  });
  Set<String> get allAllergens => FoodNames.terms({
    ...meal.contains.difference({'meat'}),
    ...allergens,
    ...allComponents.expand((c) => c.allergens),
  });
}

/// Existing recipes are explicitly samples with unverified ingredients. Do not
/// manufacture sauce/stock composition, diet certification or nutrient sources.
/// A curated catalogue can replace these records without changing the engine.
final foodCatalog = meals
    .where((m) => m.slot != 'Bữa phụ')
    .map(
      (meal) => FoodRecipe(
        meal: meal,
        components: meal.ingredients.keys
            .map((name) => FoodComponent(name))
            .toList(),
        allergens: meal.contains.difference({'meat'}),
        estimatedCost: meal.cost,
        preparationMinutes: meal.minutes,
        servings: meal.servings,
      ),
    )
    .toList(growable: false);
