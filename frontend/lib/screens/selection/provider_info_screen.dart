import 'package:flutter/material.dart';

class ProviderInfoScreen extends StatelessWidget {
  const ProviderInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF8F0),
      appBar: AppBar(
        backgroundColor: Color(0xFFFBF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // 🔙 Back
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              "Information",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Don’t know your provider? We got you!",
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/MEALogo.png', height: 100),
                  const SizedBox(height: 8),
                  Text(
                    'การไฟฟ้านครหลวง\nMetropolitan Electricity Authority',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Check Your Electricity Bill\n• MEA (MEA การไฟฟ้านครหลวง) — You'll see MEA’s logo and contact info.\n\n2. Check Your Location\n• MEA covers: Bangkok, Nonthaburi, and Samut Prakan",
              style: TextStyle(fontSize: 14, fontFamily: 'Urbanist'),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/PEALogo.png', height: 100),
                  const SizedBox(height: 8),
                  Text(
                    'การไฟฟ้าส่วนภูมิภาค\nProvincial Electricity Authority',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "1. Check Your Electricity Bill\n• PEA (PEA การไฟฟ้าส่วนภูมิภาค) — You'll see PEA’s logo instead.\n\n2. Check Your Location\n• PEA covers: All other provinces in Thailand",
              style: TextStyle(fontSize: 14, fontFamily: 'Urbanist'),
            ),
          ],
        ),
      ),
    );
  }
}
