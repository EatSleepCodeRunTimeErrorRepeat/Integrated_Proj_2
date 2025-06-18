// lib/providers/notes_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/notification_service.dart';

// The provider definition itself is unchanged.
final notesProvider = StateNotifierProvider.autoDispose
    .family<NotesNotifier, NotesState, DateTime>((ref, date) {
  return NotesNotifier(ref, date);
});

class NotesState {
  final bool isLoading;
  final List<Note> notes;
  NotesState({this.isLoading = false, this.notes = const []});
  NotesState copyWith({bool? isLoading, List<Note>? notes}) {
    return NotesState(
        isLoading: isLoading ?? this.isLoading, notes: notes ?? this.notes);
  }
}

// --- THIS CLASS HAS BEEN REWRITTEN FOR RELIABILITY AND SIMPLICITY ---
class NotesNotifier extends StateNotifier<NotesState> {
  final Ref _ref;
  final DateTime _date;

  NotesNotifier(this._ref, this._date) : super(NotesState()) {
    fetchNotesForDate();
  }

  // A public method so the UI can tell this specific provider to refresh.
  Future<void> refresh() async {
    await fetchNotesForDate();
  }

  Future<void> fetchNotesForDate() async {
    state = state.copyWith(isLoading: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.getNotesForDate(_date);
      if (response.statusCode == 200) {
        final notes = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        state = state.copyWith(isLoading: false, notes: notes);
      } else {
        throw Exception('Failed to load notes for date');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  // 'addNote' now just calls the API and returns true/false.
  // It no longer tries to refresh other providers.
  Future<bool> addNote(String content, String peakPeriod, DateTime date,
      {DateTime? remindAt}) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.createNote(content, peakPeriod, date);

      if (response.statusCode == 201) {
        // On success, schedule the notification and report success.
        final newNoteData = jsonDecode(response.body);
        final noteWithReminder = Note(
          id: newNoteData['id'],
          content: newNoteData['content'],
          peakPeriod: newNoteData['peakPeriod'],
          date: DateTime.parse(newNoteData['date']).toLocal(),
          remindAt: remindAt,
        );
        final bool isEnabled =
            _ref.read(authProvider).user?.notificationsEnabled ?? true;
        await NotificationService()
            .scheduleNoteReminder(noteWithReminder, isEnabled: isEnabled);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 'updateNote' is also simplified.
  Future<bool> updateNote(
      String noteId, String content, String peakPeriod, DateTime date,
      {DateTime? remindAt}) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response =
          await apiService.updateNote(noteId, content, peakPeriod, date);

      if (response.statusCode == 200) {
        final updatedNoteData = jsonDecode(response.body);
        final noteWithReminder = Note(
          id: updatedNoteData['id'],
          content: updatedNoteData['content'],
          peakPeriod: updatedNoteData['peakPeriod'],
          date: DateTime.parse(updatedNoteData['date']).toLocal(),
          remindAt: remindAt,
        );
        final bool isEnabled =
            _ref.read(authProvider).user?.notificationsEnabled ?? true;
        await NotificationService()
            .scheduleNoteReminder(noteWithReminder, isEnabled: isEnabled);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 'deleteNote' is also simplified.
  Future<bool> deleteNote(String noteId) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.deleteNote(noteId);
      if (response.statusCode == 200) {
        await NotificationService().cancelNoteReminder(noteId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
