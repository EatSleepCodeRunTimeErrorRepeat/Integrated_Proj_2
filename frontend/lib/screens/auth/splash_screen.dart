// lib/screens/auth/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart'; // Import AuthWrapper

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoAnimation =
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut);

    _logoController.forward();

    // REFINED NAVIGATION LOGIC
    // Navigate to the AuthWrapper after the animation. The AuthWrapper will
    // handle the logic of showing the correct screen based on auth state.
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          // Navigate to AuthWrapper instead of LandingScreen
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: Image.asset('assets/images/Logo.png', height: 240),
            ),
            const SizedBox(height: 4),
            const Text(
              'Don’t Peak Out—Plan It Out!',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
