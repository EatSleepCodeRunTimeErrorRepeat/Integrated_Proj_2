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

  // 'addNote' now jsut returns the updated note object on success.
  Future<Note?> addNote(String content, String peakPeriod, DateTime date) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.createNote(content, peakPeriod, date);
      if (response.statusCode == 201) {
        return Note.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 'updateNote'now just returns the updated note object on success.
  Future<Note?> updateNote(String noteId, String content, String peakPeriod, DateTime date) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.updateNote(noteId, content, peakPeriod, date);
      if (response.statusCode == 200) {
        return Note.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 'deleteNote'  now jsut returns the updated note object on success.
  Future<bool> deleteNote(String noteId) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.deleteNote(noteId);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
