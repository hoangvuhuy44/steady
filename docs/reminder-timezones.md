# Reminder timezone selection

The reminder screen now offers a searchable list of all IDs and aliases in the
bundled IANA 2026f database. Search accepts city names with spaces, such as
`new york`, and shows the current UTC offset beside each result. This offset is
informational; scheduling still uses the IANA rules, including DST.

**Use current device timezone** reads the OS ID on Android/iOS through a
[Flutter platform channel](https://docs.flutter.dev/platform-integration/platform-channels).
It updates the draft. Users must save or enable reminders to apply it. Unknown
IDs, missing platform support, and read failures leave the existing selection
intact and show a manual-selection fallback. No location permission is needed.

This is a snapshot selection, not an automatic follow-device mode. After travel,
select the device timezone again and save. Existing saved settings and account
sync behavior are preserved. Commitment timezone changes remain governed by D03;
this reminder screen does not edit commitment periods or journal dates.

## Device QA

1. Search/select New York, Berlin, Tokyo, Kathmandu and Sydney; save and reopen.
2. Set the OS zone to one of these, tap the device button, verify the displayed
   ID, save and verify the next notification uses the selected local wall time.
3. Test notification delivery across DST, reboot and background operation.
4. Change device timezone; verify the saved selection remains until explicitly
   replaced and saved. Test denied notification permission and offline saves.

Native delivery and iOS compilation require device/macOS validation; Dart widget
tests mock the platform channel and do not substitute for those checks.
