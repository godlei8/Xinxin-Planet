import 'date_utils.dart' as app_date;

class StreakCalculator {
  static int calculateCurrentStreak(List<String> checkedDates) {
    final sortedDates = _normalizedDates(checkedDates);
    if (sortedDates.isEmpty) {
      return 0;
    }

    final latest = sortedDates.first;
    final latestDate = app_date.DateUtils.parseDate(latest);
    final today = DateTime.now();

    if (app_date.DateUtils.daysBetween(latestDate, today) > 1) {
      return 0;
    }

    var streak = 1;
    var cursor = latestDate;

    for (var i = 1; i < sortedDates.length; i++) {
      final candidate = app_date.DateUtils.parseDate(sortedDates[i]);
      final expected = cursor.subtract(const Duration(days: 1));
      if (app_date.DateUtils.isSameDay(candidate, expected)) {
        streak++;
        cursor = candidate;
        continue;
      }
      if (!app_date.DateUtils.isSameDay(candidate, cursor)) {
        break;
      }
    }

    return streak;
  }

  static int calculateBestStreak(List<String> checkedDates) {
    final sortedDates = _normalizedDates(checkedDates).reversed.toList();
    if (sortedDates.isEmpty) {
      return 0;
    }

    var bestStreak = 1;
    var currentStreak = 1;

    for (var i = 1; i < sortedDates.length; i++) {
      final previous = app_date.DateUtils.parseDate(sortedDates[i - 1]);
      final current = app_date.DateUtils.parseDate(sortedDates[i]);
      final diff = app_date.DateUtils.daysBetween(previous, current);

      if (diff == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else if (diff > 1) {
        currentStreak = 1;
      }
    }

    return bestStreak;
  }

  static bool isValidCheckDate(String date) {
    return app_date.DateUtils.tryParseDate(date) != null;
  }

  static List<String> _normalizedDates(List<String> checkedDates) {
    final unique = checkedDates.where(isValidCheckDate).toSet().toList();
    unique.sort((a, b) => b.compareTo(a));
    return unique;
  }
}
