// lib/widgets/main_screen.dart

import 'package:flutter/material.dart';
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
  // The state for the currently selected index lives here.
  int _currentIndex = 1; // Default to HomeScreen

  // A list of the pages to be displayed.
  final List<Widget> _pages = [
    const ScheduleScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  // The callback function that updates the state.
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is the single, main Scaffold for your authenticated app state.
    return Scaffold(
      // The body changes based on the selected index.
      body: _pages[_currentIndex],
      // The single source of truth for the BottomNav.
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
