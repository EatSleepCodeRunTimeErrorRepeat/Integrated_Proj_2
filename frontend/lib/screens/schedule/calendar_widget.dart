import 'package:flutter/material.dart';

class CalendarWidget extends StatelessWidget {
  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;

  const CalendarWidget({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
  });

  String _weekdayAbbr(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mo';
      case DateTime.tuesday:
        return 'Tu';
      case DateTime.wednesday:
        return 'We';
      case DateTime.thursday:
        return 'Th';
      case DateTime.friday:
        return 'Fr';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'Su';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDateSelected(index),
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0x26356C33) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: isSelected ? 20 : 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _weekdayAbbr(date.weekday),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF356C33),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
