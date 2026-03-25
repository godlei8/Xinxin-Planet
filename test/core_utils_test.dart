import 'package:flutter_test/flutter_test.dart';
import 'package:xinxin_planet/core/utils/date_utils.dart' as app_date;
import 'package:xinxin_planet/core/utils/streak_calculator.dart';

void main() {
  group('DateUtils.isValidDate', () {
    test('accepts real calendar dates', () {
      expect(app_date.DateUtils.isValidDate(2024, 2, 29), isTrue);
      expect(app_date.DateUtils.isValidDate(2026, 3, 24), isTrue);
    });

    test('rejects overflowed dates', () {
      expect(app_date.DateUtils.isValidDate(2025, 2, 29), isFalse);
      expect(app_date.DateUtils.isValidDate(2026, 2, 30), isFalse);
      expect(app_date.DateUtils.isValidDate(2026, 13, 1), isFalse);
    });
  });

  group('StreakCalculator', () {
    test('counts best streak with duplicate dates ignored', () {
      final dates = [
        '2026-03-01',
        '2026-03-02',
        '2026-03-02',
        '2026-03-03',
        '2026-03-05',
      ];

      expect(StreakCalculator.calculateBestStreak(dates), 3);
    });

    test('returns 0 current streak when latest date is older than yesterday',
        () {
      final dates = ['2020-01-01', '2020-01-02', '2020-01-03'];

      expect(StreakCalculator.calculateCurrentStreak(dates), 0);
    });
  });
}
