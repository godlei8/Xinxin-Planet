import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinxin_planet/core/preferences/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads default preference values when storage is empty', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = AppPreferencesRepository(prefs);

    final snapshot = repository.loadSnapshot();

    expect(snapshot.themeColorIndex, 0);
    expect(snapshot.isDarkMode, isFalse);
    expect(snapshot.dailyReminder.enabled, isFalse);
    expect(snapshot.dailyReminder.hour, 21);
    expect(snapshot.dailyReminder.minute, 0);
  });

  test('persists and reloads theme and reminder settings', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = AppPreferencesRepository(prefs);

    await repository.saveThemeColorIndex(3);
    await repository.saveIsDarkMode(true);
    await repository.saveDailyReminderSettings(
      const DailyReminderSettings(
        enabled: true,
        hour: 8,
        minute: 30,
      ),
    );

    final snapshot = repository.loadSnapshot();

    expect(snapshot.themeColorIndex, 3);
    expect(snapshot.isDarkMode, isTrue);
    expect(snapshot.dailyReminder.enabled, isTrue);
    expect(snapshot.dailyReminder.hour, 8);
    expect(snapshot.dailyReminder.minute, 30);
  });

  test('persists and reloads daily quote cache', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = AppPreferencesRepository(prefs);

    await repository.saveDailyQuoteCache(
      date: '2026-03-28',
      payload: '{"content":"hello"}',
    );

    final cache = repository.readDailyQuoteCache();

    expect(cache, isNotNull);
    expect(cache!.date, '2026-03-28');
    expect(cache.payload, '{"content":"hello"}');
  });
}
