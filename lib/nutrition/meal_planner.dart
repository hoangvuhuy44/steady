import 'nutrition_profile.dart';
import 'nutrition_strategy.dart';
import 'nutrition_targets.dart';

export 'nutrition_profile.dart';

class Meal {
  final String id, name, slot, recipe;
  final int minutes, cost, kcal, protein, fibre;
  final double saturatedFat;
  final Map<String, double> ingredients; // grams, raw edible weight
  final Set<String> contains;
  final double carbs, fat, sodium, servings;
  const Meal(
    this.id,
    this.name,
    this.slot,
    this.minutes,
    this.cost,
    this.kcal,
    this.protein,
    this.fibre,
    this.saturatedFat,
    this.ingredients,
    this.contains,
    this.recipe, {
    this.carbs = 0,
    this.fat = 0,
    this.sodium = 0,
    this.servings = 1,
  });

  Meal scaled(double factor) => Meal(
    id,
    name,
    slot,
    minutes,
    (cost * factor).ceil(),
    (kcal * factor).round(),
    (protein * factor).round(),
    (fibre * factor).round(),
    saturatedFat * factor,
    ingredients.map((name, grams) => MapEntry(name, grams * factor)),
    contains,
    recipe,
    carbs: carbs * factor,
    fat: fat * factor,
    sodium: sodium * factor,
    servings: servings * factor,
  );
}

