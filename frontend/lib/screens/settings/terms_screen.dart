// lib/screens/settings/terms_screen.dart

import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms and Conditions')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: const [
          Text('1. Acceptance of Terms',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'By accessing or using the PeakSmart app (the "App"), you agree to comply with and be bound by these Terms and Conditions. If you do not agree to these terms, you should not use the App.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 20),
          Text('2. Use of the App',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'You agree to use the App solely for its intended purpose: tracking and managing energy consumption during peak and off-peak hours in Thailand. You are responsible for maintaining the confidentiality of your account details.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 20),
          Text('3. Account Registration',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'To use certain features of the App, you must create an account. You agree to provide accurate, current, and complete information during the registration process and update it as necessary.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
