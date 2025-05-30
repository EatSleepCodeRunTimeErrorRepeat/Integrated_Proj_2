import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Green top bar with back button
          Container(
            height: 76,
            width: double.infinity,
            color: const Color(0xFF366D34),
            child: Padding(
              padding: const EdgeInsets.only(left: 25, top: 43),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
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

          // Title: About Us (centered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Center(
              child: Text(
                'About Us',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600, // SemiBold
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Body text (justified)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              'PeakSmart is a mobile app designed to help residents in Thailand manage their energy consumption by tracking peak and off-peak hours. We aim to provide a user-friendly experience that enables users to make informed decisions about their energy use, reduce their electricity costs, and contribute to a more sustainable future.\n\n'
              'Our app offers real-time peak hour alerts, ensuring that you’re always aware of when to minimize your energy usage. By helping you avoid peak hours, PeakSmart empowers you to optimize your electricity consumption, save on energy bills, and do your part in reducing strain on the energy grid.',
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400, // Regular
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
