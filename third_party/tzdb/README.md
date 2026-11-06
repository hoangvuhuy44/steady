# IANA timezone data 2026f

The supplied `tzdb-2026f.tar.lz` is retained as the reproducible source input.
Its `version` file is `2026f`, released 2026-10-27 according to `NEWS`.
SHA-256: `357829e3a16a78224d23f1ae2327704c1da1fd35f6769a7aac0682755fb9027a`.
The archive was supplied by the project owner; its signature has not been verified.
Upstream releases: <https://data.iana.org/time-zones/releases/>.
See `LICENSE` for the source's public-domain declaration and exceptions.

`lib/time/iana_data.dart` contains the generated database, including backward
aliases. Both reminder initialization and settings validation load this file;
neither loads the older data bundled with `timezone` 0.10.1. The package version
remains pinned because the generator uses its TZif parser and TZF serializer.
No network or asset-loading step is needed at app startup.

## Rebuild

From the repository root, extract the archive into `build/tzdb-source`:

```powershell
New-Item -ItemType Directory -Force build/tzdb-source
tar -xf third_party/tzdb/tzdb-2026f.tar.lz -C build/tzdb-source
```

In a Linux environment with a C compiler, make, and awk, run in the extracted
`tzdb-2026f` directory (the compiler is built from the supplied source):

```sh
make zic rearguard.zi
./zic -b fat -d ../zoneinfo rearguard.zi
```

Then from the repository root with Flutter dependencies resolved:

```sh
dart run tool/generate_timezone_data.dart build/tzdb-source/zoneinfo 2026f
dart format lib/time/iana_data.dart
flutter test test/iana_data_test.dart test/native_reminders_test.dart test/reminder_controller_test.dart
```

Use a fresh output directory for each release to avoid retaining removed zones.
The conversion follows the upstream timezone package's rearguard/fat TZif
pipeline, retains all compiled location names, and uses its normal date-range
filter. It does not add leap-second support to Dart DateTime. Generated data can
be regenerated deterministically from the archive with the pinned dependency.

This updates app-bundled rules only, not Windows/Android system tzdb. Android's
native repeating notification handling can still depend on the device's own
timezone rules; physical-device verification remains necessary. No persisted
journal dates, commitment boundaries, timezone selections, or SQLite schema are
rewritten. D03's future commitment engine is outside this data update.
