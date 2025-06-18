// lib/providers/calendar_provider.dart

import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/models/peak_schedule_model.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/services/notification_service.dart';

// --- Main Providers for the Schedule Screen ---

final schedulesProvider = FutureProvider.autoDispose<List<PeakSchedule>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user?.provider == null) return [];

  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getSchedules(user!.provider!);

  if (response.statusCode == 200) {
    final schedules = (jsonDecode(response.body) as List)
        .map((data) => PeakSchedule.fromJson(data))
        .toList();

    // --- THIS LOGIC IS NOW CORRECTED ---
    final authState = ref.read(authProvider);
    final bool generalOn = authState.user?.notificationsEnabled ?? true;
    final bool peakAlertsOn = authState.user?.peakHourAlertsEnabled ?? true;

    // We no longer await this. We kick it off and let it run in the background.
    NotificationService().schedulePeakHourAlerts(schedules,
        generalOn: generalOn, peakAlertsOn: peakAlertsOn);

    return schedules;
  } else {
    throw Exception('Failed to load schedules');
  }
});

// --- THIS PROVIDER IS RESTORED ---
// It watches the main schedulesProvider and extracts a simple list of holiday dates.
final holidayProvider = Provider.autoDispose<List<DateTime>>((ref) {
  final schedulesAsync = ref.watch(schedulesProvider);
  return schedulesAsync.when(
    data: (schedules) {
      // A holiday is a schedule for a specific date that is not a peak day.
      return schedules
          .where((s) => s.specificDate != null && !s.isPeak)
          .map((s) => s.specificDate!)
          .toList();
    },
    loading: () => [],
    error: (e, s) => [],
  );
});

final allNotesProvider =
    StateNotifierProvider.autoDispose<AllNotesNotifier, AsyncValue<List<Note>>>(
        (ref) {
  ref.watch(authProvider.select((auth) => auth.user?.id));
  return AllNotesNotifier(ref);
});

class AllNotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final Ref _ref;
  AllNotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchAllNotes();
  }

  Future<void> fetchAllNotes() async {
    // No need to set loading state here again, constructor does it.
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.getAllNotes();

      // After the async gap, check if the provider is still mounted before using it.
      if (!mounted) return;

      if (response.statusCode == 200) {
        final notes = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        // Check again right before setting state.
        if (mounted) {
          state = AsyncValue.data(notes);
        }
      } else {
        throw Exception('Failed to load all notes');
      }
    } catch (e, s) {
      // Also check here before setting an error state.
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }
}

final calendarEventProvider =
    Provider.autoDispose<LinkedHashMap<DateTime, List<Note>>>((ref) {
  final allNotesAsync = ref.watch(allNotesProvider);

  return allNotesAsync.when(
    data: (notes) {
      return LinkedHashMap<DateTime, List<Note>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      )..addAll(groupBy(
          notes,
          (Note note) =>
              DateTime.utc(note.date.year, note.date.month, note.date.day)));
    },
    loading: () => LinkedHashMap(),
    error: (e, s) => LinkedHashMap(),
  );
});
