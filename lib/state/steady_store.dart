import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/activity_repository.dart';
import '../models/activity_metrics.dart';
import '../models/activity_type.dart';
import '../nutrition/meal_planner.dart';
import '../nutrition/nutrition_strategy.dart';
import '../nutrition/nutrition_targets.dart';
import '../screening/health_screening.dart';

class SteadyStore extends ChangeNotifier {
  HealthScreening? healthScreening;
  ScreeningAssessment? screeningAssessment;
  bool screeningRequired = true;
  bool screeningEnforced = true;

  bool get mealPlanningAllowed =>
      !screeningRequired && screeningAssessment?.allowsSamplePlan == true;

  void beginSession() {
    healthScreening = null;
    screeningAssessment = null;
    screeningEnforced = true;
    screeningRequired = true;
    nutritionProfile = null;
    mealPlan = [];
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

  SteadyStore({
    DateTime Function()? now,
    ActivityRepository? activityRepository,
  }) : _now = now ?? DateTime.now,
       _repository = activityRepository ?? createActivityRepository(),
       _ownsRepository = activityRepository == null;
  final DateTime Function() _now;
  final ActivityRepository _repository;
  final bool _ownsRepository;
  final List<ActivityLog> _logs = [];
  String? _activityOwnerId;
  int _activityRevision = 0;
  bool activityLoading = false;
  bool activitySaving = false;
  bool _activityLoaded = false;
  Object? activityLoadError;
  Object? activitySaveError;
  Future<void> _pendingWrite = Future.value();

  int _identityRevision = 0;
  bool _usingGuest = false;

  /// Authentication selects a local partition; it never merges or deletes logs.
  Future<void> setActivityUser(String? userId) async {
    final identityRevision = ++_identityRevision;
    _usingGuest = userId == null;
    if (userId != null) {
      await setActivityOwner(userId);
      return;
    }
    await setActivityOwner(null);
    if (identityRevision != _identityRevision) return;
    activityLoading = true;
    activityLoadError = null;
    notifyListeners();
    try {
      final owner = await _repository.guestOwnerId();
      if (identityRevision != _identityRevision) return;
      activityLoading = false;
      await setActivityOwner(owner);
    } catch (error) {
      if (identityRevision != _identityRevision) return;
      activityLoading = false;
      activityLoadError = error;
      notifyListeners();
    }
  }

  String? get activityOwnerId => _activityOwnerId;
  bool get canLogActivity =>
      _activityOwnerId != null &&
      _activityLoaded &&
      !activityLoading &&
      !activitySaving &&
      activityLoadError == null;

  Future<void> setActivityOwner(String? ownerId) async {
    if (_activityOwnerId == ownerId) return;
    _activityRevision++;
    _activityOwnerId = ownerId;
    _logs.clear();
    _activityLoaded = false;
    activityLoading = false;
    activitySaving = false;
    activityLoadError = null;
    activitySaveError = null;
    if (ownerId == null) {
      notifyListeners();
    } else {
      await reloadActivities();
    }
  }

  Future<void> reloadActivities() async {
    final owner = _activityOwnerId;
    if (activityLoading || activitySaving) return;
    if (owner == null) {
      if (_usingGuest) await setActivityUser(null);
      return;
    }
    final revision = _activityRevision;
    activityLoading = true;
    activityLoadError = null;
    notifyListeners();
    try {
      // A rapid sign-out/sign-in must read after the old write commits.
      await _pendingWrite;
      if (revision != _activityRevision) return;
      final logs = await _repository.load(owner);
      if (revision != _activityRevision) return;
      _logs
        ..clear()
        ..addAll(logs.where((log) => log.ownerId == owner));
      _activityLoaded = true;
    } catch (error) {
      if (revision != _activityRevision) return;
      activityLoadError = error;
      // Retain the last successful history on read failure.
    } finally {
      if (revision == _activityRevision) {
        activityLoading = false;
        notifyListeners();
      }
    }
  }

  List<ActivityLog> get logs => List.unmodifiable(_logs);
  int get points =>
      _logs.length * 5 + _logs.map((log) => log.localDate).toSet().length * 15;
  ActivityMetrics get activityMetrics =>
      ActivityMetrics(today: _now().toLocal(), logs: _logs);
  int get streak => activityMetrics.streak;
  bool get checkedInToday => activityMetrics.checkedInToday;

  /// The app uses this same clock to schedule its next calendar refresh.
  Duration get timeUntilNextDay {
    final now = _now().toLocal();
    return DateTime(now.year, now.month, now.day + 1).difference(now);
  }

  void refreshActivityDate() => notifyListeners();

  ActivityLog? get latestLog => _logs.isEmpty ? null : _logs.last;

  /// Returns awarded points only after commit, or null on failure/stale session.
  Future<int?> logActivity(ActivityType type, int minutes) async {
    if (!canLogActivity) return null;
    if (minutes <= 0) throw ArgumentError.value(minutes, 'minutes');
    final revision = _activityRevision;
    final recordedAt = _now().toLocal();
    final log = ActivityLog(
      id: const Uuid().v4(),
      ownerId: _activityOwnerId!,
      type: type,
      minutes: minutes,
      createdAt: recordedAt.toUtc(),
      localDate: ActivityLog.dateKey(recordedAt),
    );
    final earned = _logs.any((old) => old.localDate == log.localDate) ? 5 : 20;
    activitySaving = true;
    activitySaveError = null;
    final completed = Completer<void>();
    _pendingWrite = completed.future;
    notifyListeners();
    try {
      await _repository.insert(log);
      if (revision != _activityRevision) return null;
      _logs.add(log);
      return earned;
    } catch (error) {
      if (revision == _activityRevision) activitySaveError = error;
      return null;
    } finally {
      completed.complete();
      if (revision == _activityRevision) {
        activitySaving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _activityRevision++;
    _identityRevision++;
    if (_ownsRepository) {
      unawaited(_pendingWrite.then((_) => _repository.close()));
    }
    super.dispose();
  }
}
