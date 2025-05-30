import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String email;
  final String provider;
  final bool isPeakHour;

  const HomeScreen({
    super.key,
    required this.username,
    required this.email,
    required this.provider,
    this.isPeakHour = false, // default value
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: SizedBox(
            height: 28,
            width: 28,
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/energy-tips');
              },
              child: SizedBox(
                height: 40,
                width: 35,
                child: Image.asset(
                  'assets/icons/EnergyTips.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isPeakHour ? "Good Day," : "Good Evening,",
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF356C33),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  color: Color(0xFF858585),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            height: 273,
            width: 319,
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: isPeakHour
                  ? const Color(0xFFFF5B52)
                  : const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isPeakHour ? "YOU ARE IN" : "YOU ARE NOT IN",
                  style: const TextStyle(
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                Text(
                  "PEAK HOURS",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "02:00:00",
            style: TextStyle(
              fontSize: 32,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            isPeakHour
                ? "Countdown until Off-Peak Hours"
                : "Countdown until On-Peak Hours",
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Inter',
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Turn off your air conditioner!",
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Color(0xFF858585),
            ),
          ),
          const SizedBox(height: 120),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Text(
              "AD",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        color: const Color(0xFFFBF8F0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/calendar'); // Navigate to schedule screen here
              },
              icon: Image.asset(
                'assets/icons/calendar.png',
                width: 31.61,
                height: 31.87,
                color: const Color(0xFFABABAB),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 4),
              child: IconButton(
                onPressed: () {
                  // Already on HomeScreen, no action needed
                },
                icon: Image.asset(
                  'assets/icons/activehome.png',
                  width: 38,
                  height: 42,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: Image.asset(
                'assets/icons/profile.png',
                width: 22.41,
                height: 23.53,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
