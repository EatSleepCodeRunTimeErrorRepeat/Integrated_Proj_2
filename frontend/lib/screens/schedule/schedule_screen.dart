// lib/screens/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/models/peak_schedule_model.dart';
// FIX: Hiding our custom isSameDay to resolve the conflict.
import 'package:frontend/providers/calendar_provider.dart' hide isSameDay;
import 'package:frontend/screens/tips/energy_tips_screen.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';
// This package provides the official isSameDay function we will use.
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

  void _navigateToNotesAndRefresh(DateTime date) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EnergyTipsScreen(selectedDate: date)),
    );
    // Manually refresh the provider after returning
    ref.read(allNotesProvider.notifier).fetchAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
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
                  onPressed: () => setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.week
                        : CalendarFormat.month;
                  }),
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
    final notes = ref.watch(calendarEventProvider);
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
        final now = DateTime.now();
        if (_lastTapTime != null &&
            now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
          _navigateToNotesAndRefresh(selectedDay);
        }
        _lastTapTime = now;
      },
      eventLoader: (day) {
        return notes[DateTime(day.year, day.month, day.day)] ?? [];
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() => _calendarFormat = format);
        }
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Positioned(
            right: 1,
            bottom: 1,
            // FIX: Removed unnecessary cast
            child: _buildEventsMarker(date, events),
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

  Widget _buildScheduleList() {
    final notesAsync = ref.watch(calendarProvider(_selectedDay));
    // Watch the new schedulesProvider
    final schedulesAsync = ref.watch(schedulesProvider);

    // Use .when for both providers to handle their async states
    return notesAsync.when(
      data: (notes) {
        return schedulesAsync.when(
          data: (schedules) {
            // Filter schedules for the selected day
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: displayItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        final bool isPeak = item['type']! == 'ON_PEAK';
        final color = isPeak ? AppTheme.peakRed : AppTheme.offPeakGreen;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(26), // Replaced deprecated withOpacity
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            children: [
              Text(item['time'],
                  style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Expanded(child: Text(item['title'])),
            ],
          ),
        );
      },
    );
  }
}
