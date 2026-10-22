import 'food_catalog.dart';
import 'food_profile.dart';

const dailySlots = ['Sáng', 'Trưa', 'Tối'];

class DailyMenuEngine {
  /// Mandatory rules never depend on ranking or the number of candidates.
  static bool eligible(
    FoodRecipe recipe,
    FoodProfile profile,
    Set<String> rejected,
  ) {
    if (rejected.contains(recipe.id) || profile.medicalNote.trim().isNotEmpty) {
      return false;
    }
    final excluded = {
      ...profile.allergies,
      ...profile.intolerances,
      ...profile.medicalAvoid,
    };
    if ((excluded.isNotEmpty || profile.diet != FoodDiet.unrestricted) &&
        !recipe.auditable) {
      return false;
    }
    if (profile.diet != FoodDiet.unrestricted &&
        !recipe.diets.contains(profile.diet)) {
      return false;
    }
    final contents = {...recipe.ingredientNames, ...recipe.allAllergens};
    // Unknown custom allergens cannot be ruled out by an unrecognized token.
    // Require a known identity; never interpret a spelling guess as clearance.
    for (final term in excluded) {
      if (!FoodNames.aliases.containsValue(term) &&
          !FoodNames.allergenGroups.containsKey(term)) {
        return false;
      }
      if (contents.any((content) => FoodNames.overlaps(term, content))) {
        return false;
      }
    }
    return true;
  }

  static double rank(
    FoodRecipe recipe,
    FoodProfile profile,
    Set<String> recent,
  ) {
    var score = recent.contains(recipe.id) ? -40.0 : 0.0;
    final ingredients = recipe.ingredientNames;
    bool has(String term) =>
        ingredients.any((i) => FoodNames.matchesPreference(term, i));
    score += profile.favorites.where(has).length * 12;
    score -= profile.dislikes.where(has).length * 25;
    final minutes = recipe.preparationMinutes;
    if (profile.maxMinutes != null) {
      score += minutes == null
          ? -8
          : minutes <= profile.maxMinutes!
          ? 6
          : -12;
    }
    final n = recipe.nutrition;
    if (n != null && n.usable) {
      if (profile.goal == FoodGoal.buildMuscle) score += n.protein / 10;
      if (profile.goal == FoodGoal.loseWeight && n.kcal > 0) {
        score += n.protein / n.kcal * 30;
      }
    }
    return score;
  }

  /// Enumerate daily combinations (including empty pools), then rank the whole
  /// day. This accounts for daily cost instead of treating a daily budget as a
  /// per-meal limit. No body measurements or medical targets are inferred.
  static List<String?> generate(
    List<FoodRecipe> catalog,
    FoodProfile profile,
    Set<String> rejected,
    Set<String> recent, {
    List<String?>? fixed,
    int? swapSlot,
  }) {
    final byId = {for (final recipe in catalog) recipe.id: recipe};
    final pools = <List<FoodRecipe?>>[];
    for (var slot = 0; slot < 3; slot++) {
      if (fixed != null && slot != swapSlot) {
        final old = byId[fixed[slot]];
        pools.add([
          old != null &&
                  old.meal.slot == dailySlots[slot] &&
                  eligible(old, profile, rejected)
              ? old
              : null,
        ]);
        continue;
      }
      final options = catalog
          .where(
            (r) =>
                r.meal.slot == dailySlots[slot] &&
                eligible(r, profile, rejected) &&
                (fixed == null || r.id != fixed[slot]),
          )
          .toList();
      pools.add(options.isEmpty ? [null] : options);
    }
    List<FoodRecipe?>? best;
    var bestScore = double.negativeInfinity;
    for (final a in pools[0]) {
      for (final b in pools[1]) {
        for (final c in pools[2]) {
          final day = [a, b, c];
          final available = day.whereType<FoodRecipe>().toList();
          var score = available.fold<double>(
            0,
            (sum, r) => sum + rank(r, profile, recent),
          );
          score -=
              (available.length - available.map((r) => r.id).toSet().length) *
              100;
          final nutrients = dailyNutrition(day);
          if (nutrients != null) {
            // Compare actual daily composition without inventing a personal
            // calorie target, required intake, or an achieved health outcome.
            if (profile.goal == FoodGoal.buildMuscle) {
              score += nutrients.protein / 15;
            } else if (profile.goal == FoodGoal.loseWeight &&
                nutrients.kcal > 0) {
              score += nutrients.protein / nutrients.kcal * 90;
            }
          }
          if (profile.dailyBudget != null) {
            if (available.every((r) => r.estimatedCost != null)) {
              final total = available.fold<int>(
                0,
                (sum, r) => sum + r.estimatedCost!,
              );
              score += total <= profile.dailyBudget!
                  ? 15
                  : -15 -
                        (total - profile.dailyBudget!) /
                            profile.dailyBudget! *
                            20;
            } else {
              score -= 10;
            }
          }
          if (score > bestScore) {
            best = day;
            bestScore = score;
          }
        }
      }
    }
    return (best ?? [null, null, null]).map((r) => r?.id).toList();
  }

  static FoodNutrition? dailyNutrition(List<FoodRecipe?> recipes) {
    if (recipes.length != 3 ||
        recipes.any((r) => r?.nutrition?.usable != true)) {
      return null;
    }
    final nutrients = recipes.map((r) => r!.nutrition!).toList();
    return FoodNutrition(
      kcal: nutrients.fold(0, (s, n) => s + n.kcal),
      protein: nutrients.fold(0, (s, n) => s + n.protein),
      carbs: nutrients.fold(0, (s, n) => s + n.carbs),
      fat: nutrients.fold(0, (s, n) => s + n.fat),
      source: nutrients.map((n) => n.source).toSet().join('; '),
    );
  }
}
