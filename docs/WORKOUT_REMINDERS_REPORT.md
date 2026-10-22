# Workout reminders MVP — verification report

Date: 22 October 2026, Asia/Bangkok.

## Implemented

- Flutter Android/iOS settings under Profile; daily morning/evening times,
  editable IANA timezone, account-wide enable/disable and device registration.
- Explicit notification permission request only on Enable; current-device test
  and two demo events at +1/+3 minutes; foreground banner and notification tap
  routing to the existing workout check-in tab.
- Supabase migration with private tables/RLS, owner-only user RPCs and
  service-role-only planner/worker RPCs. No new authentication system.
- FCM HTTP v1 worker, minute-cron example, unique logical events, device fan-out,
  atomic claims/lease fencing, bounded attempts, token expiry and 10-minute TTL.
- Native manifests, Android Google Services configuration hook, iOS APNs
  entitlements; sample public app configuration and backend-only env template.
- README/setup guide with commands and the physical-device checklist.

## Executed checks

| Check | Result |
| --- | --- |
| Repository/parent `AGENTS.md` discovery | No file found in checked locations |
| `flutter pub add firebase_core firebase_messaging` | Completed; dependencies pinned and lockfile updated |
| `flutter analyze` | Passed, **No issues found** |
| `flutter test` | **143 passed, 1 skipped** |
| Focused reminder controller/widget tests after final lifecycle changes | **6 passed** |
| `deno task --config supabase/deno.json check` | Worker entry point/type checking passed |
| `deno task --config supabase/deno.json test` | **3 worker tests + database suite with 11 steps passed** |
| Migration execution | Applied to isolated PostgreSQL WASM/PGlite 0.5.10; functional queries passed |
| `git diff --check` | Passed; line-ending normalization warnings only |
| Supabase local advisors and migration history | Attempted; unavailable because local Postgres/Docker is not running |
| `flutter build apk --debug` | Passed; initial build 719.1 seconds, final incremental build 51.1 seconds |

The skipped Flutter test is the existing browser-only guest persistence test.
PGlite runs the real SQL migration and PL/pgSQL functions with a test-only Auth
schema/UID fixture. It is a single-connection PostgreSQL engine; exclusive claim
state and stale claim rejection are tested, but actual concurrent sessions and
Supabase PostgREST/JWT integration still need the development-stack test.

Database coverage: IANA/local date, previous day near midnight, DST gap/overlap,
two daily slots/two devices, repeated planner/claim, unchanged settings, changing
an unsent schedule, preserving an attempted/sent slot, disabling pending/demo
jobs, +1/+3-minute offsets, per-user test cooldown, ownership, expired FCM token,
bounded retry, lease recovery and stale-claim fencing. Provider classification
tests distinguish accepted, UNREGISTERED, permanent rejection and retry.

## Not verified with real services/devices

- No Firebase service-account/APNs credentials or native Firebase config were
  supplied. **No real remote push was sent or observed.**
- No schema, Edge Function, Vault secret or cron was deployed to a hosted
  Supabase project. Existing production/Auth data was not modified.
- FCM/APNs acceptance, Android/iPhone background display and cold-start tap
  routing require a configured build on physical devices.
- iOS compilation/signing/provisioning requires macOS/Xcode and Apple setup.
- Actual parallel PostgreSQL workers, runtime RLS through PostgREST, Supabase
  advisors and local migration history require a running development stack.
- OS notification permission, DND/battery restrictions and network availability
  affect display. An accepted provider ID is not proof of device display;
  exactly-once delivery is not guaranteed.

## Android build result

Built `build/app/outputs/flutter-apk/app-debug.apk` successfully with the existing
application ID `com.example.steady`. This debug build uses no Firebase app
credentials, so it verifies plugin/native compilation only; push remains
unavailable until the files described in the setup guide are supplied.
The final incremental build includes the latest Dart changes; its generated
kernel timestamp was checked to be newer than the reminder source files.

Gradle downloaded the Android 34 platform required by dependencies. It emitted
warnings about the Firebase Core plugin's Kotlin Gradle Plugin compatibility
with future Flutter versions, old SDK XML tooling, Java native access and
deprecated native APIs. These did not fail the current build. No Android device
installation or runtime push test was performed. No iOS build was run.

See [setup and phone checklist](workout-reminders.md). The previously delivered
release APK in `dist/` predates this feature and has not been replaced.
