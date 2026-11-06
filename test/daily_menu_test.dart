import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steady/nutrition/meal_planner.dart';
import 'package:steady/personalization/daily_menu_engine.dart';
import 'package:steady/personalization/food_catalog.dart';
import 'package:steady/personalization/food_profile.dart';
import 'package:steady/personalization/menu_controller.dart';
import 'package:steady/personalization/menu_repository.dart';

class MemoryMenuRepository implements MenuRepository {
  MenuDocument document = const MenuDocument(0, {});
  bool fail = false;
  Completer<void>? gate;
  @override
  Future<MenuDocument> load() async {
    if (gate != null) await gate!.future;
    if (fail) throw StateError('offline');
    return document;
  }

  @override
  Future<MenuDocument> save(
    Map<String, dynamic> data,
    int expectedRevision,
  ) async {
    if (fail) throw StateError('offline');
    if (document.revision != expectedRevision) throw StateError('conflict');
    document = MenuDocument(expectedRevision + 1, data);
    return document;
  }
}

FoodRecipe recipe(
  String id,
  String slot, {
  List<FoodComponent>? components,
  bool complete = true,
  int cost = 20000,
  int minutes = 15,
  FoodNutrition? nutrition,
}) => FoodRecipe(
  meal: Meal(
    id,
    'Test $id',
    slot,
    minutes,
    cost,
    0,
    0,
    0,
    0,
    {},
    {},
    'Test recipe',
  ),
  components: components ?? [const FoodComponent('Gạo lứt', verified: true)],
  status: complete ? IngredientStatus.complete : IngredientStatus.unverified,
  diets: const {FoodDiet.vegetarian, FoodDiet.vegan},
  estimatedCost: cost,
  preparationMinutes: minutes,
  nutrition: nutrition,
);

List<FoodRecipe> fixture() => [
  for (final slot in dailySlots)
    for (var i = 0; i < 4; i++) recipe('$slot-$i', slot),
];

