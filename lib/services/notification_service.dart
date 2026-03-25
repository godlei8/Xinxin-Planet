import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _nativeChannel =
      MethodChannel('xinxin_planet/native');

  static bool _initialized = false;
  static bool _androidCacheCleared = false;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    await _syncLocalTimezone();
    await _clearLegacyAndroidCacheIfNeeded();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    await _createAndroidChannels();

    _initialized = true;
  }

  static Future<bool> ensurePermissions() async {
    await initialize();
    await requestPermissions();
    return checkPermissions();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      try {
        await androidPlugin?.requestExactAlarmsPermission();
      } on PlatformException {
        // Some devices/ROMs do not expose exact alarm settings.
      }
    } else if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<bool> checkPermissions() async {
    if (Platform.isAndroid) {
      final androidPlugin =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.areNotificationsEnabled();
      return granted ?? false;
    }
    return true;
  }

  static int reminderIdForHabit(String habitId) {
    return habitId.hashCode & 0x7fffffff;
  }

  static Future<void> scheduleHabitReminder({
    required int id,
    required String habitName,
    required String time,
    required String habitId,
  }) async {
    if (!await ensurePermissions()) {
      throw Exception('\u901a\u77e5\u6743\u9650\u672a\u5f00\u542f');
    }

    final timeParts = time.split(':');
    if (timeParts.length != 2) {
      throw Exception('\u63d0\u9192\u65f6\u95f4\u683c\u5f0f\u65e0\u6548');
    }

    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    final androidDetails = AndroidNotificationDetails(
      'habit_reminders',
      '\u4e60\u60ef\u63d0\u9192',
      channelDescription: '\u4e60\u60ef\u6253\u5361\u63d0\u9192',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        '\u8bb0\u5f97\u5b8c\u6210\u4eca\u5929\u7684 "$habitName"\uff0c\u4e00\u70b9\u70b9\u575a\u6301\u4e5f\u5f88\u4e86\u4e0d\u8d77\u3002',
        contentTitle: '\u4e60\u60ef\u63d0\u9192',
        summaryText: '\u6b23\u6b23\u661f\u7403',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _scheduleWithFallback(
      id: id,
      title: '\u8be5\u6253\u5361\u5566',
      body: '\u4eca\u5929\u4e5f\u522b\u5fd8\u4e86\u5b8c\u6210 "$habitName"',
      hour: hour,
      minute: minute,
      details: NotificationDetails(android: androidDetails, iOS: iosDetails),
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habitId,
    );
  }

  static Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!await ensurePermissions()) {
      throw Exception('\u901a\u77e5\u6743\u9650\u672a\u5f00\u542f');
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      '\u6bcf\u65e5\u63d0\u9192',
      channelDescription: '\u6bcf\u65e5\u6253\u5361\u63d0\u9192',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _scheduleWithFallback(
      id: id,
      title: title,
      body: body,
      hour: hour,
      minute: minute,
      details:
          const NotificationDetails(android: androidDetails, iOS: iosDetails),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleHealthReminder({
    required int id,
    required String title,
    required String body,
    required int intervalMinutes,
  }) async {
    if (!await ensurePermissions()) {
      throw Exception('通知权限未开启');
    }

    final repeat = _repeatIntervalByMinutes(intervalMinutes);
    const androidDetails = AndroidNotificationDetails(
      'health_reminders',
      '健康提醒',
      channelDescription: '喝水、久坐、护眼等健康提醒',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _runWithAndroidCacheRecovery(() {
      return _notificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        repeat,
        const NotificationDetails(android: androidDetails, iOS: iosDetails),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    });
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'instant_notifications',
      '\u5373\u65f6\u901a\u77e5',
      channelDescription: '\u5e94\u7528\u5373\u65f6\u901a\u77e5',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails();

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  static Future<void> cancelHabitReminder(int id) async {
    await initialize();
    await _runWithAndroidCacheRecovery(() => _notificationsPlugin.cancel(id));
  }

  static Future<void> cancelHealthReminder(int id) async {
    await initialize();
    await _runWithAndroidCacheRecovery(() => _notificationsPlugin.cancel(id));
  }

  static Future<void> cancelAllReminders() async {
    await initialize();
    await _runWithAndroidCacheRecovery(_notificationsPlugin.cancelAll);
  }

  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    await initialize();
    return _notificationsPlugin.pendingNotificationRequests();
  }

  static Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) {
      return;
    }

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return;
    }

    const channels = [
      AndroidNotificationChannel(
        'habit_reminders',
        '\u4e60\u60ef\u63d0\u9192',
        description: '\u4e60\u60ef\u6253\u5361\u63d0\u9192',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'daily_reminders',
        '\u6bcf\u65e5\u63d0\u9192',
        description: '\u6bcf\u65e5\u6253\u5361\u63d0\u9192',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'health_reminders',
        '健康提醒',
        description: '喝水、久坐、护眼等健康提醒',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'instant_notifications',
        '\u5373\u65f6\u901a\u77e5',
        description: '\u5e94\u7528\u5373\u65f6\u901a\u77e5',
        importance: Importance.high,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  static Future<void> _clearLegacyAndroidCacheIfNeeded() async {
    if (!Platform.isAndroid || _androidCacheCleared) {
      return;
    }

    try {
      await _nativeChannel.invokeMethod<void>('clearNotificationCache');
    } catch (_) {
      // Ignore channel failures; plugin can still work without cache cleanup.
    }
    _androidCacheCleared = true;
  }

  static Future<void> _syncLocalTimezone() async {
    try {
      final zoneId = await _nativeChannel.invokeMethod<String>('getTimeZoneId');
      if (zoneId == null || zoneId.isEmpty) {
        return;
      }
      final location = tz.getLocation(zoneId);
      tz.setLocalLocation(location);
    } catch (_) {
      // Fallback to timezone package default when native timezone is unavailable.
    }
  }

  static Future<T> _runWithAndroidCacheRecovery<T>(
      Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (error) {
      final message = '${error.code} ${error.message} ${error.details}';
      if (!_looksLikeTypeParameterError(message)) {
        rethrow;
      }

      await _nativeChannel.invokeMethod<void>('clearNotificationCache');
      return action();
    }
  }

  static bool _looksLikeTypeParameterError(String message) {
    return message.contains('Missing type parameter') ||
        message.contains('loadScheduledNotifications') ||
        message.contains('ScheduledNotificationReceiver');
  }

  static Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationDetails details,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    final scheduledAt = _nextSchedule(hour, minute);

    Future<void> scheduleByMode(AndroidScheduleMode mode) {
      return _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledAt,
        details,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
    }

    await _runWithAndroidCacheRecovery(() async {
      try {
        await scheduleByMode(AndroidScheduleMode.exactAllowWhileIdle);
      } on PlatformException {
        if (!Platform.isAndroid) {
          rethrow;
        }
        // Fallback for devices where exact alarms are restricted by ROM.
        await scheduleByMode(AndroidScheduleMode.inexactAllowWhileIdle);
      }
    });
  }

  static tz.TZDateTime _nextSchedule(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return tz.TZDateTime.from(scheduledDate, tz.local);
  }

  static RepeatInterval _repeatIntervalByMinutes(int intervalMinutes) {
    if (intervalMinutes <= 1) {
      return RepeatInterval.everyMinute;
    }
    if (intervalMinutes <= 60) {
      return RepeatInterval.hourly;
    }
    if (intervalMinutes <= 1440) {
      return RepeatInterval.daily;
    }
    return RepeatInterval.weekly;
  }
}
