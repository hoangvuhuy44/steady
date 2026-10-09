import 'package:flutter/material.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';
import '../nutrition/meal_planner.dart' show Meal, meals;
import '../recipes/recipe_filter.dart';
import '../widgets/brand/steady_section_header.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  String? slot;
  int? maxMinutes;
  final avoidedLabels = <String>{};
  final avoidedIngredients = <String>{};

  void clearFilters() => setState(() {
    slot = null;
    maxMinutes = null;
    avoidedLabels.clear();
    avoidedIngredients.clear();
  });

  void toggle(Set<String> values, String value, bool selected) => setState(() {
    selected ? values.add(value) : values.remove(value);
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final results = RecipeFilter(
      slot: slot,
      maxMinutes: maxMinutes,
      avoidedLabels: avoidedLabels,
      avoidedIngredients: avoidedIngredients,
    ).apply(meals);

    return ListView(
      key: const ValueKey('recipe-catalogue'),
      padding: SteadySpacing.screen,
      children: [
        SteadySectionHeader(
          title: l.recipesTitle,
          subtitle: l.recipesIntro,
          icon: SteadyBrandIcon.wellness,
        ),
        const SizedBox(height: SteadySpacing.lg),
        Card(
          child: ExpansionTile(
            key: const ValueKey('recipe-filters'),
            title: Text(l.recipesFilters),
            leading: const Icon(Icons.tune),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.recipesMealType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SteadySpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    key: const ValueKey('recipe-slot-all'),
                    label: Text(l.recipesAll),
                    selected: slot == null,
                    onSelected: (_) => setState(() => slot = null),
                  ),
                  for (final value in RecipeFilter.slots)
                    ChoiceChip(
                      key: ValueKey('recipe-slot-$value'),
                      label: Text(l.mealSlot(value)),
                      selected: slot == value,
                      onSelected: (selected) =>
                          setState(() => slot = selected ? value : null),
                    ),
                ],
              ),
              const SizedBox(height: SteadySpacing.lg),
              Text(
                l.recipesCookingTime,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SteadySpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    key: const ValueKey('recipe-time-all'),
                    label: Text(l.recipesAnyTime),
                    selected: maxMinutes == null,
                    onSelected: (_) => setState(() => maxMinutes = null),
                  ),
                  for (final value in RecipeFilter.timeLimits)
                    ChoiceChip(
                      key: ValueKey('recipe-time-$value'),
                      label: Text(l.recipesWithinMinutes(value)),
                      selected: maxMinutes == value,
                      onSelected: (selected) =>
                          setState(() => maxMinutes = selected ? value : null),
                    ),
                ],
              ),
              const SizedBox(height: SteadySpacing.lg),
              Text(
                l.recipesAllergyFilter,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SteadySpacing.sm),
              Text(
                l.recipesAllergyLimit,
                key: const ValueKey('recipe-allergy-limit'),
              ),
              const SizedBox(height: SteadySpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in RecipeFilter.allergyLabels)
                    FilterChip(
                      key: ValueKey('recipe-avoid-label-$value'),
                      label: Text(l.allergen(value)),
                      selected: avoidedLabels.contains(value),
                      onSelected: (selected) =>
                          toggle(avoidedLabels, value, selected),
                    ),
                ],
              ),
              const SizedBox(height: SteadySpacing.lg),
              Text(
                l.recipesAvoidIngredients,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: SteadySpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in RecipeFilter.ingredients)
                    FilterChip(
                      key: ValueKey('recipe-avoid-ingredient-$value'),
                      label: Text(l.ingredient(value)),
                      selected: avoidedIngredients.contains(value),
                      onSelected: (selected) =>
                          toggle(avoidedIngredients, value, selected),
                    ),
                ],
              ),
              const SizedBox(height: SteadySpacing.md),
              TextButton(
                key: const ValueKey('recipe-clear-filters'),
                onPressed: clearFilters,
                child: Text(l.recipesClearFilters),
              ),
            ],
          ),
        ),
        const SizedBox(height: SteadySpacing.lg),
        Text(
          l.recipesResultCount(results.length),
          key: const ValueKey('recipe-result-count'),
        ),
        const SizedBox(height: SteadySpacing.md),
        if (results.isEmpty)
          Card(
            key: const ValueKey('recipe-empty'),
            child: Padding(
              padding: SteadySpacing.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.recipesEmptyTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: SteadySpacing.sm),
                  Text(l.recipesEmptyHelp),
                  const SizedBox(height: SteadySpacing.md),
                  OutlinedButton(
                    key: const ValueKey('recipe-empty-clear'),
                    onPressed: clearFilters,
                    child: Text(l.recipesClearFilters),
                  ),
                ],
              ),
            ),
          ),
        for (final meal in results)
          Padding(
            padding: const EdgeInsets.only(bottom: SteadySpacing.md),
            child: Card(
              child: ListTile(
                key: ValueKey('recipe-card-${meal.id}'),
                contentPadding: const EdgeInsets.all(16),
                title: Text(l.mealName(meal)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${l.mealSlot(meal.slot)} · '
                    '${l.recipesEstimatedMinutes(meal.minutes)}',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(meal: meal),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.recipeDetails)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: ListView(
              key: ValueKey('recipe-detail-${meal.id}'),
              padding: SteadySpacing.card,
              children: [
                Text(
                  l.mealName(meal),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: SteadySpacing.md),
                Text(
                  '${l.mealSlot(meal.slot)} · '
                  '${l.recipesEstimatedMinutes(meal.minutes)}',
                ),
                const SizedBox(height: SteadySpacing.lg),
                Text(
                  l.recipesSampleQuantities,
                  key: const ValueKey('recipe-sample-quantities'),
                ),
                const SizedBox(height: SteadySpacing.xl),
                Text(
                  l.ingredients,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SteadySpacing.md),
                for (final ingredient in meal.ingredients.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${l.ingredient(ingredient.key)}: '
                      '${l.grams(ingredient.value)}',
                    ),
                  ),
                const SizedBox(height: SteadySpacing.md),
                Text(
                  l.preparation,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SteadySpacing.md),
                Text(l.mealRecipe(meal)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