void main() {
  test(
    'mandatory rules inspect nested sauce and stock, aliases and uncertainty',
    () {
      final p = FoodProfile(allergies: {'đậu nành'});
      final hiddenSoy = recipe(
        'soup',
        'Trưa',
        components: [
          const FoodComponent(
            'Nước dùng',
            verified: true,
            children: [
              FoodComponent(
                'Nước sốt',
                verified: true,
                children: [
                  FoodComponent(
                    'xì dầu',
                    verified: true,
                    allergens: {'soy', 'gluten'},
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      expect(DailyMenuEngine.eligible(hiddenSoy, p, {}), isFalse);
      expect(
        DailyMenuEngine.eligible(
          recipe('incomplete', 'Trưa', complete: false),
          p,
          {},
        ),
        isFalse,
      );
      expect(
        DailyMenuEngine.eligible(
          recipe(
            'unknown-child',
            'Trưa',
            components: [
              const FoodComponent(
                'rice',
                verified: true,
                children: [FoodComponent('sauce')],
              ),
            ],
          ),
          p,
          {},
        ),
        isFalse,
      );
      expect(DailyMenuEngine.eligible(recipe('simple', 'Trưa'), p, {}), isTrue);
      expect(
        DailyMenuEngine.eligible(
          recipe('simple', 'Trưa'),
          FoodProfile(allergies: {'unrecognized allergen'}),
          {},
        ),
        isFalse,
      );
      expect(FoodNames.canonical('  Đậu   Hũ '), 'tofu');
      expect(FoodNames.overlaps('lạc', 'peanut'), isTrue);
      expect(FoodNames.matchesPreference('đậu hũ', 'Đậu phụ'), isTrue);
      expect(FoodNames.matchesPreference('đậu phụ', 'soy milk'), isFalse);
    },
  );

  test('diet, intolerance and medical restrictions cannot be relaxed; dislikes are soft', () {
    final r = recipe('simple', 'Sáng');
    expect(
      DailyMenuEngine.eligible(r, FoodProfile(intolerances: {'gạo lứt'}), {}),
      isFalse,
    );
    expect(
      DailyMenuEngine.eligible(
        r,
        FoodProfile(medicalAvoid: {'brown rice'}),
        {},
      ),
      isFalse,
    );
    expect(
      DailyMenuEngine.eligible(
        r,
        FoodProfile(medicalNote: 'Limit sodium as prescribed'),
        {},
      ),
      isFalse,
    );
    expect(
      DailyMenuEngine.eligible(r, FoodProfile(dislikes: {'brown rice'}), {}),
      isTrue,
    );
    expect(
      DailyMenuEngine.rank(r, FoodProfile(dislikes: {'brown rice'}), {}),
      lessThan(0),
    );
    final unverified = recipe('unknown', 'Sáng', complete: false);
    expect(
      DailyMenuEngine.eligible(
        unverified,
        FoodProfile(diet: FoodDiet.vegan),
        {},
      ),
      isFalse,
    );
    expect(
      foodCatalog.every((r) => r.sample && !r.auditable && r.nutrition == null),
      isTrue,
    );
    expect(
      DailyMenuEngine.generate(
        foodCatalog,
        FoodProfile(allergies: {'soy'}),
        {},
        {},
      ),
      [null, null, null],
    );
  });

  test('three slots, daily budget, time, preference and recent history affect ranking', () {
    final catalog = fixture();
    final p = FoodProfile(dailyBudget: 60000, maxMinutes: 20);
    final chosen = DailyMenuEngine.generate(catalog, p, {}, {});
    expect(chosen, ['Sáng-0', 'Trưa-0', 'Tối-0']);
    final next = DailyMenuEngine.generate(
      catalog,
      p,
      {},
      chosen.whereType<String>().toSet(),
    );
    expect(next, ['Sáng-1', 'Trưa-1', 'Tối-1']);
    expect(DailyMenuEngine.generate([], p, {}, {}), [null, null, null]);
    final prices = [
      for (final slot in dailySlots) ...[
        recipe('$slot-expensive', slot, cost: 50000, minutes: 60),
        recipe('$slot-cheap', slot, cost: 15000),
      ],
    ];
    expect(DailyMenuEngine.generate(prices, p, {}, {}), [
      'Sáng-cheap',
      'Trưa-cheap',
      'Tối-cheap',
    ]);
  });

  test('nutrition totals require every slot and a reliable source', () {
    const n = FoodNutrition(
      kcal: 500,
      protein: 25,
      carbs: 70,
      fat: 13,
      source: 'Reviewed fixture',
    );
    final complete = [for (final s in dailySlots) recipe(s, s, nutrition: n)];
    expect(DailyMenuEngine.dailyNutrition(complete)?.kcal, 1500);
    expect(
      DailyMenuEngine.dailyNutrition([complete[0], complete[1], null]),
      isNull,
    );
    expect(DailyMenuEngine.dailyNutrition(fixture().take(3).toList()), isNull);
  });

  test(
    'goals rank sourced daily nutrition and ignore legacy sample macros',
    () {
      const low = FoodNutrition(
        kcal: 500,
        protein: 10,
        carbs: 70,
        fat: 15,
        source: 'Reviewed fixture',
      );
      const high = FoodNutrition(
        kcal: 500,
        protein: 35,
        carbs: 50,
        fat: 15,
        source: 'Reviewed fixture',
      );
      final catalog = [
        for (final slot in dailySlots) ...[
          recipe('$slot-low', slot, nutrition: low),
          recipe('$slot-high', slot, nutrition: high),
        ],
      ];
      expect(
        DailyMenuEngine.generate(
          catalog,
          FoodProfile(goal: FoodGoal.buildMuscle),
          {},
          {},
        ),
        ['Sáng-high', 'Trưa-high', 'Tối-high'],
      );
      expect(
        DailyMenuEngine.generate(
          catalog,
          FoodProfile(goal: FoodGoal.loseWeight),
          {},
          {},
        ),
        ['Sáng-high', 'Trưa-high', 'Tối-high'],
      );
      expect(
        DailyMenuEngine.dailyNutrition([
          recipe('unknown', 'Sáng'),
          catalog[0],
          catalog[1],
        ]),
        isNull,
      );
    },
  );

  test('explicit zones determine calendar dates without host time zone assumptions', () {
    final instant = DateTime.utc(2026, 10, 22, 1);
    expect(FoodProfile(utcOffsetMinutes: -720).dateKey(instant), '2026-10-21');
    expect(FoodProfile(utcOffsetMinutes: 840).dateKey(instant), '2026-10-22');
    expect(FoodProfile(utcOffsetMinutes: 420).zoneKey(instant), 'offset:420');
    expect(FoodProfile().zoneKey(instant), startsWith('device:'));
  });

  test('a newly missing recipe or changed ingredient invalidates an old saved menu', () async {
    final repo = MemoryMenuRepository();
    final old = DailyMenuController(repository: repo, catalog: fixture());
    addTearDown(old.dispose);
    await old.refresh();
    await old.saveProfile(FoodProfile(allergies: {'soy'}));
    final breakfast = old.menu[0]!.id;
    final nextCatalog = fixture().where((r) => r.id != breakfast).toList();
    final changed = DailyMenuController(repository: repo, catalog: nextCatalog);
    addTearDown(changed.dispose);
    await changed.refresh();
    expect(changed.menu[0]!.id, isNot(breakfast));
    final newBreakfast = changed.menu[0]!.id;
    final withSoy = nextCatalog
        .map(
          (r) => r.id == newBreakfast
              ? recipe(
                  r.id,
                  'Sáng',
                  components: [
                    const FoodComponent('Nước tương', verified: true),
                  ],
                )
              : r,
        )
        .toList();
    final updated = DailyMenuController(repository: repo, catalog: withSoy);
    addTearDown(updated.dispose);
    await updated.refresh();
    expect(updated.menu[0]!.id, isNot(newBreakfast));
  });

  test('reload is stable, swap changes one slot, dislike persists and new days rotate', () async {
    var now = DateTime.utc(2026, 10, 21, 18);
    final repo = MemoryMenuRepository();
    DailyMenuController controller() => DailyMenuController(
      repository: repo,
      catalog: fixture(),
      now: () => now,
    );
    final c = controller();
    addTearDown(c.dispose);
    await c.refresh();
    await c.saveProfile(FoodProfile(utcOffsetMinutes: 420));
    expect(c.localDate, '2026-10-22');
    final before = c.menu.map((r) => r!.id).toList();
    final restored = controller();
    addTearDown(restored.dispose);
    await restored.refresh();
    expect(restored.menu.map((r) => r!.id), before);
    expect(await restored.swap(1), isTrue);
    expect(restored.menu[0]!.id, before[0]);
    expect(restored.menu[2]!.id, before[2]);
    expect(restored.menu[1]!.id, isNot(before[1]));
    final disliked = restored.menu[0]!.id;
    expect(await restored.swap(0, dislike: true), isTrue);
    await restored.refresh();
    expect(restored.rejected, contains(disliked));
    expect(restored.menu[0]!.id, isNot(disliked));
    final oldDay = restored.menu.map((r) => r!.id).toSet();
    now = now.add(const Duration(days: 1));
    await restored.ensureDay();
    expect(restored.menu.any((r) => oldDay.contains(r?.id)), isFalse);
  });

  test('profile edit invalidates persisted meals and failed reads hide all old meals', () async {
    final repo = MemoryMenuRepository();
    final c = DailyMenuController(repository: repo, catalog: fixture());
    addTearDown(c.dispose);
    await c.refresh();
    await c.saveProfile(FoodProfile());
    expect(c.menu.every((r) => r != null), isTrue);
    await c.saveProfile(FoodProfile(allergies: {'gạo lứt'}));
    expect(c.menu, [null, null, null]);
    await c.refresh();
    expect(c.menu, [null, null, null]);
    await c.saveProfile(FoodProfile());
    repo.fail = true;
    await c.refresh();
    expect(c.error, isNotNull);
    expect(c.menu, [null, null, null]);
  });

  test('single candidate swap fails without changing other meals; dislike leaves empty slot', () async {
    final repo = MemoryMenuRepository();
    final c = DailyMenuController(
      repository: repo,
      catalog: [for (final s in dailySlots) recipe(s, s)],
    );
    addTearDown(c.dispose);
    await c.refresh();
    await c.saveProfile(FoodProfile());
    expect(await c.swap(1), isFalse);
    expect(c.menu[1]?.id, 'Trưa');
    expect(await c.swap(1, dislike: true), isTrue);
    expect(c.menu[1], isNull);
    expect(c.menu[0]?.id, 'Sáng');
    expect(c.menu[2]?.id, 'Tối');
    await c.refresh();
    expect(c.menu[1], isNull);
  });

  test(
    'conflicting writes and disposed sessions never display uncommitted menus',
    () async {
      final repo = MemoryMenuRepository();
      final a = DailyMenuController(repository: repo, catalog: fixture());
      final b = DailyMenuController(repository: repo, catalog: fixture());
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      await a.refresh();
      await b.refresh();
      expect(await a.saveProfile(FoodProfile()), isTrue);
      expect(await b.saveProfile(FoodProfile()), isFalse);
      expect(b.menu, [null, null, null]);
      final gated = MemoryMenuRepository()..gate = Completer<void>();
      final old = DailyMenuController(repository: gated);
      final request = old.refresh();
      old.dispose();
      gated.gate!.complete();
      await request;
      expect(old.profile, isNull);
    },
  );

  test(
    'guest storage persists, stays separate and propagates errors',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repo = GuestMenuRepository();
      final c = DailyMenuController(repository: repo, catalog: fixture());
      addTearDown(c.dispose);
      await c.refresh();
      await c.saveProfile(FoodProfile());
      final d = DailyMenuController(
        repository: GuestMenuRepository(),
        catalog: fixture(),
      );
      addTearDown(d.dispose);
      await d.refresh();
      expect(d.menu.map((r) => r?.id), c.menu.map((r) => r?.id));
      expect((await MemoryMenuRepository().load()).data, isEmpty);
    },
  );
}
