import 'package:flutter/material.dart';

import '../widgets/brand/steady_progress.dart';

import '../theme/steady_radii.dart';

import '../theme/steady_spacing.dart';

import '../l10n/formatters.dart';
import '../l10n/nutrition_localizations.dart';
import '../nutrition/meal_planner.dart';
import '../nutrition/nutrition_strategy.dart';
import '../widgets/nutrition_summary_card.dart';
import '../state/steady_store.dart';
import '../widgets/screening_result_card.dart';
import '../screens/screening_screen.dart';

// Retained for research harnesses; the MVP has no route to this screen.
class ResearchMealsScreen extends StatefulWidget {
  const ResearchMealsScreen({super.key, required this.store});
  final SteadyStore store;
  @override
  State<ResearchMealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<ResearchMealsScreen> {
  String _mealTime(MealTiming timing, String slot) {
    if (timing == MealTiming.timeRestricted) {
      return switch (slot) {
        'Sáng' => '12:00',
        'Trưa' => '16:00',
        _ => '19:30',
      };
    }
    return switch (slot) {
      'Sáng' => '07:30',
      'Trưa' => '12:30',
      'Bữa phụ' => '16:00',
      _ => '19:00',
    };
  }

  final scroll = ScrollController();
  final checkedGroceries = <String>{};
  int day = 0;

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void moveToTop() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) scroll.jumpTo(0);
    });
  }

  Future<void> openSetup() async {
    final initial = widget.store.healthScreening;
    widget.store.requestScreening();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (routeContext) => ScreeningScreen(
          initial: initial,
          onCompleted: (profile) {
            widget.store.completeScreening(profile);
            Navigator.of(routeContext).pop();
          },
          onDeclined: () {
            widget.store.declineScreening();
            Navigator.of(routeContext).pop();
          },
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      day = 0;
      checkedGroceries.clear();
    });
    moveToTop();
  }

  void edit() => openSetup();

  Future<void> delete() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteTitle),
        content: Text(l.deleteHelp),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.store.clearNutrition();
    setState(() {
      day = 0;
      checkedGroceries.clear();
    });
    moveToTop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.deleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!widget.store.mealPlanningAllowed ||
        widget.store.nutritionProfile == null) {
      return ListView(
        padding: SteadySpacing.card,
        children: [
          Text(
            l.screeningPaused,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SteadySpacing.lg),
          ScreeningResultCard(assessment: widget.store.screeningAssessment),
          const SizedBox(height: SteadySpacing.lg),
          OutlinedButton(
            key: const ValueKey('meals-setup'),
            onPressed: openSetup,
            child: Text(
              widget.store.healthScreening == null
                  ? l.mealsSetup
                  : l.screeningEdit,
            ),
          ),
        ],
      );
    }
    final p = widget.store.nutritionProfile!;
    return ListView(
      controller: scroll,
      // Keep the final account action reachable above floating feedback.
      padding: const EdgeInsets.fromLTRB(
        SteadySpacing.xl,
        SteadySpacing.lg,
        SteadySpacing.xl,
        SteadySpacing.display * 2,
      ),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: SteadyRadii.controlBorder,
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: SteadySpacing.md),
            Expanded(
              child: Text(
                l.mealsTitle,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: SteadySpacing.md),
        Text(
          l.mealsIntro,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: SteadySpacing.xl),
        ...plan(p),
      ],
    );
  }

  Widget sectionTitle(String title, {String? subtitle}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: SteadySpacing.sm),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ],
    ),
  );

  List<Widget> plan(NutritionProfile p) {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final week = widget.store.mealPlan;
    return [
      Card(
        color: colors.primaryContainer,
        child: Padding(
          padding: SteadySpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.yourWeek,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: SteadySpacing.sm),
              Text(
                '${l.preference(p.goal)} · ${l.preference(p.diet)}',
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: SteadySpacing.lg),
              Wrap(
                spacing: 16,
                runSpacing: SteadySpacing.md,
                children: [
                  Text(
                    '${l.dailyBudget}: ${l.money(p.budget)}',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                  Text(
                    l.minutesValue(p.minutes),
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
              const SizedBox(height: SteadySpacing.md),
              OutlinedButton.icon(
                onPressed: edit,
                icon: const Icon(Icons.tune),
                label: Text(l.editProfile),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: SteadySpacing.xl),
      if (p.strategy != null) ...[
        NutritionSummaryCard(profile: p),
        const SizedBox(height: SteadySpacing.lg),
      ],
      if (!p.supported)
        emptyState(
          Icons.health_and_safety_outlined,
          l.unsupportedTitle,
          l.unsupportedHelp,
        )
      else if (week.isEmpty)
        emptyState(
          Icons.restaurant_menu,
          l.emptyPlanTitle,
          widget.store.mealPlanReason == null
              ? l.emptyPlanHelp
              : l.nutritionMessage(widget.store.mealPlanReason!),
        )
      else ...[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              week.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  key: ValueKey('meal-day-$i'),
                  label: Text(l.dayNumber(i + 1)),
                  selected: day == i,
                  onSelected: (_) => setState(() => day = i),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: SteadySpacing.xl),
        sectionTitle(l.estimatedDaily),
        totals(week[day], p),
        const SizedBox(height: SteadySpacing.xl),
        ...List.generate(
          week[day].length,
          (slot) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: mealCard(week[day][slot], p, slot),
          ),
        ),
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Icon(
              Icons.shopping_basket_outlined,
              color: colors.primary,
            ),
            title: Text(
              l.groceriesWeek,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(l.itemsCount(MealPlanner.groceries(week).length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: showGroceries,
          ),
        ),
        const SizedBox(height: SteadySpacing.lg),
      ],
      Card(
        child: ExpansionTile(
          title: Text(l.planNotes),
          leading: const Icon(Icons.info_outline),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(l.nutritionNote, style: const TextStyle(height: 1.5)),
            const SizedBox(height: SteadySpacing.md),
            Text(l.personalisationNote, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
      const SizedBox(height: SteadySpacing.xl),
      TextButton.icon(
        onPressed: delete,
        icon: const Icon(Icons.delete_outline),
        style: TextButton.styleFrom(foregroundColor: colors.error),
        label: Text(l.deletePlan),
      ),
    ];
  }

  Widget emptyState(IconData icon, String title, String message) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Card(
      child: Padding(
        padding: SteadySpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: SteadySpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SteadySpacing.md),
            Text(
              message,
              style: const TextStyle(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SteadySpacing.xl),
            FilledButton(
              onPressed: edit,
              child: Text(context.l10n.editProfile),
            ),
          ],
        ),
      ),
    ),
  );

  Widget totals(List<Meal> meals, NutritionProfile p) {
    final l = context.l10n;
    final cost = meals.fold<int>(0, (s, m) => s + m.cost);
    final data = [
      (l.energy, '${l.number(meals.fold<int>(0, (s, m) => s + m.kcal))} kcal'),
      (l.protein, l.grams(meals.fold<int>(0, (s, m) => s + m.protein))),
      (l.fibre, l.grams(meals.fold<int>(0, (s, m) => s + m.fibre))),
      if (p.strategy != null) ...[
        (
          l.nutritionCarbs,
          l.grams(meals.fold<double>(0, (s, m) => s + m.carbs).round()),
        ),
        (
          l.nutritionFat,
          l.grams(meals.fold<double>(0, (s, m) => s + m.fat).round()),
        ),
        (
          l.nutritionSodium,
          '${l.number(meals.fold<double>(0, (s, m) => s + m.sodium).round())} mg',
        ),
      ],
      (
        l.saturatedFat,
        l.grams(meals.fold<double>(0, (s, m) => s + m.saturatedFat)),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final count =
                constraints.maxWidth >= 620 &&
                    MediaQuery.textScalerOf(context).scale(1) < 1.5
                ? 4
                : 2;
            return Wrap(
              spacing: SteadySpacing.md,
              runSpacing: SteadySpacing.md,
              children: data
                  .map(
                    (item) => SizedBox(
                      width: (constraints.maxWidth - (count - 1) * 10) / count,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$2,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: SteadySpacing.sm),
                              Text(
                                item.$1,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
        const SizedBox(height: SteadySpacing.lg),
        Text('${l.estimatedCost}: ${l.money(cost)} / ${l.money(p.budget)}'),
        const SizedBox(height: SteadySpacing.sm),
        SteadyProgressBar(
          value: (cost / p.budget).clamp(0, 1),
          semanticLabel:
              '${l.estimatedCost}: ${l.money(cost)} / ${l.money(p.budget)}',
        ),
      ],
    );
  }

  Widget mealCard(Meal meal, NutritionProfile p, int slot) {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final alternatives = MealPlanner.alternatives(
      p,
      widget.store.mealPlan[day],
      slot,
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      switch (meal.slot) {
                        'Sáng' => Icons.wb_sunny_outlined,
                        'Trưa' => Icons.light_mode_outlined,
                        'Tối' => Icons.nightlight_outlined,
                        _ => Icons.apple_outlined,
                      },
                      color: colors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: SteadySpacing.sm),
                    Expanded(
                      child: Text(
                        '${l.mealSlot(meal.slot)}${p.strategy == null ? '' : ' · ${_mealTime(p.strategy!.timing, meal.slot)}'}',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SteadySpacing.md),
                Text(
                  l.mealName(meal),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: SteadySpacing.md),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(l.minutesValue(meal.minutes)),
                    Text(l.money(meal.cost)),
                    Text('~${l.number(meal.kcal)} kcal'),
                    if (p.strategy != null)
                      Text(
                        '${l.nutritionPortion}: ${l.number(meal.servings)}×',
                      ),
                  ],
                ),
                const SizedBox(height: SteadySpacing.md),
                OutlinedButton.icon(
                  key: ValueKey('swap-$slot'),
                  onPressed: alternatives.isEmpty
                      ? null
                      : () => swap(slot, alternatives),
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(
                    alternatives.isEmpty ? l.noAlternatives : l.swapMeal,
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            key: ValueKey('recipe-$day-$slot-${meal.id}'),
            title: Text(l.recipeDetails),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: sectionTitle(l.ingredients),
              ),
              ...meal.ingredients.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(l.ingredient(e.key))),
                      const SizedBox(width: SteadySpacing.md),
                      Text(l.grams(e.value)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SteadySpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: sectionTitle(l.preparation),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.mealRecipe(meal),
                  style: const TextStyle(height: 1.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> swap(int slot, List<Meal> alternatives) async {
    final selectedDay = day;
    final replacement = await showModalBottomSheet<Meal>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final l = context.l10n;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.swapTitle,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: l.close,
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Text(l.swapHelp),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    itemCount: alternatives.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) {
                      final m = alternatives[i];
                      return ListTile(
                        title: Text(
                          l.mealName(m),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${l.minutesValue(m.minutes)} · ${l.money(m.cost)}\n~${l.number(m.kcal)} kcal · ${l.protein}: ${l.grams(m.protein)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () => Navigator.pop(context, m),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (replacement != null &&
        mounted &&
        widget.store.swapMeal(selectedDay, slot, replacement)) {
      setState(() => checkedGroceries.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.mealSwapped(context.l10n.mealName(replacement)),
          ),
        ),
      );
    }
  }

  Future<void> showGroceries() async {
    final items = MealPlanner.groceries(widget.store.mealPlan).entries.toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          final l = context.l10n;
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.groceriesWeek,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            IconButton(
                              tooltip: l.close,
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Text(
                          l.groceriesHelp,
                          style: const TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: SteadySpacing.md),
                        Text(
                          '${checkedGroceries.length}/${items.length} · ${l.itemsCount(items.length)}',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final checked = checkedGroceries.contains(item.key);
                        return CheckboxListTile(
                          value: checked,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            l.ingredient(item.key),
                            style: TextStyle(
                              decoration: checked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Text(l.grams(item.value)),
                          onChanged: (v) => update(() {
                            if (v == true) {
                              checkedGroceries.add(item.key);
                            } else {
                              checkedGroceries.remove(item.key);
                            }
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
