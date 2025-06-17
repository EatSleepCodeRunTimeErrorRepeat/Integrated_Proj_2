// lib/providers/home_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';

// This FutureProvider is responsible for fetching the live peak status from the backend.
// It automatically handles loading and error states for us in the UI.
// It also automatically re-runs if the user logs in or out.
final peakStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  ref.watch(authProvider.select((auth) => auth.user?.id));

  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getPeakStatus();

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Failed to load peak status');
  }
});

// This provider fetches the notes for today to be displayed in the tips carousel.
final homeProvider =
    StateNotifierProvider.autoDispose<HomeProvider, HomeState>((ref) {
  ref.watch(authProvider.select((auth) => auth.user?.id));
  return HomeProvider(ref);
});

// The state for our notes.
class HomeState {
  final List<Note> notes;
  HomeState({this.notes = const []});
  HomeState copyWith({List<Note>? notes}) {
    return HomeState(notes: notes ?? this.notes);
  }
}

class HomeProvider extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeProvider(this._ref) : super(HomeState()) {
    if (_ref.read(authProvider).isAuthenticated) {
      fetchTodaysNotes();
    }
  }

  Future<void> fetchTodaysNotes() async {
    try {
      final apiService = _ref.read(apiServiceProvider);
      final response = await apiService.getNotesForDate(DateTime.now());

      if (response.statusCode == 200) {
        final notesData = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        state = state.copyWith(notes: notesData);
      }
    } catch (e) {
      // It's okay if this fails silently, the tips carousel will just be empty.
    }
  }
}
