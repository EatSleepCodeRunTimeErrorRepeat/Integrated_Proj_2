// lib/providers/notes_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/calendar_provider.dart';
import 'package:frontend/providers/home_provider.dart';

final notesProvider = StateNotifierProvider.autoDispose
    .family<NotesNotifier, NotesState, DateTime>((ref, date) {
  return NotesNotifier(ref, date);
});

class NotesState {
  final bool isLoading;
  final String? error;
  final List<Note> notes;
  final DateTime date;

  NotesState({
    required this.date,
    this.isLoading = false,
    this.error,
    this.notes = const [],
  });

  NotesState copyWith({
    DateTime? date,
    bool? isLoading,
    String? error,
    List<Note>? notes,
    bool clearError = false,
  }) {
    return NotesState(
      date: date ?? this.date,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      notes: notes ?? this.notes,
    );
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final Ref _ref;
  final DateTime _date;

  NotesNotifier(this._ref, this._date) : super(NotesState(date: _date)) {
    fetchNotesForDate();
  }

  void _syncProviders() {
    _ref.invalidate(homeProvider);
    _ref.read(allNotesProvider.notifier).fetchAllNotes();
    _ref.invalidate(calendarProvider(_date));
    fetchNotesForDate(); // Also refetch for the current screen
  }

  Future<void> fetchNotesForDate() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.getNotesForDate(_date);

      if (response.statusCode == 200) {
        final notes = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        state = state.copyWith(isLoading: false, notes: notes);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Failed to load notes: ${errorData['message']}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addNote(String content, String peakPeriod, DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.createNote(content, peakPeriod, date);
      if (response.statusCode == 201) {
        _syncProviders();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        // MODIFICATION: Log the specific error from the server
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ??
            'Failed to create note. Unknown server error.';
        // This will print the error to your debug console
        print('SERVER ERROR on note creation: $errorMessage');
        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // FIX: Added return type and robust error handling
  Future<bool> updateNote(
      String noteId, String content, String peakPeriod, DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response =
          await apiService.updateNote(noteId, content, peakPeriod, date);
      if (response.statusCode == 200) {
        _syncProviders();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: errorData['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // FIX: Added return type and robust error handling
  Future<bool> deleteNote(String noteId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.deleteNote(noteId);
      if (response.statusCode == 200) {
        _syncProviders();
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        state = state.copyWith(isLoading: false, error: errorData['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
