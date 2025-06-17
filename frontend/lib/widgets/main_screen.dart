import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/navigation_provider.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/schedule/schedule_screen.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/widgets/bottom_nav.dart';
import 'package:frontend/widgets/top_navbar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get the current page state.
    final currentPage = ref.watch(mainScreenPageProvider);

    // Map the enum state to an integer index for the BottomNav.
    // If we are on the settings page, we'll keep the profile tab highlighted.
    final bottomNavIndex = (currentPage == AppScreen.settings)
        ? 2 // Highlight the 'profile' tab
        : AppScreen.values.indexOf(currentPage);

    return Scaffold(
      // The TopNavBar is now part of the main layout.
      appBar: const TopNavBar(),
      body: _buildBody(currentPage),
      bottomNavigationBar: BottomNav(
        currentIndex: bottomNavIndex,
        onTap: (index) {
          // Tapping the bottom nav updates the state provider.
          ref.read(mainScreenPageProvider.notifier).state =
              AppScreen.values[index];
        },
      ),
    );
  }

  // This helper method returns the correct screen widget based on the state.
  Widget _buildBody(AppScreen screen) {
    switch (screen) {
      case AppScreen.schedule:
        return const ScheduleScreen();
      case AppScreen.home:
        return const HomeScreen();
      case AppScreen.profile:
        return const ProfileScreen();
      case AppScreen.settings:
        return const SettingsScreen();
    }
  }
}
