# Screening research (outside the MVP)

As of 9 October 2026, the shipped Meals tab is **Recipes**. The flow below is
retained research, mounted only by test/tool harnesses through
`lib/research/research_meals_screen.dart`. Its rules remain enforced; they have
not been weakened to make the catalogue available. See [MVP scope](product-scope.md).

Implemented from the [shared Steady research](https://chatgpt.com/s/t_6ac5e1e604e0819193143ceead43579f), reviewed on 7 October 2026.

## Connect Supabase

See [the sign-in setup guide](auth-setup.md) for email, Google, Facebook, and
native/web callback configuration. The public Steady URL/key are bundled, so
plain `flutter run` works on fresh clones. For a different project, optionally
copy `supabase-config.example.json` to `supabase-config.json` and replace both
connection settings, then pass it with `--dart-define-from-file`. Never
put a service-role or secret key in the Flutter client.
The production entry point accepts modern `sb_publishable_` keys only.

```sh
flutter pub get
flutter run -d chrome --web-port=3000
```

Use the same optional override for builds if switching projects. Home and local
check-ins remain available with missing/invalid configuration or initialization
failure. Authentication is optional and opened from Profile; there is no preview
flag or authentication gate around the application.

Email/password sign-in and sign-up use real Supabase Auth APIs. When email
confirmation is enabled, sign-up shows instructions on the optional sign-in
route. The user can dismiss it and continue as a guest. Signup
passes the same web/native redirect as OAuth. Native callbacks and Google/Facebook
browser sign-in are supported as described in the setup guide; password recovery
is not implemented. Android production INTERNET permission and
macOS network-client entitlements are included.

The user selected the Steady project (`bgcczipzseddvnwpvkhz`) by supplying its
URL. Its public client key is now bundled in the tracked public configuration.
Live Auth settings confirm email/signup enabled with email confirmation;
Google/Facebook are not enabled yet. No remote schema, Auth settings, user
accounts or existing project data are changed by this patch.

## Session lifecycle

`SupabaseAuthController` detects a new authenticated session by user ID and the
JWT's `session_id`. Token refresh and repeated events for the same session do not
restart screening. A fresh sign-in or different session clears health and
nutrition state, keeps the current tab and closes old routes without opening screening. App restarts
start with unassessed nutrition state. Activity logs persist in SQLite, separately
for the device guest and each account; signing out restores guest history.
See [activity storage](activity-storage.md). The MVP has no setup/edit action
for screening. Research harnesses explicitly mount the retained Meals screen;
completing, declining or cancelling screening returns to that research screen.

Auth session credentials follow Supabase Flutter's default local persistence;
health answers are kept only in memory, never placed in auth metadata or uploaded.
There is no health-record database table or cloud write in this implementation.

## Screening and product rules

Five steps collect measurements/body fat, self-reported conditions/treatment,
allergies/food preferences, training goals, then a result and consent. See the
[nutrition system](nutrition-system.md) for estimates and generation.
The 20 groups in the research are represented with separate diabetes types and
liver subtypes. Empty selections require explicit confirmation that the user can
report the category. Unknown answers cannot silently become “no conditions”.
Optional notes collect medicines, clinician diet orders, kidney stage/dialysis
schedule and lab values with units/date/source. These notes are not parsed,
validated as clinical evidence, or used to infer disease stages or targets.
Disease diagnosis is self-reported and unverified. No BMI diagnosis is inferred.

The outcomes describe the app's scope, not clinical severity or medical clearance:

| Outcome | App behaviour |
| --- | --- |
| General lifestyle support | Adult illustrative meal templates can be created with confirmed allergy filters. Type 2 diabetes/hypertension can show general educational habits with source links. |
| More information needed | Habit tracking remains available; meal generation and swaps pause until screening is updated. |
| Professional assessment needed | Habit tracking remains available; automatic meal templates pause. Reasons explain unsupported conditions, treatment, medicine review, clinician orders or unmodelled allergies. |

The basic condition set covers uncomplicated type 2 diabetes, hypertension,
overweight/obesity, metabolic fatty liver and asthma. All treatment flags or
nonempty medicine/diet-order notes trigger review conservatively: the current
recipe catalogue cannot verify therapeutic targets or drug-food interactions.
Other conditions, under-18s, pregnancy/breastfeeding, eating disorders, dialysis,
chemotherapy, insulin, swallowing problems, poor intake, unintended weight loss
and severe/unstable disease pause automatic plans. Kidney stage/lab notes cannot
override the pause. Cancer, poor intake or unintended weight loss also explicitly
override a weight-loss goal. These are MVP product rules, not a validated clinical
screening instrument.

Refusing consent or choosing not to share details keeps general tracking available,
with meal planning paused. Meals shows the result and supports screening updates.
Updating screening clears old plans before any new answer takes effect. Cancelling
an edit leaves meal planning paused until screening is completed again.
The store enforces the decision, retains screened allergy exclusions and uses
screened measurements/goal even if a caller supplies different meal preferences.
Meals displays the resulting configuration and offers a screening-update action.
Deleting the nutrition profile also clears screening answers and pauses meal
templates until the user completes screening again.

## Sources and limitations

Rule version: `2026-10-07`. Medical sources consulted on 7 October 2026:

- [NIDDK: healthy eating with chronic kidney disease](https://www.niddk.nih.gov/health-information/kidney-disease/chronic-kidney-disease-ckd/healthy-eating-adults-chronic-kidney-disease): nutrition changes with stage and individual needs; professional review of protein, minerals and fluid.
- [NCI: nutrition during cancer treatment](https://www.cancer.gov/about-cancer/treatment/side-effects/appetite-loss/nutrition-pdq): treatment, eating difficulties and malnutrition can change nutrition priorities.
- [NIDDK: healthy living with diabetes](https://www.niddk.nih.gov/health-information/diabetes/overview/healthy-living-with-diabetes): food, drinks, portions and medication should fit an individual care plan.
- [AHA: reducing sodium](https://www.heart.org/en/healthy-living/healthy-eating/eat-smart/sodium/how-to-reduce-sodium): compare labels, reduce salty sauces, check potassium salt substitutes with a clinician.

Recipes use scaled portions and estimated nutrients. A “lifestyle” result never
certifies a meal as medically appropriate. Energy/macros are initial lifestyle
estimates, not therapeutic prescriptions. Fluid, potassium and phosphorus targets,
medicine changes and verification of clinician orders are not implemented.
Clinical personalisation, secure health persistence, validated food-composition
data and professional rule review remain future work.

## Verification

```sh
flutter gen-l10n
dart format lib test tool
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub
```

Tests cover login validation/failure, email-confirmation signup, screening consent
and refusal, account/session isolation, refresh preservation, multiple-condition
precedence, unknown data, kidney/cancer conflicts, meal safety enforcement,
allergy retention, and both languages at narrow widths with enlarged text.
Live Supabase sign-in requires the selected project's configuration and a test
account; no real user account is created by the tests.

Rendered phone previews:

- [Vietnamese sign-in](screenshots/screening-vi-sign-in.png)
- [Vietnamese condition selection](screenshots/screening-vi-conditions.png)
- [Vietnamese screening result](screenshots/screening-vi-result.png)
- [English screening result](screenshots/screening-en-result.png)

Regenerate previews with:

```sh
flutter test tool/screening_visual_review_test.dart --no-pub --dart-define=PREVIEW_FONT=C:/Windows/Fonts/arial.ttf
```

Verified on 7 October 2026: static analysis reports no issues; all 71 unit/widget
tests pass after the nutrition-flow update; production web build succeeds; the rendered preview test passes and
the Vietnamese/English phone images were inspected. The real Supabase SDK was
tested against a local HTTP auth fixture, including PKCE signup, token refresh,
session changes, sign-out and stream errors. No live Supabase login or physical
Android/iOS device run was performed. The Steady project configuration was
subsequently supplied and its live Auth service checked; no real user account
was created or used by the checks.
