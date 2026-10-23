# Install and test Steady on Android

This is an internal testing build. It runs on the phone without Flutter,
a development server, a computer, or a USB connection after installation.
It is not a Google Play release. The release build currently uses the local
Android debug signing key: **TEST ONLY**, not production signing.

The repository version is `1.0.0+1`, so the delivery filename is
`Steady-v1.0.0-test.apk`, not `Steady-v0.1.0-test.apk`. The application ID remains
`com.example.steady`. See [the build report](ANDROID_APK_BUILD_REPORT.md) for
the actual build result, file size, supported Android version, and verification.

## Obtain and install the APK

1. Obtain `dist/Steady-v1.0.0-test.apk` from the person who built Steady. Download
   the APK file itself; source files and a web link do not install the Android app.
2. If the file is on your computer, copy it to the phone's **Downloads** folder
   using USB file transfer, or transfer it through your usual file-sharing service.
3. On the phone, open **Files / Tệp** and tap the APK in **Downloads / Tải xuống**.
4. If Android blocks the installation, follow the prompt to **Settings / Cài đặt**
   and enable **Allow from this source / Cho phép từ nguồn này** for the browser
   or file manager you used. Android menu names vary by phone. Return to the APK.
5. Tap **Install / Cài đặt**, then **Open / Mở**. You can turn off permission to
   install unknown apps for that source afterward.
6. Check that the launcher displays the existing Steady symbol and the name
   **Steady**, and that opening the app displays Home. Disconnect USB and close
   the computer's IDE/server, then open Steady again to check standalone launch.

If installation reports an incompatible app or conflicting signature, do not
uninstall an existing Steady installation that contains journal data. Ask the
builder to check Android compatibility, application ID, and signing certificate.

## Device test checklist

Record each result as **PASS**, **FAIL**, or **NOT TESTED**. Automated unit/widget
tests do not establish that these checks passed on your phone.

1. **Guest access:** Open Steady without signing in. Confirm Home, activity
   recording, Recipes, and Profile can be opened. Cancel sign-in from Profile
   using both the on-screen button and Android Back. Check you can keep using
   guest mode.
2. **Activity journal:** Record an activity (for example, a 20-minute walk).
   Wait for the saved confirmation. Check the journal/history and Home totals.
   Record another activity and check both saved entries are present.
3. **Persistence:** Close Steady, remove it from Recent Apps, and reopen it.
   Check that the saved activities and Home totals remain. Restart the phone and
   check again. Do not clear app storage or uninstall to perform this test.
4. **Recipes / Món ăn:** Browse the existing recipe catalogue. Open a recipe and
   check its name, meal category, ingredients, quantities, and cooking steps.
5. **Filters:** Select meal categories and cooking-time limits. Then try allergy
   labels and excluded ingredients, separately and together. Check results respect
   all selections. Try a combination with no results; selections should remain
   until you change them or clear the filters. Filters match the existing recipe
   data; they do not certify allergy safety or check cross-contamination.
6. **Optional Supabase sign-in:** With internet connected, open **Profile / Hồ sơ**
   and sign in with your own confirmed Steady email/password account. A Supabase
   dashboard account is not an app account. Confirm the Profile identity changes
   and navigation works. Record an account activity, close/reopen, and check it
   remains. Sign out and check the earlier guest journal returns. Sign back in
   and check the account journal returns. These are separate local histories.
   Never send your password or session token in a test report.
7. **Social sign-in:** Google/Facebook buttons are disabled by default in this
   build. Test only if the builder explicitly enables a provider and configures
   its Supabase redirect. The Android callback remains
   `io.steady.app://login-callback/`. Do not treat disabled providers as passed.
8. **Languages:** In **Profile / Hồ sơ → Language / Ngôn ngữ**, select **English**,
   then **Tiếng Việt**, then the device-language option. Check Home, journal,
   Recipes, recipe details, filters, and Profile. Change language while filters
   are selected and check selections remain. Choose one language, close/reopen,
   and check the saved language choice remains.
