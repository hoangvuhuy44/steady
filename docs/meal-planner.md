# Steady meal planner

The planner is retained research outside the MVP as of 9 October 2026. The
production tab now shows Recipes with no personalisation or nutrition totals.
Research harnesses collect measurements, health conditions, allergies/food
preferences and training goals, then generate a portioned seven-day menu.
See the [nutrition model, sources and limitations](nutrition-system.md).

Goals, energy strategy, macros, food pattern/source and meal timing are separate.
The local engine supports Lean bulk, Aggressive bulk, fat loss, recomposition,
Keto, low-carb, low-fat, vegetarian/vegan and three/four-meal schedules. Medical
screening and allergy filters take priority over generation and swaps.

The catalogue has 22 illustrative recipes with estimated nutrients and prices.
Portions change ingredient grams, cost and nutrition together; groceries use
actual portions. No feasible combination produces an explicit no-plan state.
The generator is deterministic, with no AI API call. The five-step research
flow and plan screen remain in isolated test/tool harnesses; the MVP has no
route to either flow.

Health profiles and plans stay in memory. Activities persist in local SQLite,
separately for guests and accounts. Supabase Auth session persistence is
unchanged; no health database write is implemented. Validated
food-composition data, professional review, secure health persistence and
adaptive weight/waist feedback remain necessary before clinical use.

```sh
flutter gen-l10n
dart format lib test tool
flutter analyze
flutter test
```
