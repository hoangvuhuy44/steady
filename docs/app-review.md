# Steady review — 2026-10-04

## Completed

- English/Vietnamese translations for all five tabs, activity names, form labels,
  validation messages, dialogs, snackbars, meal names, recipes, ingredients and
  shopping lists. Built-in Material controls also use the selected locale.
- Profile language picker: device default, English or Vietnamese. Only the
  language preference is persisted. App startup restores it; unsupported device
  languages fall back to English.
- Meals onboarding split into three validated steps. Optional health readings
  are collapsible; invalid readings are revealed. Inputs accept decimal commas,
  reject non-finite/out-of-range values and enforce integer-only fields.
- Meal plan displays day selection, daily nutrition estimates, cost versus budget,
  individual recipes, compatible swaps and an interactive weekly shopping list.
- Editing loads the saved profile; cancelling restores it. Deletion requires
  confirmation and clears every nutrition input and preference to defaults.
- Daily budgets apply to the combined cost of three meals rather than a rigid
  one-third allocation. Swaps use the remaining budget for their day.
- Removed fabricated activity points and history. Points and consecutive-day
  streaks now use logged activities; a missed day breaks the streak.
- Removed inactive navigation affordances from unimplemented profile settings
  and made the reward preview status explicit.
- Fixed narrow-screen/large-text overflows in check-in, rewards and profile.
  Content width is limited on desktop; Meals fields and totals adapt to width.

## Validation

Flutter 3.47.5 / Dart 3.13.4:

- `flutter analyze --no-pub`: no issues.
- `flutter test --no-pub`: unit and widget coverage for locale restoration,
  device fallback, translating existing errors, draft preservation, all three
  onboarding steps, paired blood pressure inputs, generation, swaps, grocery
  checkboxes, cancelling edits, deleting data and empty/unsupported states.
- Budget, time, allergy and vegetarian constraints checked by planner tests;
  accepted swaps update grocery quantities and remain within the daily budget.
- All tabs exercised at 360 px width with 1.6× text in both languages.
- `flutter build web --no-pub`: production web bundle compiled successfully.
- Manual image review from Flutter-rendered phone and desktop captures in
  `docs/screenshots/`. The preview tool uses a supplied font and Material icons;
  these images are not screenshots from a physical device.

The translation pipeline follows [Flutter's localization guide](https://docs.flutter.dev/ui/internationalization).
Local preference storage uses [shared_preferences](https://pub.dev/packages/shared_preferences).

## Environment limits and remaining product scope

- No connected browser automation surface was available in this session. Visual
  review used the Flutter render engine rather than an interactive browser.
- No physical Android/iOS device was tested. The Android SDK path on this machine
  contains spaces; `flutter doctor -v` reports that this affects NDK tooling.
- Windows package setup reports that symlinks require Developer Mode. Visual
  Studio C++ tooling is also absent, so native Windows compilation remains unverified.
- iOS/macOS bundles declare both supported languages. Native Apple builds require
  macOS and were not executed here.
- Activities and nutrition remain session-only, as before. Persistent activity
  storage, reminder delivery, health-provider integration and reward redemption
  are separate features still to be implemented.
- Meal nutrition/prices are illustrative estimates with fixed portions. There
  is no clinical interpretation of health readings or personalised energy target.
