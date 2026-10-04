import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../models/activity_type.dart';
import '../nutrition/meal_planner.dart';

class SteadyStore extends ChangeNotifier {
  NutritionProfile? nutritionProfile;
  List<List<Meal>> mealPlan = [];
  void setNutritionProfile(NutritionProfile profile) {
    nutritionProfile = profile;
    mealPlan = MealPlanner.generate(profile);
    notifyListeners();
  }

  bool swapMeal(int day, int slot, Meal meal) {
    final profile = nutritionProfile;
    if (profile == null ||
        day < 0 ||
        day >= mealPlan.length ||
        slot < 0 ||
        slot >= mealPlan[day].length) {
      return false;
    }
    if (!MealPlanner.alternatives(
      profile,
      mealPlan[day],
      slot,
    ).contains(meal)) {
      return false;
    }
    mealPlan[day][slot] = meal;
    notifyListeners();
    return true;
  }

  void clearNutrition() {
    nutritionProfile = null;
    mealPlan = [];
    notifyListeners();
  }

  SteadyStore({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final List<ActivityLog> _logs = [];
  int _points = 0;

  List<ActivityLog> get logs => List.unmodifiable(_logs);
  int get points => _points;
  int get streak {
    var day = DateUtils.dateOnly(_now());
    final dates = _logs.map((log) => DateUtils.dateOnly(log.createdAt)).toSet();
    if (!dates.contains(day)) day = DateTime(day.year, day.month, day.day - 1);
    var count = 0;
    while (dates.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  bool get checkedInToday {
    final now = _now();
    return _logs.any(
      (log) =>
          log.createdAt.year == now.year &&
          log.createdAt.month == now.month &&
          log.createdAt.day == now.day,
    );
  }

  ActivityLog? get latestLog => _logs.isEmpty ? null : _logs.last;

  void logActivity(ActivityType type, int minutes) {
    final wasCheckedIn = checkedInToday;

    _logs.add(ActivityLog(type: type, minutes: minutes, createdAt: _now()));

    if (!wasCheckedIn) {
      _points += 20;
    } else {
      _points += 5;
    }

    notifyListeners();
  }
}
