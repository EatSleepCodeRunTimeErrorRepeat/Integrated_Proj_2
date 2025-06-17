import 'package:flutter_riverpod/flutter_riverpod.dart';

// An enum to represent all the screens that can be shown in the main view.
enum AppScreen { schedule, home, profile, settings }

// A simple provider that holds the currently visible screen.
// We will change this state to navigate between pages.
final mainScreenPageProvider = StateProvider<AppScreen>((ref) {
  // The app will start on the home screen.
  return AppScreen.home;
});
