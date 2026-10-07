# Steady meal planner

Production sign-in collects measurements, health conditions, allergies/food
preferences and training goals, then generates a portioned seven-day menu.
See the [nutrition model, sources and limitations](nutrition-system.md).

Goals, energy strategy, macros, food pattern/source and meal timing are separate.
The local engine supports Lean bulk, Aggressive bulk, fat loss, recomposition,
Keto, low-carb, low-fat, vegetarian/vegan and three/four-meal schedules. Medical
screening and allergy filters take priority over generation and swaps.

The catalogue has 22 illustrative recipes with estimated nutrients and prices.
Portions change ingredient grams, cost and nutrition together; groceries use
actual portions. No feasible combination produces an explicit no-plan state.
The generator is deterministic, with no AI API call. The old three-step Meals
form remains for isolated component previews and legacy tests; authenticated
production users use the five-step flow.

Health profiles, plans and activity stay in memory. Supabase Auth session
persistence is unchanged; no health database write is implemented. Validated
food-composition data, professional review, secure health persistence and
adaptive weight/waist feedback remain necessary before clinical use.

```sh
flutter gen-l10n
dart format lib test tool
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --dart-define-from-file=supabase-config.json
```
