import 'package:flutter/material.dart';
import 'calendar_widget.dart'; // Your calendar widget file

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<DateTime> dates = List.generate(
    7,
    (index) => DateTime(DateTime.now().year, 1, 18 + index),
  );

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = dates[selectedIndex];

    List<String> times = [
      '00:00',
      '01:00',
      '02:00',
      '03:00',
      '04:00',
      '05:00',
      '06:00',
      '07:00',
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
      '22:00',
      '23:00',
    ];

    bool isPeakHour(String time) {
      if (selectedDate.day == 21) return time != '00:00';
      return false;
    }

    String holidayText() {
      if (selectedDate.day == 21) return 'No Holiday Today';
      if (selectedDate.day == 24) return 'Songkran Festival';
      return 'No Holiday';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with settings and energy tips icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Settings icon top-left
                  IconButton(
                    icon: const Icon(Icons.settings,
                        color: Colors.black, size: 30),
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),

                  // EnergyTips icon top-right
                  GestureDetector(
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
                ],
              ),
            ),

            // Main content container
            Center(
              child: Container(
                width: 364,
                height: 670, // Increased height
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F2E5),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Schedule',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 36,
                          color: Color(0xFF356C33),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'January',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CalendarWidget(
                      dates: dates,
                      selectedIndex: selectedIndex,
                      onDateSelected: (index) {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'Schedule Today',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: times.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) {
                          final time = times[i];
                          final peak = isPeakHour(time);
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60, // fixed width for alignment
                                  child: Text(
                                    time,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32), // moved a bit right
                                Text(
                                  peak ? 'Peak Hour' : 'Off-Peak Hour',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: peak
                                        ? const Color(0xFFFF0000)
                                        : const Color(0xFF356C33),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Holiday: ${holidayText()}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
        color: const Color(0xFFFBF8F0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                // Already on Schedule screen
              },
              icon: Image.asset(
                'assets/icons/activecalendar.png',
                width: 31.61,
                height: 31.87,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              icon: Image.asset(
                'assets/icons/Home.png',
                width: 38,
                height: 42,
                color: const Color(0xFFABABAB),
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
                color: const Color(0xFFABABAB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
