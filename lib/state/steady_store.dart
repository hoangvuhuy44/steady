import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../models/activity_type.dart';
import '../nutrition/meal_planner.dart';
import '../nutrition/nutrition_strategy.dart';
import '../nutrition/nutrition_targets.dart';
import '../screening/health_screening.dart';

class SteadyStore extends ChangeNotifier {
  HealthScreening? healthScreening;
  ScreeningAssessment? screeningAssessment;
  bool screeningRequired = false;
  bool screeningEnforced = false;

  bool get mealPlanningAllowed =>
      !screeningEnforced ||
      (!screeningRequired && screeningAssessment?.allowsSamplePlan == true);

  void beginSession() {
    healthScreening = null;
    screeningAssessment = null;
    screeningEnforced = true;
    screeningRequired = true;
    nutritionProfile = null;
    mealPlan = [];
    _logs.clear();
    _points = 0;
    notifyListeners();
  }

  void requestScreening() {
    screeningRequired = true;
    // Old plans must not be available while health details are being revised.
    nutritionProfile = null;
    mealPlan = [];
    notifyListeners();
  }

  void completeScreening(HealthScreening profile) {
    screeningEnforced = true;
    nutritionProfile = null;
    mealPlan = [];
    healthScreening = profile;
    screeningAssessment = ScreeningRules.assess(profile);
    screeningRequired = false;
    if (profile.nutritionStrategy != null && mealPlanningAllowed) {
      setNutritionProfile(
        NutritionProfile(
          age: profile.age,
          height: profile.height,
          weight: profile.weight,
          bodyFat: profile.bodyFat,
          sex: profile.sex,
          goal: profile.nutritionStrategy!.legacyGoal,
          activity: profile.activity,
          cholesterol: 'Chưa biết',
          diet: profile.nutritionStrategy!.source == FoodSource.omnivore
              ? 'Ăn đa dạng'
              : 'Chay',
          budget: profile.budget,
          minutes: profile.cookingMinutes,
          exclusions: {...profile.allergies, ...profile.dislikes},
          strategy: profile.nutritionStrategy,
          health: profile,
        ),
      );
      return;
    }
    notifyListeners();
  }

  void declineScreening() {
    screeningEnforced = true;
    healthScreening = null;
    screeningAssessment = null;
    screeningRequired = false;
    nutritionProfile = null;
    mealPlan = [];
    notifyListeners();
  }

  NutritionProfile? nutritionProfile;
  List<List<Meal>> mealPlan = [];
  NutritionTargets? get nutritionTargets => nutritionProfile == null
      ? null
      : NutritionTargets.estimate(nutritionProfile!);
  String? get mealPlanReason => nutritionProfile == null
      ? null
      : NutritionTargets.unavailableReason(nutritionProfile!) ??
            (nutritionProfile!.strategy != null && nutritionTargets == null
                ? 'nutritionEstimateUnavailable'
                : null);
  void setNutritionProfile(NutritionProfile profile) {
    if (!mealPlanningAllowed) return;
    final screening = healthScreening;
    if (screening != null) {
      profile = NutritionProfile(
        age: screening.age,
        height: screening.height,
        weight: screening.weight,
        goal: screening.goal,
        activity: profile.activity,
        cholesterol: profile.cholesterol,
        diet: profile.diet,
        budget: profile.budget,
        minutes: profile.minutes,
        exclusions: {
          ...profile.exclusions,
          ...screening.allergies,
          ...screening.dislikes,
        },
        bloodPressure: profile.bloodPressure,
        lipidResults: profile.lipidResults,
        needsProfessionalPlan: profile.needsProfessionalPlan,
        bodyFat: screening.bodyFat,
        sex: screening.sex,
        strategy: screening.nutritionStrategy ?? profile.strategy,
        health: screening,
      );
    }
    nutritionProfile = profile;
    mealPlan = MealPlanner.generate(profile);
    notifyListeners();
  }

  bool swapMeal(int day, int slot, Meal meal) {
    final profile = nutritionProfile;
    if (!mealPlanningAllowed ||
        profile == null ||
        day < 0 ||
        day >= mealPlan.length ||
        slot < 0 ||
        slot >= mealPlan[day].length) {
      return false;
    }
    final alternatives = MealPlanner.alternatives(profile, mealPlan[day], slot);
    final matches = alternatives.where(
      (candidate) => profile.strategy == null
          ? identical(candidate, meal)
          : candidate.id == meal.id && candidate.servings == meal.servings,
    );
    if (matches.isEmpty) return false;
    mealPlan[day][slot] = matches.first;
    notifyListeners();
    return true;
  }

  void clearNutrition() {
    if (screeningEnforced) {
      declineScreening();
      return;
    }
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
