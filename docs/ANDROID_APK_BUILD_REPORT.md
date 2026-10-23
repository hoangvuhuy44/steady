# Steady Android APK build report

Date: **10 October 2026 (Asia/Bangkok)**.

## Build result: SUCCESS

A real universal Android **release-mode** APK was compiled locally with
`flutter build apk --release` and copied to the delivery directory. No debug-mode
fallback was used. A GitHub Actions fallback was not needed after the local SDK
installation was repaired. No remote build or hosted download was created.

| Property | Verified value |
| --- | --- |
| Delivery location | `C:\Code\Steady\steady\dist\Steady-v1.0.0-test.apk` |
| Flutter output | `build/app/outputs/flutter-apk/app-release.apk` |
| Filename | `Steady-v1.0.0-test.apk` |
| File size | **56,910,772 bytes** (54.3 MiB) |
| Build mode / variant | Release; `android:debuggable` is `false` |
| App display name | `Steady` |
| Application ID / namespace | `com.example.steady` (preserved) |
| Version name / code | `1.0.0` / `1` (existing `pubspec.yaml` version `1.0.0+1`) |
| Minimum Android | API 24: Android 7.0 |
| Compile / target SDK | API 36 / API 36 |
| Native architectures | `armeabi-v7a`, `arm64-v8a`, `x86_64` in one APK |
| Signing | Existing Android debug certificate: **TEST ONLY** |
| Signature verification | `apksigner verify --verbose --print-certs`: successful; APK v2 signature |

The requested `v0.1.0` filename was adjusted to match the actual existing version;
the app version was not downgraded or overridden.

APK SHA-256 (also saved beside the APK as `.apk.sha256`):

```text
B6A2306354F47DBFF25B0F842ECF2DF3C71C6357D169D7033E6428EB6E8AFCE2
```

Signing certificate SHA-256:

```text
f921887ea045b52d6f5afb969e4bdbcba27656a7933bce8625a95bede11e0cec
```

The certificate subject is `C=US, O=Android, CN=Android Debug`. Release mode
describes how the app was compiled; this signing arrangement is not
production-ready. No production signing key or secret was created or committed.

## Validation

| Check executed | Result |
| --- | --- |
| Initial `git status --short` | Clean working tree |
| `flutter doctor -v` | Executed; Flutter/Android SDK detected; Android SDK-path and Windows toolchain warnings below |
| `flutter pub get` | Passed; lockfile/dependency versions unchanged |
| `flutter gen-l10n` | Passed using the existing `l10n.yaml` |
| `flutter analyze` | Passed: **No issues found** |
| `flutter test` | Passed: **137 tests passed, 1 skipped** |
| First `flutter build apk --release` | Failed during NDK installation; resolved as described below |
| Second `flutter build apk --release` | Passed; Gradle `assembleRelease`, exit code 0 (684.2 seconds) |
| APK existence / nonzero size | Passed |
| Source APK / delivery copy SHA-256 equality | Passed |
| `aapt dump badging` / Gradle output metadata | Passed: identity, version, SDK levels, app name, architectures, `release` variant |
| `apksigner verify --verbose --print-certs` | Passed |
| APK DEX inspection | Confirmed `com.example.steady.MainActivity` and `io.flutter.plugins.GeneratedPluginRegistrant` are defined in the delivered APK |
| APK manifest inspection | Confirmed not debuggable, internet permission, existing OAuth callback `io.steady.app://login-callback/` |
| APK asset inspection | Confirmed existing gradient Steady symbol, Inter/Sora fonts, and release `libapp.so` for all three architectures |
| `git diff --check` | Passed |
| Android installation / runtime smoke test | **NOT EXECUTED**; no connected Android device or configured Android virtual device was available |
| Real Supabase account login / OAuth callback | **NOT EXECUTED** on Android |

The skipped test is the existing browser-only guest-persistence test, which is
excluded from the native test run. It is not counted as passed. The executed
suite includes host SQLite file reopen/migration/identity tests, auth fixtures,
activity, recipe/filter, bilingual localization, and real-font layout tests.
These do not replace physical-device tests or a live backend login.

