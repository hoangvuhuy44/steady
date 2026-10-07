import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../l10n/nutrition_localizations.dart';
import '../nutrition/meal_planner.dart';
import '../nutrition/nutrition_strategy.dart';
import '../widgets/nutrition_summary_card.dart';
import '../state/steady_store.dart';
import '../widgets/screening_result_card.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key, required this.store});
  final SteadyStore store;
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
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

  final form = GlobalKey<FormState>();
  final scroll = ScrollController();
  final readingsController = ExpansibleController();
  final fields = <String, TextEditingController>{};
  final exclusions = <String>{};
  final checkedGroceries = <String>{};
  String goal = 'Ăn uống cân bằng';
  String activity = 'Ít vận động';
  String cholesterol = 'Chưa biết';
  String diet = 'Ăn đa dạng';
  bool professional = false, consent = false, editing = false;
  int day = 0, step = 0;
  String? stepError;

  static const allergens = [
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
  static const dislikes = [
    'Ức gà bỏ da',
    'Đậu phụ',
    'Cá rô phi phi lê',
    'Khoai lang',
    'Yến mạch',
  ];

  @override
  void initState() {
    super.initState();
    for (final key in [
      'age',
      'height',
      'weight',
      'budget',
      'minutes',
      'sys',
      'dia',
      'ldl',
      'hdl',
      'tg',
    ]) {
      fields[key] = TextEditingController();
    }
    restoreProfile();
  }

  void restoreProfile() {
    final p = widget.store.nutritionProfile;
    final screening = widget.store.healthScreening;
    for (final c in fields.values) {
      c.clear();
    }
    fields['budget']!.text = '${p?.budget ?? 120000}';
    fields['minutes']!.text = '${p?.minutes ?? 30}';
    goal = screening?.goal ?? p?.goal ?? 'Ăn uống cân bằng';
    activity = p?.activity ?? 'Ít vận động';
    cholesterol = p?.cholesterol ?? 'Chưa biết';
    diet = p?.diet ?? 'Ăn đa dạng';
    exclusions
      ..clear()
      ..addAll(p?.exclusions ?? {});
    exclusions.addAll(screening?.allergies ?? {});
    professional = p?.needsProfessionalPlan ?? false;
    consent = p != null;
    if (p != null) {
      fields['age']!.text = '${p.age}';
      fields['height']!.text = '${p.height}';
      fields['weight']!.text = '${p.weight}';
      final bp = p.bloodPressure.split('/');
      if (bp.length == 2) {
        fields['sys']!.text = bp[0];
        fields['dia']!.text = bp[1];
      }
      final lipid = p.lipidResults.split('/');
      if (lipid.length == 3) {
        fields['ldl']!.text = lipid[0];
        fields['hdl']!.text = lipid[1];
        fields['tg']!.text = lipid[2];
      }
    }
    if (screening != null) {
      fields['age']!.text = '${screening.age}';
      fields['height']!.text = '${screening.height}';
      fields['weight']!.text = '${screening.weight}';
    }
  }

  @override
  void dispose() {
    for (final c in fields.values) {
      c.dispose();
    }
    scroll.dispose();
    readingsController.dispose();
    super.dispose();
  }

  String input(String key) => fields[key]!.text.trim().replaceAll(',', '.');
  double value(String key) => double.parse(input(key));

  Widget number(
    String key,
    String label,
    double min,
    double max, {
    bool optional = false,
  }) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('meal-$key'),
        controller: fields[key],
        readOnly:
            widget.store.healthScreening != null &&
            ['age', 'height', 'weight'].contains(key),
        keyboardType: TextInputType.numberWithOptions(
          decimal: !['age', 'budget', 'minutes'].contains(key),
        ),
        textInputAction: TextInputAction.next,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          helperText: optional ? l.optional : null,
          errorMaxLines: 3,
        ),
        errorBuilder: (context, error) => Text(
          error == 'integer'
              ? context.l10n.integerError
              : context.l10n.rangeError(
                  context.l10n.number(min),
                  context.l10n.number(max),
                ),
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
        validator: (text) {
          final raw = (text ?? '').trim().replaceAll(',', '.');
          if (optional && raw.isEmpty) return null;
          final n = double.tryParse(raw);
          if (n == null || !n.isFinite || n < min || n > max) return 'range';
          if (['age', 'budget', 'minutes'].contains(key) &&
              n != n.roundToDouble()) {
            return 'integer';
          }
          return null;
        },
      ),
    );
  }

  Widget choice(
    String label,
    String selected,
    List<String> options,
    ValueChanged<String> update,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      key: ValueKey('choice-$label-$selected'),
      initialValue: selected,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: options
          .map(
            (o) => DropdownMenuItem(
              value: o,
              child: Text(context.l10n.preference(o)),
            ),
          )
          .toList(),
      onChanged:
          widget.store.healthScreening != null && label == context.l10n.goal
          ? null
          : (v) {
              if (v != null) setState(() => update(v));
            },
    ),
  );

  void moveToTop() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients) scroll.jumpTo(0);
    });
  }

  bool validateStep() {
    setState(() => stepError = null);
    if (!form.currentState!.validate()) {
      if (step == 1) readingsController.expand();
      moveToTop();
      return false;
    }
    if (step == 1) {
      final sys = input('sys'), dia = input('dia');
      final l = context.l10n;
      if (sys.isEmpty != dia.isEmpty) stepError = 'pair';
      if (sys.isNotEmpty && dia.isNotEmpty && value('sys') <= value('dia')) {
        stepError = 'order';
      }
      if (stepError != null) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stepError == 'pair'
                  ? l.bloodPressurePairError
                  : l.bloodPressureOrderError,
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  void next() {
    if (!validateStep()) return;
    setState(() {
      step++;
      stepError = null;
    });
    moveToTop();
  }

  void save() {
    if (!validateStep()) return;
    final wasEditing = editing;
    final p = NutritionProfile(
      age: value('age').toInt(),
      height: value('height'),
      weight: value('weight'),
      goal: goal,
      activity: activity,
      cholesterol: cholesterol,
      diet: diet,
      budget: value('budget').toInt(),
      minutes: value('minutes').toInt(),
      exclusions: Set.of(exclusions),
      bloodPressure: input('sys').isEmpty
          ? ''
          : '${input('sys')}/${input('dia')}',
      lipidResults: '${input('ldl')}/${input('hdl')}/${input('tg')}',
      needsProfessionalPlan: professional,
    );
    widget.store.setNutritionProfile(p);
    setState(() {
      editing = false;
      day = 0;
      checkedGroceries.clear();
    });
    moveToTop();
    if (widget.store.mealPlan.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasEditing ? context.l10n.planUpdated : context.l10n.planReady,
          ),
        ),
      );
    }
  }

  void edit() {
    if (widget.store.screeningEnforced &&
        widget.store.nutritionProfile?.strategy != null) {
      widget.store.requestScreening();
      return;
    }
    setState(() {
      restoreProfile();
      editing = true;
      step = 0;
      stepError = null;
    });
    moveToTop();
  }

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
      restoreProfile();
      editing = false;
      day = 0;
      step = 0;
      stepError = null;
      checkedGroceries.clear();
    });
    moveToTop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.deleted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (!widget.store.mealPlanningAllowed) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l.screeningPaused,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ScreeningResultCard(assessment: widget.store.screeningAssessment),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: widget.store.requestScreening,
            child: Text(l.screeningEdit),
          ),
        ],
      );
    }
    final p = widget.store.nutritionProfile;
    return ListView(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.restaurant_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.mealsTitle,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l.mealsIntro,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        if (p == null || editing) setup() else ...plan(p),
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
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
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

  Widget setup() {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final titles = [l.bodyGoal, l.health, l.preferences];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.setupTitle,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(l.setupIntro),
        const SizedBox(height: 20),
        Text(
          l.stepProgress(step + 1),
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(
            3,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i <= step
                        ? colors.primary
                        : colors.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  sectionTitle(
                    titles[step],
                    subtitle: step == 0 ? l.bodyGoalHelp : null,
                  ),
                  ...switch (step) {
                    0 => bodyFields(),
                    1 => healthFields(),
                    _ => preferenceFields(),
                  },
                  if (stepError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        stepError == 'pair'
                            ? l.bloodPressurePairError
                            : l.bloodPressureOrderError,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    key: const ValueKey('meal-next'),
                    onPressed: step == 2 ? save : next,
                    icon: Icon(
                      step == 2
                          ? Icons.auto_awesome_outlined
                          : Icons.arrow_forward,
                    ),
                    label: Text(
                      step == 2
                          ? (editing ? l.updatePlan : l.createPlan)
                          : l.continueLabel,
                    ),
                  ),
                  if (step > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          step--;
                          stepError = null;
                        });
                        moveToTop();
                      },
                      child: Text(l.back),
                    ),
                  if (editing)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          restoreProfile();
                          editing = false;
                          stepError = null;
                        });
                        moveToTop();
                      },
                      child: Text(l.cancel),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.privacyNote,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> bodyFields() {
    final l = context.l10n;
    return [
      number('age', l.age, 1, 120),
      if (widget.store.healthScreening != null)
        TextButton(
          onPressed: widget.store.requestScreening,
          child: Text(l.screeningEdit),
        ),
      LayoutBuilder(
        builder: (context, constraints) {
          final height = number('height', l.height, 50, 250);
          final weight = number('weight', l.weight, 10, 400);
          if (constraints.maxWidth < 300 ||
              MediaQuery.textScalerOf(context).scale(1) >= 1.3) {
            return Column(children: [height, weight]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: height),
              const SizedBox(width: 12),
              Expanded(child: weight),
            ],
          );
        },
      ),
      choice(l.goal, goal, [
        'Ăn uống cân bằng',
        'Hỗ trợ giảm cân',
        'Hỗ trợ tăng cơ',
      ], (v) => goal = v),
      choice(l.dailyActivity, activity, [
        'Ít vận động',
        'Nhẹ: 1–2 buổi/tuần',
        'Vừa: 3–4 buổi/tuần',
        'Nhiều: 5+ buổi/tuần',
      ], (v) => activity = v),
    ];
  }

  List<Widget> healthFields() {
    final l = context.l10n;
    return [
      choice(l.cholesterolStatus, cholesterol, [
        'Chưa biết',
        'Đã xác nhận',
        'Chưa được chẩn đoán',
      ], (v) => cholesterol = v),
      Text(
        l.healthHelp,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 16),
      ExpansionTile(
        key: const ValueKey('health-readings'),
        controller: readingsController,
        tilePadding: EdgeInsets.zero,
        initiallyExpanded: [
          'sys',
          'dia',
          'ldl',
          'hdl',
          'tg',
        ].any((k) => input(k).isNotEmpty),
        title: Text(l.optionalReadings),
        subtitle: Text(l.optional),
        // Keep optional validators mounted even when collapsed.
        maintainState: true,
        children: [
          const SizedBox(height: 12),
          number('sys', l.systolic, 50, 300, optional: true),
          number('dia', l.diastolic, 30, 200, optional: true),
          number('ldl', l.ldl, 0.1, 30, optional: true),
          number('hdl', l.hdl, 0.1, 15, optional: true),
          number('tg', l.triglycerides, 0.1, 50, optional: true),
        ],
      ),
      const SizedBox(height: 12),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: professional,
        title: Text(l.professionalLabel),
        subtitle: Text(l.professionalHelp),
        onChanged: (v) => setState(() => professional = v ?? false),
      ),
    ];
  }

  void exclude(String key, bool selected) => setState(() {
    if (selected) {
      exclusions.add(key);
    } else {
      exclusions.remove(key);
    }
  });

  List<Widget> preferenceFields() {
    final l = context.l10n;
    return [
      choice(l.diet, diet, ['Ăn đa dạng', 'Chay'], (v) => diet = v),
      number('budget', l.budget, 10000, 2000000),
      number('minutes', l.cookingTime, 5, 180),
      sectionTitle(l.allergens, subtitle: l.allergensHelp),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: allergens
            .map(
              (key) => FilterChip(
                label: Text(l.allergen(key)),
                selected: exclusions.contains(key),
                onSelected:
                    widget.store.healthScreening?.allergies.contains(key) ==
                        true
                    ? null
                    : (v) => exclude(key, v),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 20),
      sectionTitle(l.dislikes),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: dislikes
            .map(
              (key) => FilterChip(
                label: Text(l.ingredient(key)),
                selected: exclusions.contains(key),
                onSelected: (v) => exclude(key, v),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 20),
      FormField<bool>(
        initialValue: consent,
        validator: (_) => consent ? null : 'consent',
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              key: const ValueKey('meal-consent'),
              value: consent,
              title: Text(l.consent),
              onChanged: (v) {
                setState(() => consent = v ?? false);
                state.didChange(consent);
              },
            ),
            if (state.hasError)
              Text(
                l.consentError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> plan(NutritionProfile p) {
    final l = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final week = widget.store.mealPlan;
    return [
      Card(
        color: colors.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.yourWeek,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l.preference(p.goal)} · ${l.preference(p.diet)}',
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 10,
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
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: edit,
                icon: const Icon(Icons.tune),
                label: Text(l.editProfile),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      if (p.strategy != null) ...[
        NutritionSummaryCard(profile: p),
        const SizedBox(height: 16),
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
        const SizedBox(height: 20),
        sectionTitle(l.estimatedDaily),
        totals(week[day], p),
        const SizedBox(height: 20),
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
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(l.itemsCount(MealPlanner.groceries(week).length)),
            trailing: const Icon(Icons.chevron_right),
            onTap: showGroceries,
          ),
        ),
        const SizedBox(height: 16),
      ],
      Card(
        child: ExpansionTile(
          title: Text(l.planNotes),
          leading: const Icon(Icons.info_outline),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            Text(l.nutritionNote, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 12),
            Text(l.personalisationNote, style: const TextStyle(height: 1.5)),
          ],
        ),
      ),
      const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
              spacing: 10,
              runSpacing: 10,
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
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
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
        const SizedBox(height: 14),
        Text('${l.estimatedCost}: ${l.money(cost)} / ${l.money(p.budget)}'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (cost / p.budget).clamp(0, 1),
            minHeight: 6,
          ),
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
                    const SizedBox(width: 8),
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
                const SizedBox(height: 10),
                Text(
                  l.mealName(meal),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
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
                      const SizedBox(width: 12),
                      Text(l.grams(e.value)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                        const SizedBox(height: 12),
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
