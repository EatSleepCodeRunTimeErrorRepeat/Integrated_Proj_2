import 'package:flutter/material.dart';
import 'package:frontend/screens/auth/auth_wrapper.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This screen will decide if a user is already logged in.
    // We can use a simple wrapper for this logic.
    return const AuthWrapper();
  }
}