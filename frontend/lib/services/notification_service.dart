// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Bangkok'));

    await _localNotifications.initialize(settings);
    await requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Standard notification permission
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iOSPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iOSPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    // Exact alarm permission
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  Future<void> schedulePeakHourAlerts(List<PeakSchedule> schedules,
      {required bool generalOn, required bool peakAlertsOn}) async {
    if (!generalOn || !peakAlertsOn) {
      debugPrint(
          "[Notifications] Peak alerts disabled by user preference. Cancelling all.");
      await cancelAllNotifications();
      return;
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      debugPrint(
          "[Notifications] Cannot schedule alerts because exact alarm permission is denied.");
      return;
    }

    debugPrint("[Notifications] Scheduling peak hour alerts...");
    await cancelAllNotifications();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int notificationId = 0;

    for (int i = 0; i < 7; i++) {
      final dayToCheck = now.add(Duration(days: i));

      final rulesForDay = schedules.where((rule) {
        if (rule.specificDate != null) {
          return DateUtils.isSameDay(rule.specificDate, dayToCheck);
        }
        final int dartWeekday = dayToCheck.weekday % 7;
        return rule.dayOfWeek == dartWeekday;
      }).toList();

      for (final rule in rulesForDay) {
        if (rule.isPeak) {
          final timeParts = rule.startTime.split(':');
          final peakHour = int.parse(timeParts[0]);
          final peakMinute = int.parse(timeParts[1]);

          final peakTime = tz.TZDateTime(tz.local, dayToCheck.year,
              dayToCheck.month, dayToCheck.day, peakHour, peakMinute);
          final scheduledTime = peakTime.subtract(const Duration(minutes: 15));

          if (scheduledTime.isAfter(now)) {
            await _scheduleNotification(
              id: notificationId++,
              title: 'Peak Hour Alert ⚡️',
              body:
                  'Heads up! A peak period starts in 15 minutes at ${rule.startTime}.',
              scheduledTime: scheduledTime,
            );
            debugPrint(
                "[Notifications] Scheduled peak alert for ${DateFormat('MMM d, HH:mm').format(scheduledTime)}");
          }
        }
      }
    }
  }

  Future<void> scheduleNoteReminder(Note note,
      {required bool isEnabled}) async {
    if (!isEnabled || note.remindAt == null) return;
    if (await Permission.scheduleExactAlarm.isDenied) return;

    final int notificationId = note.id.hashCode;
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(note.remindAt!, tz.local);

    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await _scheduleNotification(
        id: notificationId,
        title: 'Note Reminder',
        body: note.content,
        scheduledTime: scheduledTime,
      );
      debugPrint(
          "[Notifications] Scheduled reminder for note '${note.content}' at $scheduledTime");
    }
  }

  Future<void> cancelNoteReminder(String noteId) async {
    final int notificationId = noteId.hashCode;
    await _localNotifications.cancel(notificationId);
    debugPrint("[Notifications] Canceled reminder for note ID: $noteId");
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'peak_hour_alerts_channel',
      'Peak Hour Alerts',
      channelDescription: 'Notifications for upcoming peak electricity hours.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    debugPrint("[Notifications] Cancelling all scheduled notifications.");
    await _localNotifications.cancelAll();
  }
}
