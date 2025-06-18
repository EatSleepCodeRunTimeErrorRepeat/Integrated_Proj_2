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
        AndroidInitializationSettings('@mipmap/launcher_icon');
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
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iOSPlugin = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iOSPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// --- THIS IS THE FULLY UPGRADED SCHEDULING METHOD ---
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

    debugPrint("[Notifications] Scheduling all peak and off-peak alerts...");
    await cancelAllNotifications();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Look for alerts in the next 7 days
    for (int i = 0; i < 7; i++) {
      final dayToCheck = now.add(Duration(days: i));

      final rulesForDay = schedules.where((rule) {
        if (rule.specificDate != null) {
          return DateUtils.isSameDay(rule.specificDate, dayToCheck);
        }
        final int dartWeekday =
            dayToCheck.weekday % 7; // Convert to Prisma's format (Sun=0)
        return rule.dayOfWeek == dartWeekday;
      }).toList();

      for (final rule in rulesForDay) {
        // --- Schedule alert for the START of the period ---
        final startTimeParts = rule.startTime.split(':');
        final startDateTime = tz.TZDateTime(
            tz.local,
            dayToCheck.year,
            dayToCheck.month,
            dayToCheck.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]));
        final startScheduledTime =
            startDateTime.subtract(const Duration(minutes: 15));

        if (startScheduledTime.isAfter(now)) {
          final title = rule.isPeak
              ? 'On-Peak Period Starting!'
              : 'Off-Peak Period Starting';
          final body =
              'Heads up! An ${rule.isPeak ? "On-Peak" : "Off-Peak"} period starts in 15 minutes at ${rule.startTime}.';
          // Create a unique ID for the start alert
          final startId = int.parse(
              '${dayToCheck.month}${dayToCheck.day}${startTimeParts.join()}1');

          //debugPrint("[DEBUG] Scheduling ID=$startId at $startScheduledTime");
          debugPrint("[DEBUG] Scheduling ID=$startId at $startScheduledTime");

          await _scheduleNotification(
              id: startId,
              title: title,
              body: body,
              scheduledTime: startScheduledTime);
          debugPrint(
              "[Notifications] Scheduled START alert for ${rule.startTime} on ${DateFormat('MMM d')}: $body");
        }

        // --- Schedule alert for the END of the period ---
        final endTimeParts = rule.endTime.split(':');
        final endDateTime = tz.TZDateTime(
            tz.local,
            dayToCheck.year,
            dayToCheck.month,
            dayToCheck.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]));
        final endScheduledTime =
            endDateTime.subtract(const Duration(minutes: 3));

        if (endScheduledTime.isAfter(now)) {
          final title = rule.isPeak
              ? 'On-Peak Period Ending Soon'
              : 'Off-Peak Period Ending Soon';
          final body =
              'Get ready! The ${rule.isPeak ? "On-Peak" : "Off-Peak"} period will end in 15 minutes at ${rule.endTime}.';
          // Create a unique ID for the end alert
          final endId = int.parse(
              '${dayToCheck.month}${dayToCheck.day}${endTimeParts.join()}2');

          await _scheduleNotification(
              id: endId,
              title: title,
              body: body,
              scheduledTime: endScheduledTime);
          debugPrint(
              "[Notifications] Scheduled END alert for ${rule.endTime} on ${DateFormat('MMM d')}: $body");
        }
      }
    }
  }

  // --- ADD THIS NEW METHOD FOR TESTING ---
  Future<void> scheduleTestNotification({
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    debugPrint(
        "[Notifications] Scheduling test notification for $scheduledTime");
    await _scheduleNotification(
      id: 998, // A unique ID for the test
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
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