const meals = <Meal>[
  Meal(
    'oats',
    'Cháo yến mạch chuối',
    'Sáng',
    10,
    18000,
    410,
    13,
    9,
    1.2,
    {'Yến mạch': 70, 'Chuối': 100, 'Sữa đậu nành không đường': 200},
    {'soy', 'gluten'},
    'Nấu yến mạch với sữa đậu nành và nước 5–7 phút. Thêm chuối. Không thêm đường.',
    carbs: 67,
    fat: 10,
    sodium: 80,
  ),
  Meal(
    'sweet',
    'Khoai lang, đậu nành và trái cây',
    'Sáng',
    20,
    22000,
    430,
    18,
    10,
    1,
    {'Khoai lang': 250, 'Đậu nành chín': 100, 'Ổi': 100},
    {'soy'},
    'Hấp khoai lang 15–20 phút. Ăn cùng đậu nành đã nấu chín và ổi rửa sạch.',
    carbs: 62,
    fat: 13,
    sodium: 110,
  ),
  Meal(
    'beanbreakfast',
    'Cháo đậu xanh và chuối',
    'Sáng',
    25,
    19000,
    440,
    15,
    11,
    0.5,
    {'Đậu xanh': 60, 'Gạo lứt': 50, 'Chuối': 100},
    {},
    'Ngâm đậu và gạo trước. Nấu với nước đến mềm; dùng nồi áp suất để tiết kiệm thời gian. Ăn chuối riêng.',
    carbs: 85,
    fat: 4,
    sodium: 40,
  ),
  Meal(
    'ricebreakfast',
    'Cơm lứt đậu đỏ, dưa chuột',
    'Sáng',
    20,
    22000,
    460,
    15,
    12,
    0.8,
    {'Gạo lứt': 70, 'Đậu đỏ chín': 150, 'Dưa chuột': 150, 'Dầu cải': 5},
    {},
    'Dùng cơm đã nấu và đậu đã luộc. Hâm nóng, ăn cùng dưa chuột và dầu cải.',
    carbs: 82,
    fat: 8,
    sodium: 40,
  ),
  Meal(
    'fish',
    'Cơm lứt cá hấp và rau',
    'Trưa',
    25,
    45000,
    620,
    38,
    8,
    1.5,
    {'Gạo lứt': 90, 'Cá rô phi phi lê': 150, 'Rau cải': 250, 'Dầu cải': 10},
    {'fish'},
    'Nấu cơm. Hấp cá với gừng 10–15 phút đến chín. Luộc rau, thêm dầu cải. Gia vị và nước chấm tính riêng.',
    carbs: 77,
    fat: 18,
    sodium: 140,
  ),
  Meal(
    'tofu',
    'Đậu phụ sốt cà chua, cơm lứt',
    'Trưa',
    20,
    32000,
    590,
    25,
    10,
    1.8,
    {
      'Gạo lứt': 80,
      'Đậu phụ': 200,
      'Cà chua': 150,
      'Rau cải': 200,
      'Dầu cải': 5,
    },
    {'soy'},
    'Nấu cơm. Đun cà chua với ít nước và dầu, thêm đậu phụ; ăn cùng rau luộc. Không chiên ngập dầu.',
    carbs: 75,
    fat: 21,
    sodium: 100,
  ),
  Meal(
    'lentil',
    'Cơm đậu xanh và rau củ',
    'Trưa',
    25,
    29000,
    610,
    23,
    15,
    0.7,
    {
      'Gạo lứt': 80,
      'Đậu xanh': 70,
      'Cà rốt': 150,
      'Rau cải': 200,
      'Dầu cải': 5,
    },
    {},
    'Dùng đậu đã ngâm và cơm đã nấu. Nấu đậu chín mềm, thêm cà rốt và rau; trộn với cơm và dầu.',
    carbs: 99,
    fat: 14,
    sodium: 130,
  ),
  Meal(
    'chicken',
    'Ức gà áp chảo, cơm và rau',
    'Trưa',
    25,
    42000,
    630,
    43,
    8,
    1.6,
    {'Gạo lứt': 90, 'Ức gà bỏ da': 150, 'Rau cải': 250, 'Dầu cải': 10},
    {'meat'},
    'Nấu cơm. Áp chảo gà bỏ da với dầu đến chín kỹ. Ăn với rau hấp; hạn chế nước sốt đóng chai.',
    carbs: 77,
    fat: 17,
    sodium: 170,
  ),
  Meal(
    'beanDinner',
    'Đậu đỏ, khoai lang và rau xanh',
    'Tối',
    20,
    30000,
    560,
    20,
    16,
    0.8,
    {'Đậu đỏ chín': 200, 'Khoai lang': 250, 'Rau cải': 200, 'Dầu cải': 5},
    {},
    'Hấp khoai. Hâm đậu đỏ đã nấu chín; ăn với rau luộc và dầu cải.',
    carbs: 95,
    fat: 11,
    sodium: 200,
  ),
  Meal(
    'fishDinner',
    'Cá hấp, khoai lang và rau',
    'Tối',
    25,
    43000,
    580,
    36,
    9,
    1.4,
    {'Cá rô phi phi lê': 150, 'Khoai lang': 300, 'Rau cải': 250, 'Dầu cải': 10},
    {'fish'},
    'Hấp khoai và cá đến chín, luộc rau. Dùng gừng và chanh; nước chấm tính riêng.',
    carbs: 68,
    fat: 18,
    sodium: 250,
  ),
  Meal(
    'tofuDinner',
    'Đậu phụ hấp nấm và cơm lứt',
    'Tối',
    20,
    33000,
    570,
    26,
    10,
    1.8,
    {'Đậu phụ': 200, 'Nấm': 150, 'Gạo lứt': 70, 'Rau cải': 200, 'Dầu cải': 5},
    {'soy'},
    'Hấp đậu phụ với nấm đến nóng và chín. Ăn cùng cơm lứt, rau và dầu cải.',
    carbs: 71,
    fat: 20,
    sodium: 100,
  ),
  Meal(
    'chickenDinner',
    'Gà bỏ da, khoai và rau',
    'Tối',
    25,
    40000,
    590,
    40,
    9,
    1.5,
    {'Ức gà bỏ da': 150, 'Khoai lang': 300, 'Rau cải': 200, 'Dầu cải': 10},
    {'meat'},
    'Hấp khoai, luộc hoặc áp chảo gà đến chín kỹ. Ăn cùng rau luộc.',
    carbs: 64,
    fat: 19,
    sodium: 250,
  ),
  Meal(
    'tofuScramble',
    'Đậu phụ xào rau',
    'Sáng',
    15,
    29000,
    470,
    40,
    8,
    3,
    {'Đậu phụ': 300, 'Nấm': 100, 'Rau cải': 150, 'Dầu cải': 15},
    {'soy'},
    'Làm nóng đậu phụ và rau với dầu; dùng đậu phụ không tẩm ướp. Không thêm nước sốt mặn.',
    carbs: 14,
    fat: 29,
    sodium: 90,
  ),
  Meal(
    'eggPotato',
    'Trứng, khoai lang và rau',
    'Sáng',
    20,
    27000,
    530,
    20,
    9,
    4,
    {'Trứng': 150, 'Khoai lang': 200, 'Rau cải': 150, 'Dầu cải': 10},
    {'egg'},
    'Luộc trứng chín kỹ, hấp khoai và rau; trộn rau với dầu. Không thêm muối.',
    carbs: 48,
    fat: 29,
    sodium: 320,
  ),
  Meal(
    'ketoEgg',
    'Trứng và bơ',
    'Sáng',
    15,
    32000,
    710,
    27,
    8,
    7,
    {'Trứng': 200, 'Bơ quả': 80, 'Dưa chuột': 100, 'Dầu cải': 35},
    {'egg'},
    'Luộc trứng chín kỹ. Ăn cùng bơ quả và dưa chuột; không thêm muối.',
    carbs: 10,
    fat: 63,
    sodium: 290,
  ),
  Meal(
    'ketoChicken',
    'Salad gà và bơ',
    'Trưa',
    25,
    45000,
    700,
    42,
    9,
    5,
    {'Ức gà bỏ da': 200, 'Bơ quả': 100, 'Rau cải': 200, 'Dầu cải': 40},
    {'meat'},
    'Nấu chín kỹ gà và rau. Ăn cùng bơ quả, dầu và chanh; không thêm sốt mặn.',
    carbs: 12,
    fat: 54,
    sodium: 190,
  ),
  Meal(
    'ketoFish',
    'Cá hấp và rau ít tinh bột',
    'Tối',
    25,
    42000,
    650,
    40,
    7,
    4,
    {'Cá rô phi phi lê': 200, 'Rau cải': 250, 'Dưa chuột': 100, 'Dầu cải': 45},
    {'fish'},
    'Hấp cá chín kỹ và luộc rau; ăn cùng dầu và chanh. Không thêm muối hay nước chấm.',
    carbs: 10,
    fat: 50,
    sodium: 170,
  ),
  Meal(
    'ketoTofuLunch',
    'Đậu phụ và bơ quả',
    'Trưa',
    15,
    34000,
    670,
    32,
    10,
    4,
    {'Đậu phụ': 250, 'Bơ quả': 100, 'Dưa chuột': 100, 'Dầu cải': 35},
    {'soy'},
    'Nấu chín đậu phụ không tẩm ướp. Ăn với bơ quả, dưa chuột và dầu; không thêm muối.',
    carbs: 12,
    fat: 55,
    sodium: 65,
  ),
  Meal(
    'ketoTofuDinner',
    'Đậu phụ, nấm và rau',
    'Tối',
    20,
    30000,
    640,
    34,
    8,
    4,
    {'Đậu phụ': 300, 'Nấm': 100, 'Rau cải': 150, 'Dầu cải': 40},
    {'soy'},
    'Nấu chín đậu phụ, nấm và rau với dầu. Không thêm muối hay nước sốt.',
    carbs: 12,
    fat: 51,
    sodium: 90,
  ),
  Meal(
    'paleoChicken',
    'Gà, khoai lang và rau củ',
    'Trưa',
    25,
    40000,
    660,
    22,
    16,
    2,
    {'Ức gà bỏ da': 80, 'Khoai lang': 450, 'Rau cải': 200, 'Dầu cải': 15},
    {'meat'},
    'Nấu chín kỹ gà, hấp khoai và rau. Dùng toàn bộ lượng dầu ghi trong nguyên liệu để trộn rau; không thêm muối.',
    carbs: 100,
    fat: 20,
    sodium: 210,
  ),
  Meal(
    'soySnack',
    'Đậu nành và ổi',
    'Bữa phụ',
    5,
    18000,
    270,
    22,
    7,
    1.5,
    {'Đậu nành chín': 150, 'Ổi': 100},
    {'soy'},
    'Hâm nóng đậu nành đã luộc không muối. Ăn cùng ổi rửa sạch.',
    carbs: 20,
    fat: 13,
    sodium: 10,
  ),
  Meal(
    'eggSnack',
    'Trứng và dưa chuột',
    'Bữa phụ',
    15,
    13000,
    230,
    20,
    2,
    4,
    {'Trứng': 150, 'Dưa chuột': 150},
    {'egg'},
    'Luộc trứng chín kỹ. Ăn cùng dưa chuột rửa sạch; không thêm muối.',
    carbs: 6,
    fat: 15,
    sodium: 220,
  ),
];

