/// Ingredient identities are independent of UI language. Unknown terms stay
/// unknown: in particular they must never mean “no allergen”.
class FoodNames {
  static const aliases = <String, String>{
    'đậu nành': 'soy',
    'đậu nành chín': 'soy',
    'soybean': 'soy',
    'soybeans': 'soy',
    'soya': 'soy',
    'soy': 'soy',
    'đậu phụ': 'tofu',
    'đậu hũ': 'tofu',
    'tofu': 'tofu',
    'sữa đậu nành không đường': 'soy_milk',
    'soy milk': 'soy_milk',
    'sữa': 'milk',
    'sữa bò': 'milk',
    'milk': 'milk',
    'dairy': 'milk',
    'trứng': 'egg',
    'eggs': 'egg',
    'egg': 'egg',
    'lạc': 'peanut',
    'đậu phộng': 'peanut',
    'peanuts': 'peanut',
    'peanut': 'peanut',
    'hạt cây': 'nuts',
    'tree nuts': 'nuts',
    'nuts': 'nuts',
    'vừng': 'sesame',
    'mè': 'sesame',
    'sesame': 'sesame',
    'cá': 'fish',
    'fish': 'fish',
    'cá rô phi phi lê': 'tilapia',
    'hải sản có vỏ': 'shellfish',
    'tôm': 'shrimp',
    'shrimp': 'shrimp',
    'shellfish': 'shellfish',
    'gluten': 'gluten',
    'lúa mì': 'wheat',
    'wheat': 'wheat',
    'bột mì': 'wheat',
    'nước tương': 'soy_sauce',
    'xì dầu': 'soy_sauce',
    'soy sauce': 'soy_sauce',
    'nước mắm': 'fish_sauce',
    'fish sauce': 'fish_sauce',
    'dầu hào': 'oyster_sauce',
    'oyster sauce': 'oyster_sauce',
    'yến mạch': 'oats',
    'oats': 'oats',
    'chuối': 'banana',
    'banana': 'banana',
    'khoai lang': 'sweet_potato',
    'sweet potato': 'sweet_potato',
    'ổi': 'guava',
    'guava': 'guava',
    'đậu xanh': 'mung_bean',
    'mung beans': 'mung_bean',
    'gạo lứt': 'brown_rice',
    'brown rice': 'brown_rice',
    'đậu đỏ chín': 'red_bean',
    'red beans': 'red_bean',
    'dưa chuột': 'cucumber',
    'dưa leo': 'cucumber',
    'cucumber': 'cucumber',
    'dầu cải': 'canola_oil',
    'canola oil': 'canola_oil',
    'rau cải': 'greens',
    'greens': 'greens',
    'cà chua': 'tomato',
    'tomato': 'tomato',
    'cà rốt': 'carrot',
    'carrot': 'carrot',
    'ức gà bỏ da': 'chicken',
    'gà': 'chicken',
    'chicken': 'chicken',
    'nấm': 'mushroom',
    'mushrooms': 'mushroom',
    'bơ quả': 'avocado',
    'avocado': 'avocado',
    'nước': 'water',
    'water': 'water',
    'muối': 'salt',
    'salt': 'salt',
  };

  static String canonical(String value) {
    final term = value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return aliases[term] ?? term;
  }

  static Set<String> terms(Iterable<String> values) =>
      values.map(canonical).where((s) => s.isNotEmpty).toSet();

  static const allergenGroups = {
    'soy': {'soy', 'tofu', 'soy_milk', 'soy_sauce'},
    'fish': {'fish', 'tilapia', 'fish_sauce'},
    'shellfish': {'shellfish', 'shrimp', 'oyster_sauce'},
    'gluten': {'gluten', 'wheat', 'soy_sauce', 'oats'},
    'milk': {'milk'},
    'egg': {'egg'},
    'peanut': {'peanut'},
    'nuts': {'nuts'},
    'sesame': {'sesame'},
  };

