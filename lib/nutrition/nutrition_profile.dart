import '../screening/health_screening.dart';
import 'nutrition_strategy.dart';

class NutritionProfile {
  final int age;
  final double height, weight;
  final String goal, activity, cholesterol, diet;
  final int budget, minutes;
  final Set<String> exclusions;
  final String bloodPressure, lipidResults;
  final bool needsProfessionalPlan;
  final double? bodyFat;
  final BiologicalSex sex;
  final NutritionStrategy? strategy;
  final HealthScreening? health;
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
    this.bodyFat,
    this.sex = BiologicalSex.unspecified,
    this.strategy,
    this.health,
  });
  bool get supported => age >= 18 && !needsProfessionalPlan;
  NutritionProfile withStrategy(NutritionStrategy value) => NutritionProfile(
    age: age,
    height: height,
    weight: weight,
    goal: goal,
    activity: activity,
    cholesterol: cholesterol,
    diet: diet,
    budget: budget,
    minutes: minutes,
    exclusions: exclusions,
    bloodPressure: bloodPressure,
    lipidResults: lipidResults,
    needsProfessionalPlan: needsProfessionalPlan,
    bodyFat: bodyFat,
    sex: sex,
    strategy: value,
    health: health,
  );
}