class MealPlanner {
  static List<Meal> candidates(NutritionProfile p, String slot) {
    if (!p.supported || NutritionTargets.unavailableReason(p) != null) {
      return [];
    }
    return meals
        .where(
          (m) =>
              m.slot == slot &&
              m.minutes <= p.minutes &&
              m.cost <= p.budget &&
              !m.contains.any(p.exclusions.contains) &&
              !m.ingredients.keys.any(p.exclusions.contains) &&
              (p.diet != 'Chay' ||
                  (!m.contains.contains('meat') &&
                      !m.contains.contains('fish'))) &&
              _matchesStrategy(p, m),
        )
        .toList()
      ..sort((a, b) {
        if (p.goal == 'Hỗ trợ tăng cơ') return b.protein.compareTo(a.protein);
        return b.fibre.compareTo(a.fibre);
      });
  }

  static List<List<Meal>> generate(NutritionProfile p) {
    if (p.strategy != null) return _generatePersonalized(p);
    final pools = ['Sáng', 'Trưa', 'Tối'].map((s) => candidates(p, s)).toList();
    if (pools.any((pool) => pool.isEmpty)) return [];
    final combinations = <List<Meal>>[];
    for (final breakfast in pools[0]) {
      for (final lunch in pools[1]) {
        for (final dinner in pools[2]) {
          if (breakfast.cost + lunch.cost + dinner.cost <= p.budget) {
            combinations.add([breakfast, lunch, dinner]);
          }
        }
      }
    }
    if (combinations.isEmpty) return [];
    final usage = <String, int>{};
    int score(List<Meal> combination) => List.generate(
      3,
      (slot) =>
          (usage[combination[slot].id] ?? 0) * 10 +
          pools[slot].indexOf(combination[slot]),
    ).fold(0, (sum, value) => sum + value);
    return List.generate(7, (_) {
      var selected = combinations.first;
      for (final combination in combinations.skip(1)) {
        if (score(combination) < score(selected)) selected = combination;
      }
      for (final meal in selected) {
        usage.update(meal.id, (count) => count + 1, ifAbsent: () => 1);
      }
      return List.of(selected);
    });
  }