  /// Matching a group (soy) also matches its ingredients (tofu), and vice versa.
  static bool overlaps(String a, String b) {
    a = canonical(a);
    b = canonical(b);
    if (a == b) return true;
    return allergenGroups.values.any(
      (group) => group.contains(a) && group.contains(b),
    );
  }

  static bool matchesPreference(String term, String ingredient) {
    term = canonical(term);
    ingredient = canonical(ingredient);
    return term == ingredient ||
        (allergenGroups[term]?.contains(ingredient) ?? false);
  }
}

enum FoodDiet { unrestricted, vegetarian, vegan }

enum FoodGoal { maintain, loseWeight, buildMuscle }

class FoodProfile {
  FoodProfile({
    Set<String> allergies = const {},
    Set<String> intolerances = const {},
    Set<String> favorites = const {},
    Set<String> dislikes = const {},
    Set<String> medicalAvoid = const {},
    this.medicalNote = '',
    this.diet = FoodDiet.unrestricted,
    this.goal = FoodGoal.maintain,
    this.dailyBudget,
    this.maxMinutes,
    this.utcOffsetMinutes,
  }) : allergies = FoodNames.terms(allergies),
       intolerances = FoodNames.terms(intolerances),
       favorites = FoodNames.terms(favorites),
       dislikes = FoodNames.terms(dislikes),
       medicalAvoid = FoodNames.terms(medicalAvoid);

  final Set<String> allergies, intolerances, favorites, dislikes, medicalAvoid;
  final String medicalNote;
  final FoodDiet diet;
  final FoodGoal goal;
  final int? dailyBudget, maxMinutes;

  /// Null follows the device's local zone, including DST. Explicit offsets are
  /// fixed offsets, never presented as IANA zones with daylight-saving support.
  final int? utcOffsetMinutes;
  String zoneKey(DateTime instant) {
    if (utcOffsetMinutes != null) return 'offset:$utcOffsetMinutes';
    final local = instant.toLocal();
    return 'device:${local.timeZoneName}:${local.timeZoneOffset.inMinutes}';
  }

  String dateKey(DateTime instant) {
    final date = utcOffsetMinutes == null
        ? instant.toLocal()
        : instant.toUtc().add(Duration(minutes: utcOffsetMinutes!));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {
    'allergies': allergies.toList()..sort(),
    'intolerances': intolerances.toList()..sort(),
    'favorites': favorites.toList()..sort(),
    'dislikes': dislikes.toList()..sort(),
    'medicalAvoid': medicalAvoid.toList()..sort(),
    'medicalNote': medicalNote,
    'diet': diet.name,
    'goal': goal.name,
    'dailyBudget': dailyBudget,
    'maxMinutes': maxMinutes,
    'utcOffsetMinutes': utcOffsetMinutes,
  };

  factory FoodProfile.fromJson(Map<String, dynamic> json) {
    Set<String> strings(String key) =>
        (json[key] as List? ?? []).cast<String>().toSet();
    final offset = json['utcOffsetMinutes'] as int?;
    final budget = json['dailyBudget'] as int?;
    final minutes = json['maxMinutes'] as int?;
    if ((offset != null && (offset < -720 || offset > 840)) ||
        (budget != null && budget <= 0) ||
        (minutes != null && minutes <= 0)) {
      throw const FormatException('Invalid food preferences');
    }
    return FoodProfile(
      allergies: strings('allergies'),
      intolerances: strings('intolerances'),
      favorites: strings('favorites'),
      dislikes: strings('dislikes'),
      medicalAvoid: strings('medicalAvoid'),
      medicalNote: json['medicalNote'] as String? ?? '',
      diet: FoodDiet.values.byName(json['diet'] as String),
      goal: FoodGoal.values.byName(json['goal'] as String),
      dailyBudget: budget,
      maxMinutes: minutes,
      utcOffsetMinutes: offset,
    );
  }
}
