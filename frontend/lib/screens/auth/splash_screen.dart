// lib/screens/auth/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart';

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

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // We navigate to the AuthWrapper, which will then decide the correct
        // screen to show based on the user's login status.
        Navigator.pushReplacement(
          context,
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
