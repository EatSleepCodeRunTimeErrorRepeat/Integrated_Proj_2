// lib/widgets/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/profile/profile_screen.dart';
import 'package:frontend/screens/schedule/schedule_screen.dart';
import 'package:frontend/widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Start on the Home screen

  // Use a final list of screens for the IndexedStack
  final List<Widget> _screens = const [
    ScheduleScreen(),
    HomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // This allows the app to draw under the system status and navigation bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    return Scaffold(
      // The body of the scaffold should not be in a SafeArea,
      // allowing screens to extend to the screen edge if they want.
      // Each individual screen (like HomeScreen) should use SafeArea if needed.
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // The bottom navigation bar will automatically be padded by the system
      // because we enabled edge-to-edge mode.
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
