class DateUtils {
  static bool isValidDate(int year, int month, int day) {
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day;
  }

  static String formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
  }

  static DateTime parseDate(String dateStr) {
    final parsed = tryParseDate(dateStr);
    if (parsed == null) {
      throw FormatException('Invalid date: $dateStr');
    }
    return parsed;
  }

  static DateTime? tryParseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    if (!isValidDate(year, month, day)) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static String getTodayString() {
    return formatDate(DateTime.now());
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static int daysBetween(DateTime from, DateTime to) {
    final normalizedFrom = DateTime(from.year, from.month, from.day);
    final normalizedTo = DateTime(to.year, to.month, to.day);
    return normalizedTo.difference(normalizedFrom).inDays;
  }

  static List<DateTime> getDaysInMonth(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    return List<DateTime>.generate(
      lastDay.day,
      (index) => firstDay.add(Duration(days: index)),
    );
  }

  static String getWeekdayName(int weekday) {
    const names = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[weekday - 1];
  }

  static String getMonthName(int month) {
    const names = [
      '一月',
      '二月',
      '三月',
      '四月',
      '五月',
      '六月',
      '七月',
      '八月',
      '九月',
      '十月',
      '十一月',
      '十二月'
    ];
    return names[month - 1];
  }

  static String formatDateCN(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  static String formatMonthDay(DateTime date) {
    return '${date.month}月${date.day}日';
  }
}
