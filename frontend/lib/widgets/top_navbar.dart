// lib/widgets/top_navbar.dart

import 'package:flutter/material.dart';
import 'package:frontend/screens/settings/settings_screen.dart';
import 'package:frontend/screens/tips/energy_tips_screen.dart';
import 'package:frontend/utils/app_theme.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  // Flag to conditionally show a back button instead of the settings icon
  final bool showBackButton;

  const TopNavBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // The leading widget (on the left) is now conditional
      leading: showBackButton
          ? const BackButton(color: Colors.white)
          : IconButton(
              icon: Image.asset('assets/icons/settings.png',
                  height: 28, width: 28),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
      // This prevents a default back button from appearing when we don't want it
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryGreen,
      elevation: 4,
      actions: [
        // The energy tips button remains as an action on the right
        IconButton(
          icon: Image.asset('assets/icons/EnergyTips.png',
              height: 28, width: 28, color: Colors.white),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EnergyTipsScreen(selectedDate: DateTime.now()))),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
