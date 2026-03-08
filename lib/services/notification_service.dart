import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Check if notifications are supported (Not supported on Web)
  static bool get _isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Initialize notification service
  static Future<void> init() async {
    if (!_isSupported) return;

    // Initialize timezone database
    tz.initializeTimeZones();

    // Force Asia/Kolkata timezone (IST)
    final kolkata = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(kolkata);

    // Android initialization
    const androidInit =
        AndroidInitializationSettings('mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidInit,
    );

    await _notifications.initialize(settings:settings);

    // Request notification permission (Android 13+)
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 🔔 Instant Notification (For ESP32 Logs: taken/missed)
  /// Automatically generates unique ID
  static Future<void> show({
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;

    // Generate unique ID to avoid overwrite
    final int id =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_channel',
        'Medicine Logs',
        channelDescription: 'Medicine taken or missed logs',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      id:id,
      title:title,
      body:body,
      notificationDetails:notificationDetails,
    );
  }

  /// Schedule Daily Notification (UNCHANGED)
  static Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_isSupported) return;

    final location = tz.local;
    final now = tz.TZDateTime.now(location);

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_channel',
        'Medicine Reminder',
        channelDescription: 'Daily medicine reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel specific notification
  static Future<void> cancel(int id) async {
  if (!_isSupported) return;
  await _notifications.cancel(id: id);
}

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    if (!_isSupported) return;
    await _notifications.cancelAll();
  }
}