## Build environment and resolved issue

- Windows; Flutter stable `3.47.5`, Dart `3.13.4`.
- Android Studio's JetBrains Java runtime `25.0.3` was selected by Flutter.
  Existing Java/Kotlin compilation targets remain Java 17.
- Existing Gradle wrapper `9.3.1`, Android Gradle Plugin `9.1.0`, and declared
  Kotlin plugin `2.4.0` were retained.
- Android SDK: `C:\Users\Le Thi Thu Ha\AppData\Local\Android\sdk`.
- Installed missing NDK `28.2.13676358` and Android platform `android-36` into
  the existing SDK. Build tools `36.0.0`, `36.1.0`, and `37.0.0` were present.

The initial build failed because the new `sdkmanager.bat` compatibility wrapper
did not translate the requested NDK package correctly (`Package ndk not found`,
`Package 28.2.13676358 not found`). Installation through the Android CLI using
`ndk/28.2.13676358` and `platforms/android-36` succeeded. The release build then
completed without modifying Android build settings or application code. The
prerequisite commands are in the [testing/rebuild guide](ANDROID_APK_TESTING.md).

Remaining non-blocking diagnostics:

- Flutter doctor warns about spaces in the SDK path. The actual release build,
  including native-library processing, nevertheless completed at this path.
- Visual Studio's Windows C++ workload is absent; this does not block Android.
- Dependency resolution reports 12 newer package versions outside the current
  constraints. Dependencies were not upgraded for this task.
- SDK processing reports XML version 4 versus a parser supporting version 3.
- Java 25 emits native-access warnings from Gradle and signature verification.
  Both compilation and signature verification finished successfully.
- `apkanalyzer.bat` has an unquoted tools-directory JVM argument and initially
  failed on the SDK path's spaces. APK inspection succeeded using its underlying
  Java CLI with the tools-directory property and classpath correctly quoted.

## Files changed

- `.gitignore`: ignore `/dist/` so generated test APKs are not committed.
- `README.md`: link the Android testing guide and this report.
- `docs/ANDROID_APK_TESTING.md`: installation, feature/network/language/persistence
  checklist, problem reporting, rebuild instructions, and safe update guidance.
- `docs/ANDROID_APK_BUILD_REPORT.md`: this verification record.
- Ignored delivery files: `dist/Steady-v1.0.0-test.apk` and its SHA-256 sidecar.

No Dart code, Android IDs, manifest, launcher artwork, version, database schema,
backend, UI, or product behavior was changed. The existing public Supabase
configuration is compiled into the app; no local secret file is required.
Email/password auth remains available as configured by the backend, while social
buttons remain disabled by default. No research-only features were activated,
and no real functionality was replaced with fixtures or mock data.

## Installation and next steps

1. Copy/download the delivered APK onto an Android 7.0+ phone.
2. Open it in the phone's file manager, allow installation from that source if
   prompted, and select **Install** (or **Update** for a compatible existing app).
3. Open **Steady** and follow [the full device checklist](ANDROID_APK_TESTING.md).
   Standalone launch, journal persistence on Android, live Supabase login, and
   runtime behavior remain unverified until these checks are performed.
4. For future updates, rebuild from this repository with the same test signing
   certificate and application ID and increase the version code. Compare signing
   fingerprints before distributing an update. Keep the original test keystore
   private and backed up; do not commit it.
5. Do not uninstall or clear app storage to solve an update conflict. Local
   journals currently have no server backup, and a differently signed/package-ID
   APK cannot transparently update this installation. A new CI runner's generated
   debug key would also differ; stable CI signing would require securely supplying
   the original test keystore and credentials through GitHub Actions secrets.
6. Before production distribution, arrange production signing and an explicit
   migration/data-preservation strategy, validate backend/provider settings,
   review distribution requirements, and finish device testing. This APK is an
   internal testing artifact only.
