import 'activity_type.dart';

/// A derived snapshot of saved calendar dates, never persisted as totals.
class ActivityMetrics {
  ActivityMetrics({required DateTime today, required List<ActivityLog> logs})
    : today = DateTime.utc(today.year, today.month, today.day) {
    final todayKey = ActivityLog.dateKey(this.today);
    final startKey = ActivityLog.dateKey(days.first);
    for (final log in logs) {
      // localDate is the date saved at recording, even after timezone changes.
      if (log.localDate.compareTo(todayKey) > 0) continue;
      _recordedDates.add(log.localDate);
      if (log.localDate.compareTo(startKey) >= 0) {
        _recentDates.add(log.localDate);
        _minutes += log.minutes;
      }
      if (log.localDate == todayKey &&
          (_latestToday == null ||
              log.createdAt.compareTo(_latestToday!.createdAt) >= 0)) {
        _latestToday = log;
      }
    }
  }

  // UTC is used only for calendar arithmetic, not to convert recording dates.
  final DateTime today;
  final Set<String> _recordedDates = {};
  final Set<String> _recentDates = {};
  int _minutes = 0;
  ActivityLog? _latestToday;

  static const targetDays = 5;
  List<DateTime> get days =>
      List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));
  bool isActiveOn(DateTime day) =>
      _recordedDates.contains(ActivityLog.dateKey(day));
  bool get checkedInToday => isActiveOn(today);
  ActivityLog? get latestToday => _latestToday;
  int get activeDays => _recentDates.length;
  int get minutes => _minutes;
  bool get targetReached => activeDays >= targetDays;

  int get streak {
    var day = today;
    // Give the user all of today to continue a streak ending yesterday.
    if (!isActiveOn(day)) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (isActiveOn(day)) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }
}
