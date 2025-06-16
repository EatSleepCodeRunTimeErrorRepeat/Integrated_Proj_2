// lib/widgets/top_navbar.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/screens/tips/energy_tips_screen.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const TopNavBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF356C33), // Green background
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Settings Icon with navigation logic
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 12.0), // Move down by 12 pixels
              child: Image.asset(
                'assets/icons/settings.png', // Your custom settings icon
                height: 47,
                width: 47,
              ),
            ),
          ),
          // Add a Spacer to prevent the icons from overlapping
          const Spacer(),
          // Energy Tips Icon with navigation logic
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        EnergyTipsScreen(selectedDate: DateTime.now()))),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 12.0), // Move down by 12 pixels
              child: Image.asset(
                'assets/icons/EnergyTipsEdit.png', // Your custom energy tips icon
                height: 43,
                width: 43,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
