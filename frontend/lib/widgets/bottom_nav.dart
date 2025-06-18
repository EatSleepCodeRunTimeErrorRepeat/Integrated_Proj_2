import 'package:flutter/material.dart';
import 'package:frontend/utils/app_theme.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12), // ~5% opacity
            blurRadius: 10,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, 'assets/icons/calendar.png',
                'assets/icons/activecalendar.png'),
            _buildNavItem(
                1, 'assets/icons/Home.png', 'assets/icons/activehome.png'),
            _buildNavItem(2, 'assets/icons/profile.png',
                'assets/icons/profileactive.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, String activeIconPath) {
    final bool isSelected = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Image.asset(
        isSelected ? activeIconPath : iconPath,
        height: isSelected ? 38 : 32,
      ),
    );
  }
}
