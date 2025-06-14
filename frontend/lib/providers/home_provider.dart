// lib/providers/home_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/note_model.dart';
import 'package:frontend/providers/auth_provider.dart';

// NEW: A dedicated provider to get the live peak status from our backend.
// It automatically handles async logic (loading, data, error).
final peakStatusProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // This makes the provider re-run if the user logs out or changes.
  ref.watch(authProvider.select((auth) => auth.user?.id));

  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getPeakStatus();

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    // Propagate the error message from the backend to the UI.
    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Failed to load peak status');
  }
});

// The HomeProvider is now only responsible for fetching notes. No more timers!
final homeProvider =
    StateNotifierProvider.autoDispose<HomeProvider, HomeState>((ref) {
  // This also depends on the user so it can be refreshed easily.
  ref.watch(authProvider.select((auth) => auth.user?.id));
  return HomeProvider(ref);
});

// State is simplified: only manages notes for the tips carousel.
class HomeState {
  final bool isLoading;
  final String? error;
  final List<Note> notes;

  HomeState({
    this.isLoading = true,
    this.error,
    this.notes = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    List<Note>? notes,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      notes: notes ?? this.notes,
    );
  }
}

class HomeProvider extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeProvider(this._ref) : super(HomeState()) {
    fetchNotes();
  }

  // The provider's only job is to fetch today's notes for the "Tips Carousel".
  Future<void> fetchNotes() async {
    state = state.copyWith(isLoading: true);
    try {
      final apiService = _ref.read(apiServiceProvider);
      // Fetches notes for the current date.
      final response = await apiService.getNotesForDate(DateTime.now());

      if (response.statusCode == 200) {
        final notesData = (jsonDecode(response.body) as List)
            .map((data) => Note.fromJson(data))
            .toList();
        state = state.copyWith(isLoading: false, notes: notesData);
      } else {
        throw Exception('Failed to load notes for tips carousel');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
