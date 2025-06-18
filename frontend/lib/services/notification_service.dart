// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  // --- THIS IS THE FULLY CORRECTED PERMISSION LOGIC ---
  Future<void> requestPermissions() async {
    // 1. Request standard notification permission
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    // 2. Check and request the special "Alarms & Reminders" permission
    var status = await Permission.scheduleExactAlarm.status;
    if (status.isDenied) {
      debugPrint(
          "[Permissions] Exact Alarm permission is denied. Requesting...");
      final newStatus = await Permission.scheduleExactAlarm.request();
      debugPrint("[Permissions] New status after request: $newStatus");

      // If still denied after request, it means the user must grant it manually.
      // In a real app, you would show a dialog explaining why you need it and
      // provide a button that opens the settings.
      if (newStatus.isPermanentlyDenied || newStatus.isDenied) {
        debugPrint(
            "[Permissions] Permission permanently denied. Opening app settings.");
        // This will open the app settings page for the user.
        await openAppSettings();
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'peak_smart_channel_id',
      'PeakSmart Alerts',
      channelDescription: 'Notifications for peak hours and reminders.',
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

  // --- ADDED THIS METHOD BACK FOR THE TEST BUTTON ---
  Future<void> showTestNotification({required bool isEnabled}) async {
    // 1. Check if notifications are enabled before proceeding.
    if (!isEnabled) {
      debugPrint(
          "[DEBUG] Test notification blocked because notifications are disabled.");
      return;
    }

    // 2. If enabled, show the notification as before.
    const androidDetails = AndroidNotificationDetails(
      'peak_smart_channel_id',
      'PeakSmart Alerts',
      channelDescription: 'Notifications for peak hours and reminders.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      999, // A static ID for the test notification
      'Test Notification ⚡️',
      'You notifications are enabled! ',
      notificationDetails,
    );
    debugPrint("[DEBUG] Immediate test notification shown.");
  }

  Future<void> printPendingNotifications() async {
    final List<PendingNotificationRequest> pendingRequests =
        await _localNotifications.pendingNotificationRequests();
    if (pendingRequests.isEmpty) {
      debugPrint("[DEBUG] No pending notifications are currently scheduled.");
    } else {
      debugPrint(
          "[DEBUG] -------- START OF PENDING NOTIFICATIONS LIST --------");
      for (var p in pendingRequests) {
        debugPrint("[DEBUG] ID: ${p.id}, Title: ${p.title}, Body: ${p.body}");
      }
      debugPrint(
          "[DEBUG] --------- END OF PENDING NOTIFICATIONS LIST ---------");
    }
  }

  Future<void> schedulePeakHourAlerts(List<PeakSchedule> schedules,
      {required bool generalOn, required bool peakAlertsOn}) async {
    if (!generalOn || !peakAlertsOn) {
      await cancelAllPeakHourNotifications();
      return;
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      debugPrint(
          "[Notifications] Cannot schedule: Exact alarm permission denied.");
      return;
    }

    await cancelAllPeakHourNotifications();
    debugPrint("[Notifications] Scheduling all peak and off-peak alerts...");

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < 7; i++) {
      final dayToCheck = now.add(Duration(days: i));
      final rulesForDay = schedules.where((rule) {
        if (rule.specificDate != null) {
          return DateUtils.isSameDay(rule.specificDate, dayToCheck);
        }
        return rule.dayOfWeek == (dayToCheck.weekday % 7);
      }).toList();

      for (final rule in rulesForDay) {
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
          final startId = -int.parse(
              '${dayToCheck.month}${dayToCheck.day}${startTimeParts.join()}1');
          await _scheduleNotification(
              id: startId,
              title: title,
              body: body,
              scheduledTime: startScheduledTime);
        }

        final endTimeParts = rule.endTime.split(':');
        final endDateTime = tz.TZDateTime(
            tz.local,
            dayToCheck.year,
            dayToCheck.month,
            dayToCheck.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]));
        final endScheduledTime =
            endDateTime.subtract(const Duration(minutes: 15));

        if (endScheduledTime.isAfter(now)) {
          final title = rule.isPeak
              ? 'On-Peak Period Ending Soon'
              : 'Off-Peak Period Ending Soon';
          final body =
              'Get ready! The ${rule.isPeak ? "On-Peak" : "Off-Peak"} period will end in 15 minutes at ${rule.endTime}.';
          final endId = -int.parse(
              '${dayToCheck.month}${dayToCheck.day}${endTimeParts.join()}2');
          await _scheduleNotification(
              id: endId,
              title: title,
              body: body,
              scheduledTime: endScheduledTime);
        }
      }
    }
  }

  Future<void> scheduleNoteReminder(Note note) async {
    if (note.remindAt == null) return;
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
    }
  }

  Future<void> cancelNoteReminder(String noteId) async {
    final int notificationId = noteId.hashCode;
    await _localNotifications.cancel(notificationId);
  }

  // --- ADDED THIS METHOD BACK FOR THE LOGOUT FUNCTION ---
  Future<void> cancelAllNotifications() async {
    debugPrint("[Notifications] Cancelling ALL scheduled notifications.");
    await _localNotifications.cancelAll();
  }

  Future<void> cancelAllPeakHourNotifications() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    for (var request in pending) {
      if (request.id < 0) {
        await _localNotifications.cancel(request.id);
      }
    }
    debugPrint("[Notifications] All peak hour alerts have been cancelled.");
  }
}
