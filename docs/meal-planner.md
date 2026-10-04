# Vietnam meal planner prototype

The Meals tab extends Steady's existing Flutter app. It uses a deterministic,
local recipe catalogue, not an AI service. App localization uses the Flutter
localization SDK and intl; shared_preferences stores only the language choice.

## Run and verify

Use the Flutter SDK compatible with the existing pubspec.yaml (Dart ^3.13.4):

```bash
flutter pub get
dart format lib test tool
flutter analyze --no-pub
flutter test --no-pub
flutter run
```

The current review used Flutter 3.47.5 / Dart 3.13.4. Static analysis, unit/widget
tests and the production web build pass. See app-review.md for native platform
limitations and screenshot-based visual review.

## Onboarding and selection

Required: age, height (cm), weight (kg), goal, activity, daily VND budget,
per-recipe cooking time and diet. Optional: clinician-reported cholesterol status,
LDL/HDL/triglycerides in mmol/L, blood pressure in mmHg, allergens and dislikes.
Only enter lab values in the indicated units. Paired BP fields are validated.
The app does not diagnose or interpret readings. Those fields and activity are
collected for future professional-reviewed personalisation, not used to prescribe
energy intake. Muscle support ranks protein; other goals rank fibre. Weight loss
currently does not change portions. All plans use the same cholesterol-conscious
recipe catalogue regardless of reported diagnosis.

Under-18s and users indicating pregnancy, breastfeeding, kidney disease, eating
disorders or another therapeutic diet do not receive an automated plan.

Hard filters: allergens, disliked ingredients, vegetarian diet, time, cost.
Generation chooses three-meal combinations whose total cost fits the daily
budget, rotating dishes to reduce repetition. Empty candidate pools or no
affordable combinations produce an explicit no-plan state; no hard constraints
are relaxed. Swaps use identical filters plus the remaining daily budget and
recompute grocery totals. Oats conservatively carry a
gluten exclusion tag. Check all packaged ingredient labels and cross-contamination
risks: catalogue matching cannot guarantee allergen-free preparation.

## Data and limitations

12 illustrative recipes, fixed portions, seven days, three meals/day. Nutrition
and prices are developer estimates, not verified food-composition calculations or
live Vietnam grocery pricing. Condiments, drinks and snacks are excluded. Timing
may assume pre-cooked rice/beans; raw versus cooked bean weights are labelled.
This is a sample menu, not an energy-complete or clinical prescription. No claims
are made that a recipe meets a particular saturated-fat or fibre target.

Profiles, lab readings and plans stay in memory with explicit session consent.
Tab switching preserves the form; closing the app loses the data. Delete clears
the profile and plan. Secure persistent health storage, clinician-set targets,
portion calculations, lipid test dates, medications, and validated recipe data
must be added before clinical use or a public health-personalisation launch.
Existing activity persistence is unchanged.

## Guidance informing the catalogue

- American Heart Association: https://www.heart.org/en/health-topics/cholesterol/prevention-and-treatment-of-high-cholesterol-hyperlipidemia
  Reduce saturated/trans fats; favour vegetables, whole grains, legumes,
  unsaturated fats and lean proteins.
- NHLBI: https://www.nhlbi.nih.gov/health/blood-cholesterol/diagnosis
  Cholesterol diagnosis needs clinical assessment and blood testing; questionnaires
  cannot establish it.

## Next useful iteration

Validate recipe nutrition and local prices, then add professionally reviewed
portion/energy rules and secure consent-based storage. Do not infer clinical
restrictions from body measurements alone.
