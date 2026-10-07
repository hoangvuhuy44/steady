import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_type.dart';
import '../nutrition/meal_planner.dart';
import 'app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension SteadyLocalization on AppLocalizations {
  String money(num amount) => NumberFormat.currency(
    locale: localeName,
    name: 'VND',
    symbol: '₫',
    decimalDigits: 0,
  ).format(amount);
  String number(num value) =>
      NumberFormat.decimalPattern(localeName).format(value);
  String grams(num value) => '${number(value)} g';

  String activityName(ActivityType type) => switch (type) {
    ActivityType.walk => walk,
    ActivityType.run => run,
    ActivityType.cycle => cycle,
    ActivityType.swim => swim,
    ActivityType.gym => gym,
    ActivityType.sport => sport,
    ActivityType.mma => mma,
    ActivityType.other => other,
  };

  // Catalogue and profile values stay invariant across UI languages.
  String preference(String value) => switch (value) {
    'Ăn uống cân bằng' => balanced,
    'Hỗ trợ giảm cân' => weightLoss,
    'Hỗ trợ tăng cơ' => muscle,
    'Ít vận động' => sedentary,
    'Nhẹ: 1–2 buổi/tuần' => lightActivity,
    'Vừa: 3–4 buổi/tuần' => moderateActivity,
    'Nhiều: 5+ buổi/tuần' => highActivity,
    'Chưa biết' => unknown,
    'Đã xác nhận' => confirmed,
    'Chưa được chẩn đoán' => notDiagnosed,
    'Ăn đa dạng' => omnivore,
    'Chay' => vegetarian,
    _ => throw ArgumentError.value(value, 'preference'),
  };
  String mealSlot(String slot) => switch (slot) {
    'Sáng' => breakfast,
    'Trưa' => lunch,
    'Tối' => dinner,
    'Bữa phụ' => snack,
    _ => throw ArgumentError.value(slot, 'slot'),
  };
  String allergen(String key) => switch (key) {
    'soy' => soy,
    'fish' => fish,
    'gluten' => gluten,
    'milk' => milk,
    'egg' => egg,
    'peanut' => peanut,
    'nuts' => nuts,
    'shellfish' => shellfish,
    'sesame' => sesame,
    _ => throw ArgumentError.value(key, 'allergen'),
  };
  String ingredient(String name) => switch (name) {
    'Yến mạch' => oatsIngredient,
    'Chuối' => banana,
    'Sữa đậu nành không đường' => soyMilk,
    'Khoai lang' => sweetPotato,
    'Đậu nành chín' => cookedSoybeans,
    'Ổi' => guava,
    'Đậu xanh' => mungBeans,
    'Gạo lứt' => brownRice,
    'Đậu đỏ chín' => cookedRedBeans,
    'Dưa chuột' => cucumber,
    'Dầu cải' => canolaOil,
    'Cá rô phi phi lê' => tilapia,
    'Rau cải' => greens,
    'Đậu phụ' => tofuIngredient,
    'Cà chua' => tomato,
    'Cà rốt' => carrot,
    'Ức gà bỏ da' => chickenBreast,
    'Nấm' => mushrooms,
    'Trứng' => eggIngredient,
    'Bơ quả' => avocadoIngredient,
    _ => throw ArgumentError.value(name, 'ingredient'),
  };
  String mealName(Meal meal) => switch (meal.id) {
    'oats' => oatsName,
    'sweet' => sweetName,
    'beanbreakfast' => beanbreakfastName,
    'ricebreakfast' => ricebreakfastName,
    'fish' => fishName,
    'tofu' => tofuName,
    'lentil' => lentilName,
    'chicken' => chickenName,
    'beanDinner' => beanDinnerName,
    'fishDinner' => fishDinnerName,
    'tofuDinner' => tofuDinnerName,
    'chickenDinner' => chickenDinnerName,
    'tofuScramble' => tofuScrambleName,
    'eggPotato' => eggPotatoName,
    'ketoEgg' => ketoEggName,
    'ketoChicken' => ketoChickenName,
    'ketoFish' => ketoFishName,
    'ketoTofuLunch' => ketoTofuLunchName,
    'ketoTofuDinner' => ketoTofuDinnerName,
    'soySnack' => soySnackName,
    'eggSnack' => eggSnackName,
    'paleoChicken' => paleoChickenName,
    _ => throw ArgumentError.value(meal.id, 'meal'),
  };
  String mealRecipe(Meal meal) => switch (meal.id) {
    'oats' => oatsRecipe,
    'sweet' => sweetRecipe,
    'beanbreakfast' => beanbreakfastRecipe,
    'ricebreakfast' => ricebreakfastRecipe,
    'fish' => fishRecipe,
    'tofu' => tofuRecipe,
    'lentil' => lentilRecipe,
    'chicken' => chickenRecipe,
    'beanDinner' => beanDinnerRecipe,
    'fishDinner' => fishDinnerRecipe,
    'tofuDinner' => tofuDinnerRecipe,
    'chickenDinner' => chickenDinnerRecipe,
    'tofuScramble' => tofuScrambleRecipe,
    'eggPotato' => eggPotatoRecipe,
    'ketoEgg' => ketoEggRecipe,
    'ketoChicken' => ketoChickenRecipe,
    'ketoFish' => ketoFishRecipe,
    'ketoTofuLunch' => ketoTofuLunchRecipe,
    'ketoTofuDinner' => ketoTofuDinnerRecipe,
    'soySnack' => soySnackRecipe,
    'eggSnack' => eggSnackRecipe,
    'paleoChicken' => paleoChickenRecipe,
    _ => throw ArgumentError.value(meal.id, 'meal'),
  };
  List<String> get weekdays => [mon, tue, wed, thu, fri, sat, sun];
}
