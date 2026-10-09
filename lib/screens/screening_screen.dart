import 'package:flutter/material.dart';

import '../l10n/formatters.dart';
import '../l10n/nutrition_localizations.dart';
import '../l10n/screening_localizations.dart';
import '../nutrition/meal_planner.dart';
import '../nutrition/nutrition_strategy.dart';
import '../screening/health_screening.dart';
import '../widgets/nutrition_summary_card.dart';
import '../widgets/screening_result_card.dart';

class ScreeningScreen extends StatefulWidget {
  const ScreeningScreen({
    super.key,
    required this.onCompleted,
    required this.onDeclined,
    this.initial,
  });
  final ValueChanged<HealthScreening> onCompleted;
  final VoidCallback onDeclined;
  final HealthScreening? initial;
  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final form = GlobalKey<FormState>();
  final scroll = ScrollController(keepScrollOffset: false);
  final fields = <String, TextEditingController>{};
  final conditions = <HealthCondition>{};
  final flags = <HealthFlag>{};
  final allergies = <String>{};
  final dislikes = <String>{};
  NutritionStrategy strategy = const NutritionStrategy();
  BiologicalSex sex = BiologicalSex.unspecified;
  String activity = 'Ít vận động';
  bool conditionsKnown = false, allergiesKnown = false, treatmentKnown = false;
  bool consent = false, consentError = false;
  int step = 0;
  static const allergenKeys = [
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

  @override
  void initState() {
    super.initState();
    for (final key in [
      'age',
      'height',
      'weight',
      'bodyFat',
      'medications',
      'orders',
      'otherAllergies',
      'kidneyStage',
      'labs',
      'budget',
      'minutes',
      'sessions',
    ]) {
      fields[key] = TextEditingController();
    }
    final p = widget.initial;
    fields['budget']!.text = '${p?.budget ?? 150000}';
    fields['minutes']!.text = '${p?.cookingMinutes ?? 30}';
    fields['sessions']!.text =
        '${p?.nutritionStrategy?.resistanceSessions ?? 0}';
    if (p != null) {
      fields['age']!.text = '${p.age}';
      fields['height']!.text = '${p.height}';
      fields['weight']!.text = '${p.weight}';
      fields['bodyFat']!.text = p.bodyFat == null ? '' : '${p.bodyFat}';
      fields['medications']!.text = p.medications;
      fields['orders']!.text = p.clinicianOrders;
      fields['otherAllergies']!.text = p.otherAllergies;
      fields['kidneyStage']!.text = p.kidneyStage;
      fields['labs']!.text = p.labNotes;
      conditions.addAll(p.conditions);
      flags.addAll(p.flags);
      allergies.addAll(p.allergies);
      dislikes.addAll(p.dislikes);
      strategy = p.nutritionStrategy ?? const NutritionStrategy();
      sex = p.sex;
      activity = p.activity;
      conditionsKnown = p.conditionsKnown;
      allergiesKnown = p.allergiesKnown;
      treatmentKnown = p.treatmentKnown;
    }
  }

  @override
  void dispose() {
    scroll.dispose();
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  String input(String key) => fields[key]!.text.trim();
  double value(String key) => double.parse(input(key).replaceAll(',', '.'));
  HealthScreening get profile => HealthScreening(
    age: value('age').toInt(),
    height: value('height'),
    weight: value('weight'),
    bodyFat: input('bodyFat').isEmpty ? null : value('bodyFat'),
    sex: sex,
    goal: strategy.legacyGoal,
    nutritionStrategy: strategy.copyWith(
      resistanceSessions: value('sessions').toInt(),
    ),
    activity: activity,
    budget: value('budget').toInt(),
    cookingMinutes: value('minutes').toInt(),
    conditions: conditions,
    flags: flags,
    allergies: allergies,
    dislikes: dislikes,
    conditionsKnown: conditionsKnown,
    allergiesKnown: allergiesKnown,
    treatmentKnown: treatmentKnown,
    medications: input('medications'),
    clinicianOrders: input('orders'),
    otherAllergies: input('otherAllergies'),
    kidneyStage: input('kidneyStage'),
    labNotes: input('labs'),
    completedAt: DateTime.now(),
  );
  NutritionProfile get nutritionProfile {
    final p = profile;
    return NutritionProfile(
      age: p.age,
      height: p.height,
      weight: p.weight,
      bodyFat: p.bodyFat,
      sex: p.sex,
      goal: p.goal,
      activity: p.activity,
      cholesterol: 'Chưa biết',
      diet: strategy.source == FoodSource.omnivore ? 'Ăn đa dạng' : 'Chay',
      budget: p.budget,
      minutes: p.cookingMinutes,
      exclusions: {...allergies, ...dislikes},
      strategy: p.nutritionStrategy,
      health: p,
    );
  }

  void move(int target) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (scroll.hasClients) scroll.jumpTo(0);
    setState(() {
      step = target;
      consentError = false;
    });
  }

  void next() {
    if (!form.currentState!.validate()) return;
    if (step < 4) {
      move(step + 1);
      return;
    }
    if (!consent) {
      setState(() => consentError = true);
      return;
    }
    widget.onCompleted(profile);
  }

  Widget number(
    String key,
    String label,
    double min,
    double max, {
    bool optional = false,
  }) {
    final l = context.l10n;
    final integer = ['age', 'budget', 'minutes', 'sessions'].contains(key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: ValueKey('screening-$key'),
        controller: fields[key],
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          errorMaxLines: 3,
          helperText: optional ? l.nutritionBodyFatHelp : null,
          helperMaxLines: 4,
        ),
        validator: (text) {
          final raw = (text ?? '').trim().replaceAll(',', '.');
          if (optional && raw.isEmpty) return null;
          final n = double.tryParse(raw);
          if (n == null || !n.isFinite || n < min || n > max) {
            return l.rangeError(l.number(min), l.number(max));
          }
          if (integer && n != n.roundToDouble()) return l.integerError;
          return null;
        },
      ),
    );
  }

  Widget choice<T extends Enum>(
    String key,
    String label,
    T selected,
    List<T> options,
    ValueChanged<T> changed,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<T>(
      key: ValueKey('screening-$key-${selected.name}'),
      initialValue: selected,
      isExpanded: true,
      itemHeight: null,
      decoration: InputDecoration(labelText: label),
      items: options
          .map(
            (value) => DropdownMenuItem(
              value: value,
              child: Text(context.l10n.nutritionOption(value), maxLines: 3),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => changed(value));
      },
    ),
  );
  Widget note(String key, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      key: ValueKey('screening-$key'),
      controller: fields[key],
      maxLines: 3,
      maxLength: 1000,
      decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
    ),
  );
  Widget check(
    String key,
    String title,
    bool selected,
    ValueChanged<bool> changed,
  ) => CheckboxListTile(
    key: ValueKey(key),
    contentPadding: EdgeInsets.zero,
    controlAffinity: ListTileControlAffinity.leading,
    title: Text(title),
    value: selected,
    onChanged: (value) => setState(() => changed(value!)),
  );
  List<Widget> content() {
    final l = context.l10n;
    return switch (step) {
      0 => [
        Text(l.screeningPrivacy),
        const SizedBox(height: 24),
        number('age', l.age, 1, 120),
        number('height', l.height, 50, 250),
        number('weight', l.weight, 10, 400),
        number('bodyFat', l.nutritionBodyFat, 3, 65, optional: true),
        choice(
          'sex',
          l.nutritionSex,
          sex,
          BiologicalSex.values,
          (value) => sex = value,
        ),
        Text(l.nutritionSexHelp),
      ],
      1 => [
        Text(l.screeningConditionsHelp),
        const SizedBox(height: 12),
        check(
          'screening-conditions-known',
          l.screeningConditionsKnown,
          conditionsKnown,
          (value) => conditionsKnown = value,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final condition in HealthCondition.values)
              FilterChip(
                key: ValueKey('condition-${condition.name}'),
                label: Text(l.conditionName(condition)),
                selected: conditions.contains(condition),
                onSelected: (selected) => setState(() {
                  conditionsKnown = true;
                  selected
                      ? conditions.add(condition)
                      : conditions.remove(condition);
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l.screeningTreatmentHelp),
        check(
          'screening-treatment-known',
          l.screeningTreatmentKnown,
          treatmentKnown,
          (value) => treatmentKnown = value,
        ),
        for (final flag in HealthFlag.values)
          check(
            'screening-flag-${flag.name}',
            l.flagName(flag),
            flags.contains(flag),
            (selected) {
              treatmentKnown = true;
              selected ? flags.add(flag) : flags.remove(flag);
            },
          ),
        const SizedBox(height: 16),
        note('medications', l.screeningMedications),
        note('orders', l.screeningOrders),
        if (conditions.contains(HealthCondition.kidneyDisease))
          note('kidneyStage', l.screeningKidneyStage),
        note('labs', l.screeningLabNotes),
        Text(l.screeningLabHelp),
      ],
      2 => [
        Text(l.nutritionPreferenceHelp),
        const SizedBox(height: 16),
        Text(l.allergens, style: Theme.of(context).textTheme.titleMedium),
        check(
          'screening-allergies-known',
          l.screeningAllergiesKnown,
          allergiesKnown,
          (value) => allergiesKnown = value,
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final allergen in allergenKeys)
              FilterChip(
                key: ValueKey('screening-allergy-$allergen'),
                label: Text(l.allergen(allergen)),
                selected: allergies.contains(allergen),
                onSelected: (selected) => setState(() {
                  allergiesKnown = true;
                  selected
                      ? allergies.add(allergen)
                      : allergies.remove(allergen);
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        note('otherAllergies', l.screeningOtherAllergies),
        Text(l.dislikes, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final ingredient
                in (meals
                    .expand((meal) => meal.ingredients.keys)
                    .toSet()
                    .toList()
                  ..sort()))
              FilterChip(
                key: ValueKey('screening-dislike-$ingredient'),
                label: Text(l.ingredient(ingredient)),
                selected: dislikes.contains(ingredient),
                onSelected: (selected) => setState(() {
                  selected
                      ? dislikes.add(ingredient)
                      : dislikes.remove(ingredient);
                }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        choice(
          'source',
          l.nutritionFoodSource,
          strategy.source,
          FoodSource.values,
          (value) => strategy = strategy.copyWith(source: value),
        ),
        choice(
          'pattern',
          l.nutritionFoodPattern,
          strategy.pattern,
          FoodPattern.values,
          (value) => strategy = strategy.copyWith(pattern: value),
        ),
        choice(
          'macros',
          l.nutritionMacroStrategy,
          strategy.macros,
          MacroStrategy.values,
          (value) => strategy = strategy.copyWith(macros: value),
        ),
        choice(
          'timing',
          l.nutritionMealTiming,
          strategy.timing,
          MealTiming.values,
          (value) => strategy = strategy.copyWith(timing: value),
        ),
        number('budget', l.budget, 10000, 2000000),
        number('minutes', l.cookingTime, 5, 180),
      ],
      3 => [
        choice(
          'goal',
          l.goal,
          strategy.goal,
          BodyGoal.values,
          (value) => strategy = strategy.copyWith(
            goal: value,
            energy: NutritionStrategy.energyFor(value),
          ),
        ),
        choice(
          'energy',
          l.nutritionEnergyStrategy,
          strategy.energy,
          EnergyStrategy.values,
          (value) => strategy = strategy.copyWith(energy: value),
        ),
        if (strategy.energy == EnergyStrategy.aggressiveBulk)
          Text(l.nutritionBulkTradeoff),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          key: ValueKey('screening-activity-$activity'),
          initialValue: activity,
          isExpanded: true,
          itemHeight: null,
          decoration: InputDecoration(labelText: l.dailyActivity),
          items:
              [
                    'Ít vận động',
                    'Nhẹ: 1–2 buổi/tuần',
                    'Vừa: 3–4 buổi/tuần',
                    'Nhiều: 5+ buổi/tuần',
                  ]
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(l.preference(value), maxLines: 3),
                    ),
                  )
                  .toList(),
          onChanged: (value) => setState(() => activity = value!),
        ),
        const SizedBox(height: 16),
        number('sessions', l.nutritionTrainingSessions, 0, 7),
        choice(
          'experience',
          l.nutritionExperience,
          strategy.experience,
          TrainingExperience.values,
          (value) => strategy = strategy.copyWith(experience: value),
        ),
      ],
      _ => [
        ScreeningResultCard(assessment: ScreeningRules.assess(profile)),
        const SizedBox(height: 16),
        NutritionSummaryCard(profile: nutritionProfile),
        const SizedBox(height: 20),
        Text(l.screeningPrivacy),
        check(
          'screening-consent',
          l.screeningConsent,
          consent,
          (value) => consent = value,
        ),
        if (consentError)
          Text(
            l.screeningConsentError,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Text(l.screeningSources),
          children: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: SelectableText(
                'Mifflin–St Jeor — https://pubmed.ncbi.nlm.nih.gov/2305711/\n\n'
                'Energy surplus trial — https://pmc.ncbi.nlm.nih.gov/articles/PMC10620361/\n\n'
                'ISSN: ketogenic diets — https://pubmed.ncbi.nlm.nih.gov/38934469/\n\n'
                'NIDDK: kidney nutrition — https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd/healthy-eating-adults-chronic-kidney-disease',
              ),
            ),
          ],
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final titles = [
      l.nutritionBodyMeasurements,
      l.health,
      l.preferences,
      l.nutritionTrainingGoal,
      l.screeningReview,
    ];
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(title: Text(l.screeningTitle)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Form(
                key: form,
                child: ListView(
                  key: ValueKey('screening-step-$step'),
                  controller: scroll,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      l.screeningTitle,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(l.screeningIntro),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(value: (step + 1) / 5),
                    const SizedBox(height: 12),
                    Text(l.screeningProgress(step + 1)),
                    const SizedBox(height: 8),
                    Text(
                      titles[step],
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    ...content(),
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('screening-next'),
                      onPressed: next,
                      child: Text(
                        step == 4
                            ? (ScreeningRules.assess(profile).allowsSamplePlan
                                  ? l.nutritionGenerate
                                  : l.screeningContinue)
                            : l.screeningNext,
                      ),
                    ),
                    if (step > 0)
                      TextButton(
                        onPressed: () => move(step - 1),
                        child: Text(l.back),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey('screening-decline'),
                      onPressed: widget.onDeclined,
                      child: Text(l.screeningDecline),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