  static List<Meal> alternatives(NutritionProfile p, List<Meal> day, int slot) {
    if (slot < 0 || slot >= day.length) return [];
    final current = day[slot];
    final otherCost = day.fold<int>(0, (s, m) => s + m.cost) - current.cost;
    if (p.strategy != null) {
      final targets = NutritionTargets.estimate(p);
      if (targets == null) return [];
      return candidates(p, current.slot)
          .where((meal) => meal.id != current.id)
          .expand((meal) => _portions.map(meal.scaled))
          .where((meal) {
            final replacement = List<Meal>.of(day)..[slot] = meal;
            return _fits(p, targets, replacement);
          })
          .toList();
    }
    return candidates(p, current.slot)
        .where((m) => m.id != current.id && otherCost + m.cost <= p.budget)
        .toList();
  }

  static const _portions = [0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  static bool _matchesStrategy(NutritionProfile p, Meal m) {
    final s = p.strategy;
    if (s == null) return m.slot != 'Bữa phụ';
    if (s.source != FoodSource.omnivore &&
        m.contains.any({'meat', 'fish', 'shellfish'}.contains)) {
      return false;
    }
    if (s.source == FoodSource.vegan &&
        m.contains.any({'egg', 'milk'}.contains)) {
      return false;
    }
    if (s.pattern == FoodPattern.paleo &&
        m.ingredients.keys.any(
          {
            'Yến mạch',
            'Gạo lứt',
            'Đậu phụ',
            'Đậu xanh',
            'Đậu đỏ chín',
            'Đậu nành chín',
            'Sữa đậu nành không đường',
          }.contains,
        )) {
      return false;
    }
    if (s.macros == MacroStrategy.ketogenic && m.carbs > 16) return false;
    return true;
  }

  static bool _fits(NutritionProfile p, NutritionTargets t, List<Meal> day) {
    final kcal = day.fold<double>(0, (sum, m) => sum + m.kcal);
    final protein = day.fold<double>(0, (sum, m) => sum + m.protein);
    final carbs = day.fold<double>(0, (sum, m) => sum + m.carbs);
    final fat = day.fold<double>(0, (sum, m) => sum + m.fat);
    if (day.fold<int>(0, (sum, m) => sum + m.cost) > p.budget ||
        kcal < t.kcal * 0.90 ||
        kcal > t.kcal * 1.10 ||
        protein < t.protein * 0.90 ||
        protein > t.protein * 1.30 ||
        day.fold<double>(0, (sum, m) => sum + m.sodium) > t.sodiumLimit ||
        day.fold<double>(0, (sum, m) => sum + m.saturatedFat) >
            t.saturatedFatLimit) {
      return false;
    }
    if (p.strategy!.macros == MacroStrategy.ketogenic) {
      if (carbs > 50 || fat * 9 < kcal * 0.55) return false;
    } else if (carbs < t.carbs * 0.75 ||
        carbs > t.carbs * 1.25 ||
        fat < t.fat * 0.70 ||
        fat > t.fat * 1.30) {
      return false;
    }
    if (p.strategy!.pattern == FoodPattern.mediterranean &&
        day.fold<double>(0, (sum, m) => sum + m.saturatedFat) * 9 >
            kcal * 0.07) {
      return false;
    }
    // Fibre is a food-quality constraint, including for low-carbohydrate menus.
    return day.fold<int>(0, (sum, m) => sum + m.fibre) >= 25;
  }

  static List<List<Meal>> _generatePersonalized(NutritionProfile p) {
    final targets = NutritionTargets.estimate(p);
    if (targets == null) return [];
    final slots = [
      'Sáng',
      'Trưa',
      if (p.strategy!.timing == MealTiming.fourMeals) 'Bữa phụ',
      'Tối',
    ];
    final pools = slots
        .map(
          (slot) => candidates(p, slot)
              .expand((meal) => _portions.map(meal.scaled))
              .where(
                (meal) =>
                    meal.cost <= p.budget && meal.kcal <= targets.kcal * 0.65,
              )
              .toList(),
        )
        .toList();
    if (pools.any((pool) => pool.isEmpty)) return [];
    final combinations = <List<Meal>>[];
    void search(int slot, List<Meal> day, int cost, int kcal) {
      if (cost > p.budget || kcal > targets.kcal * 1.10) return;
      if (slot == pools.length) {
        if (_fits(p, targets, day)) combinations.add(List.of(day));
        return;
      }
      for (final meal in pools[slot]) {
        day.add(meal);
        search(slot + 1, day, cost + meal.cost, kcal + meal.kcal);
        day.removeLast();
      }
    }

    search(0, [], 0, 0);
    if (combinations.isEmpty) return [];
    double mismatch(List<Meal> day) {
      final kcal = day.fold<double>(0, (sum, m) => sum + m.kcal);
      final protein = day.fold<double>(0, (sum, m) => sum + m.protein);
      final carbs = day.fold<double>(0, (sum, m) => sum + m.carbs);
      return (kcal - targets.kcal).abs() / targets.kcal +
          (protein - targets.protein).abs() / targets.protein +
          (carbs - targets.carbs).abs() / targets.carbs;
    }

    combinations.sort((a, b) => mismatch(a).compareTo(mismatch(b)));
    final shortlist = combinations.take(500).toList();
    final usage = <String, int>{};
    double score(List<Meal> day) =>
        mismatch(day) +
        day.fold<double>(0, (sum, m) => sum + (usage[m.id] ?? 0) * 0.12);
    return List.generate(7, (_) {
      var selected = shortlist.first;
      for (final candidate in shortlist.skip(1)) {
        if (score(candidate) < score(selected)) selected = candidate;
      }
      for (final meal in selected) {
        usage.update(meal.id, (value) => value + 1, ifAbsent: () => 1);
      }
      return List.of(selected);
    });
  }

  static Map<String, double> groceries(List<List<Meal>> plan) {
    final result = <String, double>{};
    for (final day in plan) {
      for (final meal in day) {
        meal.ingredients.forEach(
          (name, grams) => result.update(
            name,
            (value) => value + grams,
            ifAbsent: () => grams,
          ),
        );
      }
    }
    return result;
  }
}
