import 'package:shared_preferences/shared_preferences.dart';

class AppPreferenceKeys {
  static const String themeColorIndex = 'theme_color_index';
  static const String darkMode = 'dark_mode';
  static const String dailyReminderEnabled = 'daily_reminder_enabled';
  static const String dailyReminderHour = 'daily_reminder_hour';
  static const String dailyReminderMinute = 'daily_reminder_minute';

  static const String dailyQuoteCacheDate = 'daily_quote_cache_date';
  static const String dailyQuoteCachePayload = 'daily_quote_cache_payload';
}

class DailyReminderSettings {
  const DailyReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  static const DailyReminderSettings defaults = DailyReminderSettings(
    enabled: false,
    hour: 21,
    minute: 0,
  );

  final bool enabled;
  final int hour;
  final int minute;

  DailyReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return DailyReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }
}

class AppPreferencesSnapshot {
  const AppPreferencesSnapshot({
    required this.themeColorIndex,
    required this.isDarkMode,
    required this.dailyReminder,
  });

  final int themeColorIndex;
  final bool isDarkMode;
  final DailyReminderSettings dailyReminder;
}

class AppPreferencesRepository {
  AppPreferencesRepository(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppPreferencesRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferencesRepository(prefs);
  }

  AppPreferencesSnapshot loadSnapshot() {
    return AppPreferencesSnapshot(
      themeColorIndex: themeColorIndex,
      isDarkMode: isDarkMode,
      dailyReminder: dailyReminderSettings,
    );
  }

  int get themeColorIndex =>
      _prefs.getInt(AppPreferenceKeys.themeColorIndex) ?? 0;

  bool get isDarkMode => _prefs.getBool(AppPreferenceKeys.darkMode) ?? false;

  DailyReminderSettings get dailyReminderSettings => DailyReminderSettings(
        enabled:
            _prefs.getBool(AppPreferenceKeys.dailyReminderEnabled) ?? false,
        hour: _prefs.getInt(AppPreferenceKeys.dailyReminderHour) ?? 21,
        minute: _prefs.getInt(AppPreferenceKeys.dailyReminderMinute) ?? 0,
      );

  Future<void> saveThemeColorIndex(int index) {
    return _prefs.setInt(AppPreferenceKeys.themeColorIndex, index);
  }

  Future<void> saveIsDarkMode(bool value) {
    return _prefs.setBool(AppPreferenceKeys.darkMode, value);
  }

  Future<void> saveDailyReminderSettings(DailyReminderSettings settings) async {
    await _prefs.setBool(
      AppPreferenceKeys.dailyReminderEnabled,
      settings.enabled,
    );
    await _prefs.setInt(
      AppPreferenceKeys.dailyReminderHour,
      settings.hour,
    );
    await _prefs.setInt(
      AppPreferenceKeys.dailyReminderMinute,
      settings.minute,
    );
  }

  Future<void> clear() {
    return _prefs.clear();
  }
}