9. **Without internet:** In guest mode, enable airplane mode and reopen Steady.
   Record another activity and verify it after closing/reopening. Browse recipes,
   details and filters, and switch language. These use local data/bundled assets.
   Recipe filters currently reset when the app is restarted; journal entries and
   language preference should persist.
10. **Reconnect:** Turn airplane mode off. Check login works with valid credentials.
    Authentication, registration, email confirmation, OAuth, and session refresh
    require connectivity. An existing session may be cached; offline availability
    is not proof that Supabase login or token refresh works offline. Journal data
    is local; this app does not upload it or restore it from Supabase.
11. **Phone layout:** Open the keyboard on sign-in, use Android Back, increase
    Android text size, and rotate the phone. Check controls remain reachable and
    Vietnamese characters render correctly. Research screening/planning screens
    should not appear through the Recipes flow. Preserve the existing MVP tabs;
    this build does not add features.

## Report a problem

Send the builder the phone model, Android version, APK filename/version, language,
network state, guest/account mode, steps to reproduce, expected result, and actual
result. Include a screenshot or recording with personal information hidden. For a
crash, record the approximate time and whether it happens every time.

For a developer collecting logs on a USB-debugging phone:

```sh
adb devices
adb logcat -b crash -d
```

Review logs before sharing them and remove emails, tokens, or other private data.

## Install future updates without losing your journal

- Keep the installed app. Open the new APK and choose **Update / Cập nhật**.
  Android updates require the same application ID and signing certificate, and a
  compatible version code. Future builds should increase the code above `1`.
- Do not uninstall Steady or use **Clear storage / Xóa dữ liệu**. The journal is
  SQLite data on this phone, separated by guest/account identity, with no current
  server backup/export. Signing in does not back up the journal.
- Keep the original build machine's debug keystore privately for test updates.
  Builds from another machine or a fresh CI runner usually have a different debug
  key and cannot update this APK. Do not commit or share the keystore publicly.
- If Android refuses an update, stop and ask the builder for an APK signed with
  the original certificate. After a successful update, check the guest history,
  account history, and selected language again.

## Rebuild on the same development machine

Use Flutter `3.47.5` / Dart `3.13.4`, the configured Android SDK, and the same
private test signing key. This SDK uses Android API `36`, minimum API `24`, and
NDK `28.2.13676358`; the Gradle wrapper and Android plugin versions are already
configured in the repository. From the repository root:

```sh
flutter doctor -v
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release
```

The universal APK is `build/app/outputs/flutter-apk/app-release.apk`. After a
successful build, copy it into `dist/Steady-v1.0.0-test.apk` (adjust the name when
the version changes). Do not use `--split-per-abi` for this universal test APK.
Verify file size, package metadata, and certificate before delivering an update.
Do not replace this artifact with an old APK if compilation fails.

On this Windows machine, the new `sdkmanager.bat` compatibility wrapper failed
to install the required NDK automatically. With the current Android CLI, install
the prerequisites directly using slash-separated package paths:

```powershell
$steadyAndroidSdk = "$env:LOCALAPPDATA\Android\sdk"
& "$steadyAndroidSdk\cmdline-tools\latest\bin\android.exe" --sdk $steadyAndroidSdk sdk install 'ndk/28.2.13676358'
& "$steadyAndroidSdk\cmdline-tools\latest\bin\android.exe" --sdk $steadyAndroidSdk sdk install 'platforms/android-36'
```

For an older SDK manager, the equivalent package names are `ndk;28.2.13676358`
and `platforms;android-36`. Check the installed tool's help before using either
format. Keep the SDK configured in the ignored `android/local.properties`; do
not commit machine-specific SDK paths or signing files.

For a later version, update `version:` in `pubspec.yaml`, retaining a monotonically
increasing build number, or build with explicit version arguments, for example
`flutter build apk --release --build-name=1.0.1 --build-number=2`.

Before production distribution, configure private production signing, settle the
production application ID and migration strategy, review current store/SDK
requirements, validate backend/Auth configuration, and complete device testing.
Switching the signing key or package ID cannot transparently update this test
installation; plan preservation of local data before that transition.
