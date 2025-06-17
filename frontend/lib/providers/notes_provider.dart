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
  final List<Note> notes;
  NotesState({this.isLoading = false, this.notes = const []});
  NotesState copyWith({bool? isLoading, List<Note>? notes}) {
    return NotesState(
        isLoading: isLoading ?? this.isLoading, notes: notes ?? this.notes);
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final Ref _ref;
  final DateTime _date;

  NotesNotifier(this._ref, this._date) : super(NotesState()) {
    fetchNotesForDate();
  }

  void _syncProviders() {
    _ref.invalidate(homeProvider);
    _ref.invalidate(allNotesProvider);
    // After syncing other providers, also refresh the current screen's data.
    fetchNotesForDate();
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

  // The CRUD methods now just call _syncProviders on success.
  Future<bool> addNote(String content, String peakPeriod, DateTime date) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.createNote(content, peakPeriod, date);
      if (response.statusCode == 201) {
        _syncProviders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateNote(
      String noteId, String content, String peakPeriod, DateTime date) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response =
          await apiService.updateNote(noteId, content, peakPeriod, date);
      if (response.statusCode == 200) {
        _syncProviders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.deleteNote(noteId);
      if (response.statusCode == 200) {
        _syncProviders();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
