/// Prototype recipe values are estimates, not validated clinical nutrition data.
class NutritionProfile {
  final int age;
  final double height, weight;
  final String goal, activity, cholesterol, diet;
  final int budget, minutes;
  final Set<String> exclusions;
  final String bloodPressure, lipidResults;
  final bool needsProfessionalPlan;
  const NutritionProfile({
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.activity,
    required this.cholesterol,
    required this.diet,
    required this.budget,
    required this.minutes,
    required this.exclusions,
    this.bloodPressure = '',
    this.lipidResults = '',
    this.needsProfessionalPlan = false,
  });
  bool get supported => age >= 18 && !needsProfessionalPlan;
}

class Meal {
  final String id, name, slot, recipe;
  final int minutes, cost, kcal, protein, fibre;
  final double saturatedFat;
  final Map<String, double> ingredients; // grams, raw edible weight
  final Set<String> contains;
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
    this.recipe,
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
  ),
];

class MealPlanner {
  static List<Meal> candidates(NutritionProfile p, String slot) {
    if (!p.supported) return [];
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
                      !m.contains.contains('fish'))),
        )
        .toList()
      ..sort((a, b) {
        if (p.goal == 'Hỗ trợ tăng cơ') return b.protein.compareTo(a.protein);
        return b.fibre.compareTo(a.fibre);
      });
  }

  static List<List<Meal>> generate(NutritionProfile p) {
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
    return candidates(p, current.slot)
        .where((m) => m.id != current.id && otherCost + m.cost <= p.budget)
        .toList();
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
