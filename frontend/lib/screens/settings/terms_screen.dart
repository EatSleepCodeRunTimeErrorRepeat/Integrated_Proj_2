import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green top bar with back arrow
          Container(
            height: 76,
            width: double.infinity,
            color: const Color(0xFF366D34),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 43),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/settings'),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Title: Terms and Conditions (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Text(
                'Terms and Conditions',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: 24,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Terms content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '1. Acceptance of Terms',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700, // Bold
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By accessing or using the PeakSmart app (the "App"), you agree to comply with and be bound by these Terms and Conditions. If you do not agree to these terms, you should not use the App.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400, // Regular
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '2. Use of the App',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You agree to use the App solely for its intended purpose: tracking and managing energy consumption during peak and off-peak hours in Thailand. You are responsible for maintaining the confidentiality of your account details.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '3. Account Registration',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To use certain features of the App, you must create an account. You agree to provide accurate, current, and complete information during the registration process and update it as necessary.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
