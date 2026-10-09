# Activity storage

Android and iOS use `sqflite` with a versioned `steady_activities.db` in the
platform database directory. `ActivityRepository` is injectable for tests.
There is no in-memory fallback that reports a successful save.

Each row contains a UUID, owner ID, enum **name** (not ordinal), minutes,
UTC timestamp (ISO 8601; legacy Unix microseconds are also read), and the local calendar date (`YYYY-MM-DD`) captured when
the user saves. The owner/time index supports account-scoped history queries.
Stored dates remain unchanged if the user later changes timezone.

Schema v2 adds `device_identity`. A transactional lookup creates one stable
`guest:<UUID>` owner for this installation and reuses it after app restarts.
Existing v1 account rows are preserved by migration. Account owners retain their
Supabase user IDs. Guests and accounts use distinct query partitions; there is
no guest-to-account history merge and no server backup or synchronization.

`SteadyApp` binds restored and changed identities to `SteadyStore` without an
authentication gate. It opens Home immediately. Signing out loads the device's
guest history without deleting any database rows. `beginSession`
only resets screening and its existing nutrition state. Points and streak are
derived from saved rows: 20 points for the first activity on a local date,
5 for each additional activity. A streak may end today or yesterday.

Home derives today's recording status, unique active days, and total activity
minutes from the current owner's logs. The rolling window is today and the six
preceding calendar dates, inclusive. All durations count, while multiple rows
on one date contribute only one active day. Older and future-dated rows are
excluded from these window metrics. No aggregate totals are stored.

The saved `local_date` is authoritative for Home, the calendar and streak;
`created_at_utc` never changes a log's calendar date. UTC calendar arithmetic
handles month/year boundaries without daylight-saving gaps. The calendar takes
the same derived snapshot as Home instead of reading its own wall clock.
The app schedules a refresh at local midnight using the store's injected clock,
refreshes and reschedules on resume, and cancels the timer on pause/disposal.

Streak counts consecutive active dates, extending beyond the rolling window.
If today has no record, yesterday's streak remains through the end of today;
missing an entire date resets the streak. The shared Home/Profile goal is at
least five active dates in the last seven, independent of streak. Home places
this goal and activity metrics above the secondary streak explanation. Points
and Rewards retain their existing calculation. Today's card only shows a row
saved for today, and committed-save notifications show activity and minutes.

Loading and saving cannot overlap in the current session. The store rejects
duplicate pending saves, preserves history on read errors, and ignores results
from an earlier account revision. Loads wait for pending writes, including
when the same account signs out and immediately returns. Success notifications
and navigation happen only after a committed write for the current account.
Read errors offer retry; write errors keep the form available for another save.

Automated coverage is in `activity_repository_test.dart`, `steady_store_test.dart`,
`check_in_widget_test.dart`, `auth_activity_widget_test.dart`,
`auth_screening_widget_test.dart`, `widget_test.dart`,
`activity_metrics_test.dart`, and `home_activity_widget_test.dart`. Database tests
use real SQLite through FFI on the test host, including file close/reopen,
guest identity persistence, v1 migration and guest/account isolation.
The dev-only FFI/SQLite3 versions avoid a native-assets failure with SDK paths
containing spaces on Windows.

Validated on 9 October 2026: `flutter gen-l10n` succeeds, `flutter analyze`
reports no issues and all 125 tests pass (including Recipes MVP coverage). Coverage includes repeated activities,
inclusive window boundaries, month/year/leap-year transitions, future dates,
saved dates differing from recording instants, yesterday's streak, missed dates,
a reached 5/7 goal with streak zero, history restoration, midnight and resume.
Authentication transitions and initialization failure use test
controllers/fixtures; database persistence and migration use real host SQLite.
No physical Android/iOS run or live account login was performed for this change.

## Device verification still required

- Android and iOS: launch into Home as a guest, save several activities,
  terminate the app completely, reopen, and verify history-derived metrics.
- Open sign-in from Profile; cancel with the button and system back. Verify
  Home/check-ins also work with missing configuration and initialization failure.
- Switch between two real Supabase accounts, sign out, and sign back in; check
  that each account and the guest see only their own activities. Repeat after
  terminating the app, including while a write is pending.
- Enter Meals without automatic navigation. Only its setup button opens health
  and nutrition screening. Cancel back to Meals and use the Home tab. Complete
  screening to return to Meals; check that unassessed/ineligible cases cannot
  create or swap plans. Signing in must return to Home without screening.
- Verify saving/loading UI on device, including a storage write failure and retry.
- Check recording around local midnight and after changing the device timezone.

Browser and Windows production SQLite backends are outside this change. If the
native plugin is unavailable, the load error is shown and saving stays disabled.
