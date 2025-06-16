// lib/screens/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:frontend/providers/calendar_provider.dart' hide isSameDay;
import 'package:frontend/screens/tips/energy_tips_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:frontend/widgets/top_navbar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  /// Navigates to the EnergyTipsScreen for the selected date on double-tap.
  void _navigateToNotesAndRefresh(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EnergyTipsScreen(selectedDate: date)),
    );
    // Manually refresh the provider after returning
    ref.read(allNotesProvider.notifier).fetchAllNotes();
  }

  // The _showAddNoteDialog method has been removed as it was only used by the FloatingActionButton.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      // FIX: Removed the FloatingActionButton as requested.
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1, thickness: 1),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_selectedDay),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _calendarFormat = _calendarFormat == CalendarFormat.month
                          ? CalendarFormat.week
                          : CalendarFormat.month;
                    });
                  },
                  child: Text(_calendarFormat == CalendarFormat.month
                      ? 'View Week'
                      : 'View Month'),
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
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
        // This is the restored double-tap logic
        final now = DateTime.now();
        if (_lastTapTime != null &&
            now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
          _navigateToNotesAndRefresh(selectedDay);
        }
        _lastTapTime = now;
      },
      eventLoader: (day) {
        return notesByDay[DateTime(day.year, day.month, day.day)] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          if (holidays.any((holiday) => isSameDay(holiday, day))) {
            return Container(
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppTheme.holidayBlue.withAlpha(77),
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
            right: 1,
            bottom: 1,
            child: _buildEventsMarker(date, events.cast<Note>()),
          );
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppTheme.primaryGreen.withAlpha(128),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppTheme.primaryGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    final notesAsync = ref.watch(calendarProvider(_selectedDay));
    final schedulesAsync = ref.watch(schedulesProvider);
    final holidays = ref.watch(holidayProvider);

    if (holidays.any((holiday) => isSameDay(_selectedDay, holiday))) {
      return const Center(
        child: Text(
          'No Peak Period Today (Holiday)',
          style: TextStyle(
              fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return notesAsync.when(
      data: (notes) {
        return schedulesAsync.when(
          data: (schedules) {
            final daySchedule = schedules.where((s) {
              if (s.specificDate != null) {
                return isSameDay(s.specificDate!, _selectedDay);
              }
              return s.dayOfWeek == _selectedDay.weekday;
            }).toList();
            return _buildCombinedList(daySchedule, notes);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) =>
              Center(child: Text("Error loading schedules: ${e.toString()}")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) =>
          Center(child: Text("Error loading notes: ${e.toString()}")),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    final bool isPeak = item['type']! == 'ON_PEAK';
    final bool isSchedule = item['title'].toString().contains('Peak Period');

    if (isSchedule) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPeak ? AppTheme.peakRed.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen,
            width: 1.5,
          ),
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
        color: Colors.grey.shade100,
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

  Widget _buildCombinedList(List<PeakSchedule> schedules, List<Note> notes) {
    final List<Map<String, dynamic>> displayItems = [];
    for (var schedule in schedules) {
      displayItems.add({
        'time': '${schedule.startTime} - ${schedule.endTime}',
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
      itemBuilder: (context, index) {
        final item = displayItems[index];
        return _buildListItem(item);
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List<Note> notes) {
    final hasOnPeak = notes.any((note) => note.peakPeriod == 'ON_PEAK');
    final hasOffPeak = notes.any((note) => note.peakPeriod == 'OFF_PEAK');

    if (hasOnPeak && hasOffPeak) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.peakRed)),
        const SizedBox(width: 1),
        Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.offPeakGreen)),
      ]);
    } else if (hasOnPeak) {
      return Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppTheme.peakRed));
    } else {
      return Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
              shape: BoxShape.circle, color: AppTheme.offPeakGreen));
    }
  }
}
