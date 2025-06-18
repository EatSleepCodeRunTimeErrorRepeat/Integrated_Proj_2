// lib/screens/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:frontend/providers/calendar_provider.dart';
import 'package:frontend/providers/notes_provider.dart';
import 'package:frontend/screens/tips/energy_tips_screen.dart';
import 'package:frontend/services/notification_service.dart'; // Import NotificationService
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/timezone.dart' as tz; // Import timezone package

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _lastTapTime;

  Future<void> _navigateToTipsScreen(DateTime day) async {
    final bool? didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (context) => EnergyTipsScreen(selectedDate: day)),
    );

    if (didChange == true && mounted) {
      ref.invalidate(allNotesProvider);
      ref.invalidate(notesProvider(day));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCalendar(),

          // --- IMMEDIATE TEST BUTTON ---
          ElevatedButton(
            onPressed: () async {
              final FlutterLocalNotificationsPlugin
                  flutterLocalNotificationsPlugin =
                  FlutterLocalNotificationsPlugin();
              await flutterLocalNotificationsPlugin.show(
                999,
                "🚀 Notification Test",
                "If you see this, the channel is working.",
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'peak_hour_alerts_channel',
                    'Peak Hour Alerts',
                    channelDescription:
                        'Notifications for upcoming peak electricity hours.',
                    importance: Importance.max,
                    priority: Priority.high,
                  ),
                ),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text("Test notification sent! Check system tray.")));
              }
            },
            child: const Text("Send Immediate Test Notification"),
          ),

          // --- "TIME-TRAVEL" TEST BUTTON ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              final notificationService = NotificationService();
              final tz.TZDateTime scheduledTime =
                  tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

              // This assumes you added the 'scheduleTestNotification' method to your service
              // from the previous instruction.
              await notificationService.scheduleTestNotification(
                title: "⏰ Scheduled Test",
                body: "This notification was scheduled 5 seconds ago.",
                scheduledTime: scheduledTime,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Scheduled test in 5 seconds..."),
                  duration: Duration(seconds: 4),
                ));
              }
            },
            child: const Text("Send Scheduled Test (in 5s)"),
          ),

          const Divider(height: 1, thickness: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat.yMMMMd().format(_selectedDay),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _calendarFormat = _calendarFormat == CalendarFormat.month
                          ? CalendarFormat.twoWeeks
                          : CalendarFormat.month;
                    });
                  },
                  child: Text(
                      _calendarFormat == CalendarFormat.month
                          ? 'View 2 Weeks'
                          : 'View Month',
                      style: const TextStyle(color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildScheduleList()),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final notesByDay = ref.watch(calendarEventProvider);
    final holidays = ref.watch(holidayProvider);

    return TableCalendar<Note>(
      firstDay: DateTime.utc(2024, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      availableGestures: AvailableGestures.all,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        final now = DateTime.now();
        if (_lastTapTime != null &&
            isSameDay(_selectedDay, selectedDay) &&
            now.difference(_lastTapTime!) < const Duration(milliseconds: 400)) {
          _navigateToTipsScreen(selectedDay);
        } else if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
        _lastTapTime = now;
      },
      eventLoader: (day) {
        return notesByDay[DateTime.utc(day.year, day.month, day.day)] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (holidays.any((holiday) => isSameDay(holiday, day))) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppTheme.holidayBlue.withAlpha(50),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.holidayBlue, width: 1.5),
              ),
              child: Center(
                  child: Text('${day.day}',
                      style: const TextStyle(color: Colors.black))),
            );
          }
          return null;
        },
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Positioned(
              right: 1, bottom: 1, child: _buildEventsMarker(events));
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
            color: AppTheme.primaryGreen.withAlpha(128),
            shape: BoxShape.circle),
        selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryGreen, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildEventsMarker(List<dynamic> events) {
    final notes = events.cast<Note>();
    final hasOnPeak = notes.any((note) => note.peakPeriod == 'ON_PEAK');
    final hasOffPeak = notes.any((note) => note.peakPeriod == 'OFF_PEAK');

    return Row(mainAxisSize: MainAxisSize.min, children: [
      if (hasOnPeak)
        Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.peakRed)),
      if (hasOnPeak && hasOffPeak) const SizedBox(width: 2),
      if (hasOffPeak)
        Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.offPeakGreen)),
    ]);
  }

  Widget _buildScheduleList() {
    final holidays = ref.watch(holidayProvider);
    final isHoliday =
        holidays.any((holiday) => isSameDay(holiday, _selectedDay));

    if (isHoliday) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration_outlined,
                size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 16),
            Text(
              'Public Holiday',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No peak periods today.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final notesAsync = ref.watch(notesProvider(_selectedDay));
    final schedulesAsync = ref.watch(schedulesProvider);

    if (schedulesAsync.hasError) {
      return Center(
          child: Text(
              "Error loading schedule: ${schedulesAsync.error.toString()}"));
    }

    if (schedulesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final notes = notesAsync.notes;
    final List<PeakSchedule> allSchedules = schedulesAsync.value!;

    final schedulesForDay = allSchedules.where((s) {
      if (s.specificDate != null) {
        return isSameDay(s.specificDate!, _selectedDay);
      }
      final int dartWeekday =
          _selectedDay.weekday == 7 ? 0 : _selectedDay.weekday;
      return s.dayOfWeek == dartWeekday;
    }).toList();

    final List<Map<String, dynamic>> displayItems = [];
    for (var schedule in schedulesForDay) {
      displayItems.add({
        'time': schedule.startTime,
        'title': schedule.isPeak ? 'On-Peak Period' : 'Off-Peak Period',
        'type': schedule.isPeak ? 'ON_PEAK' : 'OFF_PEAK'
      });
    }
    for (var note in notes) {
      displayItems.add({
        'time': DateFormat('HH:mm').format(note.date),
        'title': note.content,
        'type': note.peakPeriod
      });
    }

    if (displayItems.isEmpty) {
      return const Center(child: Text('No schedule or notes for this day.'));
    }

    displayItems.sort((a, b) => a['time'].compareTo(b['time']));

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: displayItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildListItem(displayItems[index]),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    final bool isPeak = item['type'] == 'ON_PEAK';
    final bool isSchedule = item['title'].toString().contains('Peak Period');

    if (isSchedule) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPeak ? AppTheme.peakRed.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
              width: 1.5),
        ),
        child: Row(
          children: [
            Text(item['time'],
                style: TextStyle(
                    color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(child: Text(item['title'])),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F0),
        borderRadius: BorderRadius.circular(8),
        border: Border(
            left: BorderSide(
                color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
                width: 5)),
      ),
      child: Row(
        children: [
          Text(item['time'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(width: 16),
          Expanded(child: Text(item['title'])),
        ],
      ),
    );
  }
}
