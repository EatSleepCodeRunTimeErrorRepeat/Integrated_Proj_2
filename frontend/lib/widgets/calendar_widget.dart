// lib/widgets/calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  const CalendarWidget({super.key, required this.onDateSelected});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final List<DateTime> _dates = List.generate(30, (i) => DateTime.now().add(Duration(days: i)));
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedIndex = index);
              widget.onDateSelected(_dates[index]);
            },
            child: Container(
              width: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                // FIX: Replaced deprecated .withOpacity()
                color: isSelected ? AppTheme.primaryGreen.withAlpha(38) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${date.day}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: isSelected ? 20 : 16)),
                  const SizedBox(height: 4),
                  Text(DateFormat('E').format(date), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppTheme.primaryGreen)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}