import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/models/peak_schedule_model.dart';

// This provider fetches notes for a SINGLE day for the schedule list.
final calendarProvider =
    FutureProvider.autoDispose.family<List<Note>, DateTime>((ref, date) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getNotesForDate(date);
  if (response.statusCode == 200) {
    final notes = (jsonDecode(response.body) as List)
        .map((data) => Note.fromJson(data))
        .toList();
    return notes;
  } else {
    throw Exception('Failed to load notes for date');
  }
});

// NEW: Provider to fetch all schedules for the user's provider
final schedulesProvider =
    FutureProvider.autoDispose<List<PeakSchedule>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user?.provider == null) {
    return []; // Return empty list if no provider is set
  }
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getSchedules(user!.provider!);
  if (response.statusCode == 200) {
    final schedules = (jsonDecode(response.body) as List)
        .map((data) => PeakSchedule.fromJson(data))
        .toList();
    return schedules;
  } else {
    throw Exception('Failed to load schedules');
  }
});

// --- REFACTORED allNotesProvider ---
// This StateNotifier will manage the state of all notes.
class AllNotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final Ref _ref;
  late final ApiService _apiService;

  AllNotesNotifier(this._ref) : super(const AsyncValue.loading()) {
    _apiService = _ref.read(apiServiceProvider);
    fetchAllNotes();
  }

  Future<void> fetchAllNotes() async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiService.getAllNotes();
      if (response.statusCode == 200) {
        final notes = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        state = AsyncValue.data(notes);
      } else {
        throw Exception('Failed to load all notes');
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

// The provider is now a StateNotifierProvider.
final allNotesProvider =
    StateNotifierProvider<AllNotesNotifier, AsyncValue<List<Note>>>((ref) {
  return AllNotesNotifier(ref);
});

// This provider now correctly consumes the new allNotesProvider
final calendarEventProvider =
    Provider<LinkedHashMap<DateTime, List<Note>>>((ref) {
  // Watch the new provider to get the async state
  final allNotesAsync = ref.watch(allNotesProvider);

  // Use .when to handle loading/error states gracefully
  return allNotesAsync.when(
    data: (notes) {
      // Group notes by date when data is available
      return LinkedHashMap<DateTime, List<Note>>(
        equals: isSameDay,
        hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
      )..addAll(groupBy(
          notes,
          (Note note) =>
              DateTime(note.date.year, note.date.month, note.date.day)));
    },
    // Return an empty map for loading and error states
    loading: () => LinkedHashMap(),
    error: (e, s) => LinkedHashMap(),
  );
});

// Helper function for table_calendar
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
