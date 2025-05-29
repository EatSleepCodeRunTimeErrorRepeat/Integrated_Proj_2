import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final Color primaryGreen = const Color(0xFF366D34);
  final Color creamBg = const Color(0xFFFBF8F0);
  final Color offPeakColor = Colors.green.shade700;

  final List<Map<String, dynamic>> dates = [
    {'day': '18', 'weekday': 'Mo'},
    {'day': '19', 'weekday': 'Tu'},
    {'day': '20', 'weekday': 'We'},
    {'day': '21', 'weekday': 'Th'},
    {'day': '22', 'weekday': 'Fr'},
    {'day': '23', 'weekday': 'Sa'},
    {'day': '24', 'weekday': 'Su'},
  ];

  int selectedDateIndex = 3; // Thursday, '21'

  final List<String> hours = [
    "08.00",
    "10.00",
    "12.00",
    "14.00",
    "16.00",
    "18.00",
    "20.00",
    "22.00",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: creamBg,
        elevation: 0,
        title: Text(
          'Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryGreen),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            color: primaryGreen,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.lightbulb_outline),
            color: primaryGreen,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dates scroll
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == selectedDateIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateIndex = index;
                        });
                      },
                      child: Container(
                        width: 50,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dates[index]['day'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dates[index]['weekday'],
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected ? Colors.white : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Hourly schedule list
              ...hours.map((hour) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        hour,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Off-Peak Hour',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: offPeakColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.transparent,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor: Colors.transparent,
                          child: CircleAvatar(
                            radius: 6,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 15),
              Divider(color: Colors.grey.shade300, thickness: 1),
              const SizedBox(height: 8),

              Text(
                'Holiday: Songkran Festival',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ScheduleScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
