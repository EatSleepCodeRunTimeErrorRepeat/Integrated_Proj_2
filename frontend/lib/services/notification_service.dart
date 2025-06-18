// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart'; // <-- THIS IMPORT WAS MISSING

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
    //TEST BUTTON
    Future<void> showTestNotification() async {
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
      'If you can see this, your app can display notifications!',
      notificationDetails,
    );
    debugPrint("[DEBUG] Immediate test notification shown.");
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
  
  Future<void> printPendingNotifications() async {
    final List<PendingNotificationRequest> pendingRequests =
        await _localNotifications.pendingNotificationRequests();
    if (pendingRequests.isEmpty) {
      debugPrint("[DEBUG] No pending notifications are currently scheduled.");
    } else {
      debugPrint("[DEBUG] -------- START OF PENDING NOTIFICATIONS LIST --------");
      for (var p in pendingRequests) {
        debugPrint("[DEBUG] ID: ${p.id}, Title: ${p.title}, Body: ${p.body}");
      }
      debugPrint("[DEBUG] --------- END OF PENDING NOTIFICATIONS LIST ---------");
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
    int scheduledCount = 0;

    for (int i = 0; i < 7; i++) {
      final dayToCheck = now.add(Duration(days: i));
      final rulesForDay = schedules.where((rule) {
        if (rule.specificDate != null) {
          return DateUtils.isSameDay(rule.specificDate, dayToCheck);
        }
        return rule.dayOfWeek == (dayToCheck.weekday % 7);
      }).toList();

      if (rulesForDay.isNotEmpty) {
        debugPrint("[DEBUG] Found ${rulesForDay.length} rules for ${DateFormat('MMM d').format(dayToCheck)}");
      }

      for (final rule in rulesForDay) {
        // --- Schedule alert for the START of the period ---
        final startTimeParts = rule.startTime.split(':');
        final startDateTime = tz.TZDateTime(tz.local, dayToCheck.year, dayToCheck.month, dayToCheck.day, int.parse(startTimeParts[0]), int.parse(startTimeParts[1]));
        final startScheduledTime = startDateTime.subtract(const Duration(minutes: 15));
        
        if (startScheduledTime.isAfter(now)) {
          scheduledCount++;
          final title = rule.isPeak ? 'On-Peak Period Starting!' : 'Off-Peak Period Starting';
          final body = 'Heads up! An ${rule.isPeak ? "On-Peak" : "Off-Peak"} period starts in 15 minutes at ${rule.startTime}.';
          final startId = int.parse('${dayToCheck.month}${dayToCheck.day}${startTimeParts.join()}1');
          await _scheduleNotification(id: startId, title: title, body: body, scheduledTime: startScheduledTime);
        }

        // --- Schedule alert for the END of the period ---
        final endTimeParts = rule.endTime.split(':');
        final endDateTime = tz.TZDateTime(tz.local, dayToCheck.year, dayToCheck.month, dayToCheck.day, int.parse(endTimeParts[0]), int.parse(endTimeParts[1]));
        final endScheduledTime = endDateTime.subtract(const Duration(minutes: 15));

        if (endScheduledTime.isAfter(now)) {
           scheduledCount++;
           final title = rule.isPeak ? 'On-Peak Period Ending Soon' : 'Off-Peak Period Ending Soon';
           final body = 'Get ready! The ${rule.isPeak ? "On-Peak" : "Off-Peak"} period will end in 15 minutes at ${rule.endTime}.';
           final endId = int.parse('${dayToCheck.month}${dayToCheck.day}${endTimeParts.join()}2');
           await _scheduleNotification(id: endId, title: title, body: body, scheduledTime: endScheduledTime);
        }
      }
    }
    debugPrint("[DEBUG] Finished scheduling. Total alerts scheduled: $scheduledCount");
  }

  Future<void> scheduleNoteReminder(Note note) async {
    debugPrint("[DEBUG] Received request to schedule reminder for note: '${note.content}'");
    if (note.remindAt == null) {
      debugPrint("[DEBUG] Note has no reminder time. Skipping.");
      return;
    }

    if (await Permission.scheduleExactAlarm.isDenied) {
      debugPrint("[DEBUG] Cannot schedule reminder: Exact alarm permission denied.");
      return;
    }

    final int notificationId = note.id.hashCode;
    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(note.remindAt!, tz.local);

    if (scheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
      await _scheduleNotification(
        id: notificationId,
        title: 'Note Reminder',
        body: note.content,
        scheduledTime: scheduledTime,
      );
      debugPrint("[DEBUG] SUCCESS: OS has accepted note reminder with ID: $notificationId for time: $scheduledTime");
    } else {
      debugPrint("[DEBUG] Did not schedule reminder because the time is in the past.");
    }
  }

  Future<void> cancelNoteReminder(String noteId) async {
    final int notificationId = noteId.hashCode;
    await _localNotifications.cancel(notificationId);
    debugPrint("[Notifications] Canceled reminder for note ID: $noteId");
  }

  Future<void> cancelAllNotifications() async {
    debugPrint("[Notifications] Cancelling ALL scheduled notifications.");
    await _localNotifications.cancelAll();
  }

  // A specific function to cancel only system alerts, leaving note reminders intact.
  Future<void> cancelAllPeakHourNotifications() async {
    final pending = await _localNotifications.pendingNotificationRequests();
    for (var request in pending) {
      if (request.id.toString().length > 6) { // Heuristic: Peak hour IDs are long numbers
        await _localNotifications.cancel(request.id);
      }
    }
    debugPrint("[Notifications] All peak hour alerts have been cancelled.");
  }
}