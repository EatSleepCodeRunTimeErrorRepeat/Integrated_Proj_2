// lib/screens/settings/about_screen.dart

import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'PeakSmart is a mobile app designed to help residents in Thailand manage their energy consumption by tracking peak and off-peak hours. We aim to provide a user-friendly experience that enables users to make informed decisions about their energy use, reduce their electricity costs, and contribute to a more sustainable future.\n\n'
          'Our app offers real-time peak hour alerts, ensuring that you’re always aware of when to minimize your energy usage. By helping you avoid peak hours, PeakSmart empowers you to optimize your electricity consumption, save on energy bills, and do your part in reducing strain on the energy grid.',
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
